import PushKit
import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate, CallManagerDelegate, PortSIPEventDelegate {
    var sipRegistered: Bool!
    var portSIPSDK: PortSIPSDK!
    var mSoundService: SoundService!
    var internetReach: Reachability!
    var _callManager: CallManager!
    
    var sipURL: String?
    var isConference: Bool!
    var conferenceId: Int32!
    var loginViewController: LoginViewController!
    var _activeLine: Int!
    var activeSessionid: CLong!
    var lineSessions: [CLong] = []
    
    var _VoIPPushToken: NSString!
    var _APNsPushToken: NSString!
    var _backtaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    var _enablePushNotification: Bool?
    
    var _enableForceBackground: Bool?
    
    func findSession(sessionid: CLong) -> (Int) {
        for i in 0 ..< MAX_LINES {
            if lineSessions[i] == sessionid {
                return i
            }
        }
        print("Can't find session, Not exist this SessionId = \(sessionid)")
        return -1
    }
    
    func findIdleLine() -> (Int) {
        for i in 0 ..< MAX_LINES {
            if lineSessions[i] == CLong(INVALID_SESSION_ID) {
                return i
            }
        }
        print("No idle line available. All lines are in use.")
        return -1
    }
    
    func freeLine(sessionid: CLong) {
        for i in 0 ..< MAX_LINES {
            if lineSessions[i] == sessionid {
                lineSessions[i] = CLong(INVALID_SESSION_ID)
                return
            }
        }
        print("Can't Free Line, Not exist this SessionId = \(sessionid)")
    }
    func showAlertView(_ title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(ok)
        
        let tabBarController = window?.rootViewController as! UITabBarController
        
        tabBarController.present(alertController, animated: true)
    }
    
    // --
    
    // MARK: - APNs message PUSH
    
    @available(iOS 10.0, *) // foreground
    override func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Foreground Notification:\(userInfo)")
        completionHandler([.sound, .alert])
    }
    
    @available(iOS 10.0, *) // Background
    override func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Background Notification:\(userInfo)")
        completionHandler()
    }
    
    // 8.0 < iOS < 10.0
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == UIApplication.State.active {
            print("Foreground Notification:\(userInfo)")
        } else {
            print("Background Notification:\(userInfo)")
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        completionHandler(.newData)
    }
    
    // MARK: - VoIP PUSH
    
    func addPushSupportWithPortPBX(_ enablePush: Bool) {
        if _VoIPPushToken == nil || _APNsPushToken == nil {
            return
        }
        // This VoIP Push is only work with PortPBX(https://www.portsip.com/portsip-pbx/)
        // if you want work with other PBX, please contact your PBX Provider
        
        let bundleIdentifier: String = Bundle.main.bundleIdentifier!
        portSIPSDK.clearAddedSipMessageHeaders()
        let token = NSString(format: "%@|%@", _VoIPPushToken, _APNsPushToken)
        if enablePush {
            let pushMessage: String = NSString(format: "device-os=ios;device-uid=%@;allow-call-push=true;allow-message-push=true;app-id=%@", token, bundleIdentifier) as String
            
            print("Enable pushMessage:{\(pushMessage)}")
            
            portSIPSDK.addSipMessageHeader(-1, methodName: "REGISTER", msgType: 1, headerName: "X-Push", headerValue: pushMessage)
        } else {
            let pushMessage: String = NSString(format: "device-os=ios;device-uid=%@;allow-call-push=false;allow-message-push=false;app-id=%@", token, bundleIdentifier) as String
            
            print("Disable pushMessage:{\(pushMessage)}")
            
            portSIPSDK.addSipMessageHeader(-1, methodName: "REGISTER", msgType: 1, headerName: "X-Push", headerValue: pushMessage)
        }
    }
    
    func updatePushStatusToSipServer() {
        // This VoIP Push is only work with
        // PortPBX(https://www.portsip.com/portsip-pbx/)
        // if you want work with other PBX, please contact your PBX Provider
        
        addPushSupportWithPortPBX(_enablePushNotification!)
        loginViewController.refreshRegister()
    }
    
    func processPushMessageFromPortPBX(_ dictionaryPayload: [AnyHashable: Any], completion: () -> Void) {
        /* dictionaryPayload JSON Format
         Payload: {
         "message_id" = "96854b5d-9d0b-4644-af6d-8d97798d9c5b";
         "msg_content" = "Received a call.";
         "msg_title" = "Received a new call";
         "msg_type" = "call";// im message is "im"
         "X-Push-Id" = "pvqxCpo-j485AYo9J1cP5A..";
         "send_from" = "102";
         "send_to" = "sip:105@portsip.com";
         }
         */
        
        let parsedObject = dictionaryPayload
        var isVideoCall = false
        let msgType = parsedObject["msg_type"] as? String
        if (msgType?.count ?? 0) > 0 {
            if msgType == "video" {
                isVideoCall = true
            } else if msgType == "aduio" {
                isVideoCall = false
            }
        }
        
        var uuid: UUID?
        let pushId = dictionaryPayload["X-Push-Id"]
        
        if pushId != nil {
            let uuidStr = pushId as! String
            uuid = UUID(uuidString: uuidStr)
        }
        if uuid == nil {
            return
        }
        
        let sendFrom = parsedObject["send_from"]
        let sendTo = parsedObject["send_to"]
        
        if !_callManager.enableCallKit {
            // If not enable Call Kit, show the local Notification
            postNotification(title: "SIPSample", body: "You receive a new call From:\(String(describing: sendFrom)) To:\(String(describing: sendTo))", sound: UNNotificationSound.default, trigger:nil)
        } else {
            _callManager.incomingCall(sessionid: -1, existsVideo: isVideoCall, remoteParty: sendFrom as! String,
                                      remoteDisplayName: sendFrom as! String, callUUID: uuid!, completionHandle: completion)
            loginViewController.refreshRegister()
            beginBackgroundRegister()
        }
    }
    
    func pushRegistry(_: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for _: PKPushType) {
        var deviceTokenString = String()
        let bytes = [UInt8](pushCredentials.token)
        for item in bytes {
            deviceTokenString += String(format: "%02x", item & 0x0000_00FF)
        }
        
        _VoIPPushToken = NSString(string: deviceTokenString)
        
        print("didUpdatePushCredentials token=", deviceTokenString)
        
        updatePushStatusToSipServer()
    }
    
    func pushRegistry(_: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for _: PKPushType) {
        print("didReceiveIncomingPushWith:payload=", payload.dictionaryPayload)
        if sipRegistered,
           UIApplication.shared.applicationState == .active || _callManager.getConnectCallNum() > 0 { // ignore push message when app is active
            print("didReceiveIncomingPushWith:ignore push message when ApplicationStateActive or have active call. ")
            
            return
        }
        
        processPushMessageFromPortPBX(payload.dictionaryPayload, completion: {})
    }
    
    func pushRegistry(_: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for _: PKPushType, completion: @escaping () -> Void) {
        print("didReceiveIncomingPushWith:payload=", payload.dictionaryPayload)
        if sipRegistered,
           UIApplication.shared.applicationState == .active || _callManager.getConnectCallNum() > 0 { // ignore push message when app is active
            print("didReceiveIncomingPushWith:ignore push message when ApplicationStateActive or have active call. ")
            
            return
        }
        
        processPushMessageFromPortPBX(payload.dictionaryPayload, completion: completion)
    }
    
    func beginBackgroundRegister() {
        _backtaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundRegister()
            
        })
        
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { _ in
                
                self.endBackgroundRegister()
            })
        } else {
            // Fallback on earlier versions
            
            //          Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(endBackgroundRegister), userInfo: nil, repeats: true)
        }
    }
    
    func endBackgroundRegister() {
        if _backtaskIdentifier != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(_backtaskIdentifier)
            _backtaskIdentifier = UIBackgroundTaskIdentifier.invalid
            NSLog("endBackgroundRegister")
        }
    }
    
    func postNotification(title:String,body:String, sound:UNNotificationSound?, trigger: UNNotificationTrigger?){
        // Configure the notification's payload.
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        
        let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if error != nil {
                // Handle any errors
            }
        }
    }
    
    // MARK: UIApplicationDelegate
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if let controller = window?.rootViewController as? FlutterViewController {
            setupPortSipMethodChannel(with: controller)
        }
        UserDefaults.standard.register(defaults: ["CallKit": true])
        UserDefaults.standard.register(defaults: ["PushNotification": true])
        UserDefaults.standard.register(defaults: ["ForceBackground": false])
        
        let enableCallKit = UserDefaults.standard.bool(forKey: "CallKit")
        _enablePushNotification = UserDefaults.standard.bool(forKey: "PushNotification")
        _enableForceBackground = UserDefaults.standard.bool(forKey: "ForceBackground")
        
        portSIPSDK = PortSIPSDK()
        portSIPSDK.delegate = self
        mSoundService = SoundService()
        
        
        let cxProvider = PortCxProvider.shareInstance
        _callManager = CallManager(portsipSdk: portSIPSDK)
        _callManager.delegate = self
        _callManager.enableCallKit = enableCallKit
        cxProvider.callManager = _callManager
        
        
        _activeLine = 0
        activeSessionid = CLong(INVALID_SESSION_ID)
        for _ in 0 ..< MAX_LINES {
            lineSessions.append(CLong(INVALID_SESSION_ID))
        }
        
        sipRegistered = false
        isConference = false
        
        
        
        
        loginViewController = LoginViewController(portSIPSDK: portSIPSDK)
        
        startNotifierNetwork()
        
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        // voip push
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        
        // im push
        let notifiCenter = UNUserNotificationCenter.current()
        notifiCenter.delegate = self
        notifiCenter.requestAuthorization(options: [.alert, .sound, .badge]) { accepted, _ in
            
            if !accepted {
                print("Permission granted: \(accepted)")
            }
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    override func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var deviceTokenString = String()
        let bytes = [UInt8](deviceToken)
        for item in bytes {
            deviceTokenString += String(format: "%02x", item & 0x0000_00FF)
        }
        
        _APNsPushToken = NSString(string: deviceTokenString)
        updatePushStatusToSipServer()
    }
    
    private func registerAppNotificationSettings(launchOptions _: [UIApplication.LaunchOptionsKey: Any]?) {}
    
    @objc func reachabilityChanged(_: Notification) {
        let netStatus = internetReach.currentReachabilityStatus()
        
        switch netStatus {
        case NotReachable:
            NSLog("reachabilityChanged:kNotReachable")
        case ReachableViaWWAN:
            loginViewController.refreshRegister()
            NSLog("reachabilityChanged:kReachableViaWWAN")
        case ReachableViaWiFi:
            loginViewController.refreshRegister()
            NSLog("reachabilityChanged:kReachableViaWiFi")
        default:
            break
        }
        
    }
    
    func startNotifierNetwork() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
    }
    
    func stopNotifierNetwork() {
        internetReach.stopNotifier()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
    }
    
    // MARK: - UIApplicationDelegate
    
    override func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if(_callManager.getConnectCallNum()>0){
            return;
        }
        NSLog("applicationDidEnterBackground")
        if _enableForceBackground! {
            // Disable to save battery, or when you don't need incoming calls while APP is in background.
            portSIPSDK.startKeepAwake()
        } else {
            loginViewController.unRegister()
            
            beginBackgroundRegister()
        }
        NSLog("applicationDidEnterBackground End")
    }
    
    override func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if _enableForceBackground! {
            portSIPSDK.stopKeepAwake()
        } else {
            loginViewController.refreshRegister()
        }
    }
    
    override func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        if _enablePushNotification! {
            portSIPSDK.unRegisterServer(90);
            
            Thread.sleep(forTimeInterval: 1.0)
            
            print("applicationWillTerminate")
        }
    }
    
    // PortSIPEventDelegate
    
    func onRegisterSuccess(_ statusText: String!, statusCode: Int32, sipMessage: String!) {
        NSLog("Status: \(String(describing: statusText)), Message: \(String(describing: sipMessage))")
        sipRegistered = true
        NSLog("onRegisterSuccess")
    }
    
    func onRegisterFailure(_ statusText: String!, statusCode: Int32, sipMessage: String!) {
        NSLog("Status: \(String(describing: statusText)), Message: \(String(describing: sipMessage))")
        sipRegistered = false
        NSLog("onRegisterFailure")
    }
    
    // Call Event
    func onInviteIncoming(_ sessionId: Int, callerDisplayName: String!, caller: String!, calleeDisplayName: String!, callee: String!, audioCodecs: String!, videoCodecs: String!, existsAudio: Bool, existsVideo: Bool, sipMessage: String!) {
        
        let num = _callManager.getConnectCallNum()
        let index = findIdleLine()
        if num >= MAX_LINES || index < 0 {
            portSIPSDK.rejectCall(sessionId, code: 486)
            return
        }
        let remoteParty = caller
        let remoteDisplayName = callerDisplayName
        
        var uuid: UUID?
        if _enablePushNotification! {
            
            let pushId = portSIPSDK.getSipMessageHeaderValue(sipMessage, headerName: "X-Push-Id")
            if pushId != nil {
                uuid = UUID(uuidString: pushId!)
            }
        }
        if uuid == nil {
            uuid = UUID()
        }
        lineSessions[index] = sessionId
        
        _callManager.incomingCall(sessionid: sessionId, existsVideo: existsVideo, remoteParty: remoteParty!, remoteDisplayName: remoteDisplayName!, callUUID: uuid!, completionHandle: {})
    }
    
    func onInviteTrying(_ sessionId: Int) {
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
    }
    
    func onInviteSessionProgress(_ sessionId: Int, audioCodecs: String!, videoCodecs: String!, existsEarlyMedia: Bool, existsAudio: Bool, existsVideo: Bool, sipMessage: String!) {
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        
        if existsEarlyMedia {
            // Checking does this call has video
            if existsVideo {
                // This incoming call has video
                // If more than one codecs using, then they are separated with "#",
                // for example: "g.729#GSM#AMR", "H264#H263", you have to parse them by yourself.
            }
            
            if existsAudio {
                // If more than one codecs using, then they are separated with "#",
                // for example: "g.729#GSM#AMR", "H264#H263", you have to parse them by yourself.
            }
        }
        
        let result = _callManager.findCallBySessionID(sessionId)
        
        result!.session.existEarlyMedia = existsEarlyMedia
        
    }
    
    func onInviteRinging(_ sessionId: Int, statusText: String!, statusCode: Int32, sipMessage: String!) {
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        let result = _callManager.findCallBySessionID(sessionId)
        if !result!.session.existEarlyMedia {
            _ = mSoundService.playRingBackTone()
        }    }
    
    func onInviteAnswered(_ sessionId: Int, callerDisplayName: String!, caller: String!, calleeDisplayName: String!, callee: String!, audioCodecs: String!, videoCodecs: String!, existsAudio: Bool, existsVideo: Bool, sipMessage: String!) {
        guard let result = _callManager.findCallBySessionID(sessionId) else {
            print("Not exist this SessionId = \(sessionId)")
            return
        }
        
        result.session.sessionState = true
        result.session.videoState = existsVideo
        
        if existsVideo {
            //            videoViewController.onStartVideo(sessionId)
        }
        
        if existsAudio {}
        
        //        numpadViewController.setStatusText("Call Established on line \(findSession(sessionid: sessionId))")
        
        if result.session.isReferCall {
            result.session.isReferCall = false
            result.session.originCallSessionId = -1
        }
        
        if isConference == true {
            _callManager.joinToConference(sessionid: sessionId)
        }
        _ = mSoundService.stopRingBackTone()
    }
    
    func onInviteFailure(_ sessionId: Int, callerDisplayName: String!, caller: String!, calleeDisplayName: String!, callee: String!, reason: String!, code: Int32, sipMessage: String!) {
        
    }
    
    func onInviteUpdated(_ sessionId: Int, audioCodecs: String!, videoCodecs: String!, screenCodecs: String!, existsAudio: Bool, existsVideo: Bool, existsScreen: Bool, sipMessage: String!) {
    }
    
    func onInviteConnected(_ sessionId: Int) {
        guard let result = _callManager.findCallBySessionID(sessionId) else {
            return
        }
        
        if result.session.videoState {
            setLoudspeakerStatus(true)
        } else {
            setLoudspeakerStatus(false)
        }
        NSLog("onInviteConnected...")
    }
    
    func onInviteBeginingForward(_ forwardTo: String) {
    }
    
    func onInviteClosed(_ sessionId: Int, sipMessage: String) {
        let result = _callManager.findCallBySessionID(sessionId)
        if result != nil {
            _callManager.endCall(sessionid: sessionId)
        }
        _ = mSoundService.stopRingTone()
        _ = mSoundService.stopRingBackTone()
        // Setting speakers for sound output (The system default behavior)
        setLoudspeakerStatus(true)
        
        if activeSessionid == sessionId {
            activeSessionid = CLong(INVALID_SESSION_ID)
        }
        NSLog("onInviteClosed...")
    }
    
    func onDialogStateUpdated(_ BLFMonitoredUri: String!, blfDialogState BLFDialogState: String!, blfDialogId BLFDialogId: String!, blfDialogDirection BLFDialogDirection: String!) {
        
        NSLog("The user \(BLFMonitoredUri!) dialog state is updated:\(BLFDialogState!), dialog id: \(BLFDialogId!), direction: \(BLFDialogDirection!) ")
    }
    
    func onRemoteHold(_ sessionId: Int) {
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        
    }
    
    func onRemoteUnHold(_ sessionId: Int, audioCodecs: String!, videoCodecs: String!, existsAudio: Bool, existsVideo: Bool) {
        
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        
    }
    
    // Transfer Event
    
    func onReceivedRefer(_ sessionId: Int, referId: Int, to: String!, from: String!, referSipMessage: String!) {
        
        
        guard _callManager.findCallBySessionID(sessionId) != nil else {
            portSIPSDK.rejectRefer(referId)
            return
        }
        
        let index = findIdleLine()
        if index < 0 {
            // Not found the idle line, reject refer.
            portSIPSDK.rejectRefer(referId)
            return
        }
        
        
        // auto accept refer
        let referSessionId = portSIPSDK.acceptRefer(referId, referSignaling: referSipMessage)
        if referSessionId <= 0 {
        } else {
            _callManager.endCall(sessionid: sessionId)
            
            let session = Session()
            session.sessionId = referSessionId
            session.videoState = true
            session.recvCallState = true
            
            let newIndex = _callManager.addCall(call: session)
            lineSessions[index] = referSessionId
            
            session.sessionState = true
            session.isReferCall = true
            session.originCallSessionId = sessionId
            
        }
        /* if you want to reject Refer
         [mPortSIPSDK rejectRefer:referId);
         [numpadViewController setStatusText("Rejected the the refer.");
         */
    }
    
    func onReferAccepted(_ sessionId: Int) {
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        
    }
    
    func onReferRejected(_ sessionId: Int, reason: String!, code: Int32) {
        
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        
    }
    
    func onTransferTrying(_ sessionId: Int) {
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        
    }
    
    func onTransferRinging(_ sessionId: Int) {
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        
    }
    
    func onACTVTransferSuccess(_ sessionId: Int) {
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        
        
        // Transfer has success, hangup call.
        portSIPSDK.hangUp(sessionId)
    }
    
    func onACTVTransferFailure(_ sessionId: Int, reason: String!, code: Int32) {
        
        if sessionId == -1 {
            return
        }
        
    }
    
    // Signaling Event
    
    func onReceivedSignaling(_ sessionId: Int, message: String!) {
        
        // This event will be fired when the SDK received a SIP message
        // you can use signaling to access the SIP message.
    }
    
    func onSendingSignaling(_ sessionId: Int, message: String!) {
        
        // This event will be fired when the SDK sent a SIP message
        // you can use signaling to access the SIP message.
    }
    
    func onWaitingVoiceMessage(_ messageAccount: String!, urgentNewMessageCount: Int32, urgentOldMessageCount: Int32, newMessageCount: Int32, oldMessageCount: Int32) {
        
    }
    
    func onWaitingFaxMessage(_ messageAccount: String!, urgentNewMessageCount: Int32, urgentOldMessageCount: Int32, newMessageCount: Int32, oldMessageCount: Int32) {
    }
    
    func onRecvDtmfTone(_ sessionId: Int, tone: Int32) {
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        
    }
    
    func onRecvOptions(_ optionsMessage: String!) {
        
        NSLog("Received an OPTIONS message:\(optionsMessage!)")
    }
    
    func onRecvInfo(_ infoMessage: String!) {
        
        NSLog("Received an INFO message:\(infoMessage!)")
    }
    
    func onRecvNotifyOfSubscription(_ subscribeId: Int, notifyMessage: String!, messageData: UnsafeMutablePointer<UInt8>!, messageDataLength: Int32) {
        NSLog("Received an Notify message")
    }
    
    // Instant Message/Presence Event
    
    func onPresenceRecvSubscribe(_ subscribeId: Int, fromDisplayName: String!, from: String!, subject: String!) {
        
    }
    func onPresenceOnline(_ fromDisplayName: String!, from: String!, stateText: String!) {
        
    }
    
    func onPresenceOffline(_ fromDisplayName: String!, from: String!) {
    }
    
    func onRecvMessage(_ sessionId: Int, mimeType: String!, subMimeType: String!, messageData: UnsafeMutablePointer<UInt8>!, messageDataLength: Int32) {
        
        let index = findSession(sessionid: sessionId)
        if index == -1 {
            return
        }
        
        
        if mimeType == "text", subMimeType == "plain" {
            let recvMessage = String(cString: messageData)
            
            showAlertView("recvMessage", message: recvMessage)
        } else if mimeType == "application", subMimeType == "vnd.3gpp.sms" {
            // The messageData is binary data
        } else if mimeType == "application", subMimeType == "vnd.3gpp2.sms" {
            // The messageData is binary data
        }
    }
    
    func onRTPPacketCallback(_ sessionId: Int, mediaType: Int32, direction: DIRECTION_MODE, rtpPacket RTPPacket: UnsafeMutablePointer<UInt8>!, packetSize: Int32) {
        
    }
    
    func onRecvOutOfDialogMessage(_ fromDisplayName: String!, from: String!, toDisplayName: String!, to: String!, mimeType: String!, subMimeType: String!, messageData: UnsafeMutablePointer<UInt8>!, messageDataLength: Int32, sipMessage: String!) {
        
        
        if mimeType == "text", subMimeType == "plain" {
            let strMessageData = String(cString: messageData)
            showAlertView(from!, message: strMessageData)
        } else if mimeType == "application", subMimeType == "vnd.3gpp.sms" {
            // The messageData is binary data
        } else if mimeType == "application", subMimeType == "vnd.3gpp2.sms" {
            // The messageData is binary data
        }
    }
    
    func onSendOutOfDialogMessageSuccess(_ messageId: Int, fromDisplayName: String!, from: String!, toDisplayName: String!, to: String!, sipMessage: String!) {
    }
    
    func onSendMessageFailure(_ sessionId: Int, messageId: Int, reason: String!, code: Int32, sipMessage: String!) {
    }
    
    func onSendMessageSuccess(_ sessionId: Int, messageId: Int, sipMessage: String!) {
    }
    
    func onPlayFileFinished(_ sessionId: Int, fileName: String!) {
        NSLog("PlayFileFinished fileName \(fileName!)")
    }
    func onStatistics(_ sessionId: Int, stat: String!) {
        NSLog("onStatistics stat: \(stat!)")
    }
    
    func onSendOutOfDialogMessageSuccess(_ messageId: Int, fromDisplayName _: UnsafeMutablePointer<Int8>!, from _: UnsafeMutablePointer<Int8>!, toDisplayName _: UnsafeMutablePointer<Int8>!, to _: UnsafeMutablePointer<Int8>!, sipMessage: UnsafeMutablePointer<CChar>!) {
    }
    
    func onSendOutOfDialogMessageFailure(_ messageId: Int, fromDisplayName: String!, from: String!, toDisplayName: String!, to: String!, reason: String!, code: Int32, sipMessage: String!) {
    }
    
    func onSubscriptionFailure(_ subscribeId: Int, statusCode: Int32) {
        NSLog("SubscriptionFailure subscribeId \(subscribeId) statusCode: \(statusCode)")
    }
    
    func onSubscriptionTerminated(_ subscribeId: Int) {
        NSLog("SubscriptionFailure subscribeId \(subscribeId)")
    }
    
    
    func onAudioRawCallback(_: Int, audioCallbackMode _: Int32, data _: UnsafeMutablePointer<UInt8>!, dataLength _: Int32, samplingFreqHz _: Int32) {
        /* !!! IMPORTANT !!!
         
         Don't call any PortSIP SDK API functions in here directly. If you want to call the PortSIP API functions or
         other code which will spend long time, you should post a message to main thread(main window) or other thread,
         let the thread to call SDK API functions or other code.
         */
    }
    
    func onVideoRawCallback(_: Int, videoCallbackMode _: Int32, width _: Int32, height _: Int32, data _: UnsafeMutablePointer<UInt8>!, dataLength _: Int32) -> Int32 {
        /* !!! IMPORTANT !!!
         
         Don't call any PortSIP SDK API functions in here directly. If you want to call the PortSIP API functions or
         other code which will spend long time, you should post a message to main thread(main window) or other thread,
         let the thread to call SDK API functions or other code.
         */
        0
    }
    
    func pressNumpadButton(_ dtmf: Int32) {
        if activeSessionid != CLong(INVALID_SESSION_ID) {
            _callManager.playDtmf(sessionid: activeSessionid, tone: Int(dtmf))
        }
    }
    
    func makeCall(_ callee: String, videoCall: Bool) -> (CLong) {
        if activeSessionid != CLong(INVALID_SESSION_ID) {
            showAlertView("Warning", message: "Current line is busy now, please switch a line")
            return CLong(INVALID_SESSION_ID)
        }
        
        let sessionId = _callManager.makeCall(callee: callee, displayName: callee, videoCall: videoCall)
        
        if sessionId >= 0 {
            activeSessionid = sessionId
            print("makeCall------------------ \(String(describing: activeSessionid))")
            
            return activeSessionid
        } else {
            return sessionId
        }
    }
    
    func hungUpCall() {
        if activeSessionid != CLong(INVALID_SESSION_ID) {
            _ = mSoundService.stopRingTone()
            _ = mSoundService.stopRingBackTone()
            _callManager.endCall(sessionid: activeSessionid)
            
        }
    }
    
    func holdCall() {
        if activeSessionid != CLong(INVALID_SESSION_ID) {
            _callManager.holdCall(sessionid: activeSessionid, onHold: true)
        }
        
        if isConference == true {
            _callManager.holdAllCall(onHold: true)
        }
    }
    
    func unholdCall() {
        if activeSessionid != CLong(INVALID_SESSION_ID) {
            _callManager.holdCall(sessionid: activeSessionid, onHold: false)
        }
        
        if isConference == true {
            _callManager.holdAllCall(onHold: false)
        }
    }
    
    func referCall(_ referTo: String) {
        let result = _callManager.findCallBySessionID(activeSessionid)
        if result == nil || !result!.session.sessionState {
            showAlertView("Warning", message: "Need to make the call established first")
            return
        }
        
        let ret = portSIPSDK.refer(activeSessionid, referTo: referTo)
        if ret != 0 {
            showAlertView("Warning", message: "Refer failed")
        }
    }
    
    func muteCall(_ mute: Bool) {
        if activeSessionid != CLong(INVALID_SESSION_ID) {
            _callManager.muteCall(sessionid: activeSessionid, muted: mute)
        }
        if isConference == true {
            _callManager.muteAllCall(muted: mute)
        }
    }
    
    func setLoudspeakerStatus(_ enable: Bool) {
        portSIPSDK.setLoudspeakerStatus(enable)
    }
    
    //    func getStatistics() {
    //        let audio: Bool = true
    //        let video: Bool = true
    //        if audio {
    //            // audio Statistics
    //            var sendBytes: Int32 = 0
    //            var sendPackets: Int32 = 0
    //            var sendPacketsLost: Int32 = 0
    //            var sendFractionLost: Int32 = 0
    //            var sendRttMS: Int32 = 0
    //            var sendCodecType: Int32 = 0
    //            var sendJitterMS: Int32 = 0
    //            var sendAudioLevel: Int32 = 0
    //            var recvBytes: Int32 = 0
    //            var recvPackets: Int32 = 0
    //            var recvPacketsLost: Int32 = 0
    //            var recvFractionLost: Int32 = 0
    //            var recvCodecType: Int32 = 0
    //            var recvJitterMS: Int32 = 0
    //            var recvAudioLevel: Int32 = 0
    //
    //            let errorCodec: Int32 = portSIPSDK.getAudioStatistics(activeSessionid, sendBytes: &sendBytes, sendPackets: &sendPackets, sendPacketsLost: &sendPacketsLost, sendFractionLost: &sendFractionLost, sendRttMS: &sendRttMS, sendCodecType: &sendCodecType, sendJitterMS: &sendJitterMS, sendAudioLevel: &sendAudioLevel, recvBytes: &recvBytes, recvPackets: &recvPackets, recvPacketsLost: &recvPacketsLost, recvFractionLost: &recvFractionLost, recvCodecType: &recvCodecType, recvJitterMS: &recvJitterMS, recvAudioLevel: &recvAudioLevel)
    //            if errorCodec == 0 {
    //                print("Audio Send Statistics sendBytes:\(sendBytes) sendPackets:\(sendPackets) sendPacketsLost:\(sendPacketsLost) sendFractionLost:\(sendFractionLost) sendRttMS:\(sendRttMS) sendCodecType:\(sendCodecType) sendJitterMS:\(sendJitterMS) sendAudioLevel:\(sendAudioLevel) ")
    //                print("Audio Received Statistics recvBytes:\(recvBytes) recvPackets:\(recvPackets) recvPacketsLost:\(recvPacketsLost) recvFractionLost:\(recvFractionLost) recvCodecType:\(recvCodecType) recvJitterMS:\(recvJitterMS) recvAudioLevel:\(recvAudioLevel)")
    //            }
    //        }
    //        if video {
    //            // Video Statistics
    //            var sendBytes: Int32 = 0
    //            var sendPackets: Int32 = 0
    //            var sendPacketsLost: Int32 = 0
    //            var sendFractionLost: Int32 = 0
    //            var sendRttMS: Int32 = 0
    //            var sendCodecType: Int32 = 0
    //            var sendFrameWidth: Int32 = 0
    //            var sendFrameHeight: Int32 = 0
    //            var sendBitrateBPS: Int32 = 0
    //            var sendFramerate: Int32 = 0
    //            var recvBytes: Int32 = 0
    //            var recvPackets: Int32 = 0
    //            var recvPacketsLost: Int32 = 0
    //            var recvFractionLost: Int32 = 0
    //            var recvCodecType: Int32 = 0
    //            var recvFrameWidth: Int32 = 0
    //            var recvFrameHeight: Int32 = 0
    //            var recvBitrateBPS: Int32 = 0
    //            var recvFramerate: Int32 = 0
    //            let errorCodec: Int32 = portSIPSDK.getVideoStatistics(activeSessionid, sendBytes: &sendBytes, sendPackets: &sendPackets, sendPacketsLost: &sendPacketsLost, sendFractionLost: &sendFractionLost, sendRttMS: &sendRttMS, sendCodecType: &sendCodecType, sendFrameWidth: &sendFrameWidth, sendFrameHeight: &sendFrameHeight, sendBitrateBPS: &sendBitrateBPS, sendFramerate: &sendFramerate, recvBytes: &recvBytes, recvPackets: &recvPackets, recvPacketsLost: &recvPacketsLost, recvFractionLost: &recvFractionLost, recvCodecType: &recvCodecType, recvFrameWidth: &recvFrameWidth, recvFrameHeight: &recvFrameHeight, recvBitrateBPS: &recvBitrateBPS, recvFramerate: &recvFramerate)
    //
    //            if errorCodec == 0 {
    //                print("Video Send Statistics sendBytes:\(sendBytes) sendPackets:\(sendPackets) sendPacketsLost:\(sendPacketsLost) sendFractionLost:\(sendFractionLost) sendRttMS:\(sendRttMS) sendCodecType:\(sendCodecType) sendFrameWidth:\(sendFrameWidth) sendFrameHeight:\(sendFrameHeight) sendBitrateBPS:\(sendBitrateBPS) sendFramerate:\(sendFramerate) ")
    //            }
    //        }
    //    }
    
    func didSelectLine(_ activedline: Int) {
        let tabBarController = window?.rootViewController as! UITabBarController
        
        tabBarController.dismiss(animated: true, completion: nil)
        
        if !sipRegistered || _activeLine == activedline {
            return
        }
        
        if !isConference {
            _callManager.holdCall(sessionid: activeSessionid, onHold: true)
        }
        _activeLine = activedline
        
        activeSessionid = lineSessions[_activeLine]
        
        
        if !isConference && activeSessionid != CLong(INVALID_SESSION_ID) {
            _callManager.holdCall(sessionid: activeSessionid, onHold: false)
        }
    }
    
    func switchSessionLine() {
        
    }
    
    //    #pragma mark - CallManager delegate
    
    func onIncomingCallWithoutCallKit(_ sessionId: CLong, existsVideo: Bool, remoteParty: String, remoteDisplayName: String) {
        guard _callManager.findCallBySessionID(sessionId) != nil else {
            return
        }
        if UIApplication.shared.applicationState == .background, _enablePushNotification == false {
            
            var stringAlert:String;
            if(existsVideo){
                stringAlert = "VideoCall from \n  \(remoteParty)"
            }
            else{
                stringAlert = "Call from \n \(remoteParty)"
            }
            
            postNotification(title: "SIPSample", body: stringAlert, sound:nil, trigger: nil)
        } else {
            let index = findSession(sessionid: sessionId)
            if index < 0 {
                return
            }
            let alertController = UIAlertController(title: "Incoming Call", message: "Call from <\(remoteDisplayName)>\(remoteParty) on line \(index)", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Reject", style: .default, handler: { action in
                _ = self.mSoundService.stopRingTone()
                self._callManager.endCall(sessionid: sessionId)
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Answer", style: .default, handler: { action in
                _ = self.mSoundService.stopRingTone()
                _ = self._callManager.answerCall(sessionId: sessionId, isVideo: false)
                
            }))
            
            if existsVideo {
                alertController.addAction(UIAlertAction(title: "Video", style: .default, handler: { action in
                    _ = self.mSoundService.stopRingTone()
                    _ = self._callManager.answerCall(sessionId: sessionId, isVideo: true)
                    
                }))
            }
            
            let tabBarController = window?.rootViewController as! UITabBarController
            
            tabBarController.present(alertController, animated: true)
            
            _ = mSoundService.playRingTone()
        }
    }
    
    func onNewOutgoingCall(sessionid: CLong) {
        lineSessions[_activeLine] = sessionid
    }
    
    func onAnsweredCall(sessionId: CLong) {
        let result = _callManager.findCallBySessionID(sessionId)
        
        if result != nil {
            if result!.session.videoState {
                setLoudspeakerStatus(true)
            } else {
                setLoudspeakerStatus(false)
            }
            let line = findSession(sessionid: sessionId)
            if line >= 0 {
                didSelectLine(line)
            }
        }
        
        _ = mSoundService.stopRingTone()
        _ = mSoundService.stopRingBackTone()
        
        if activeSessionid == CLong(INVALID_SESSION_ID) {
            activeSessionid = sessionId
        }
        
    }
    
    func onCloseCall(sessionId: CLong) {
        
        freeLine(sessionid: sessionId)
        
        let result = _callManager.findCallBySessionID(sessionId)
        if result != nil {
            if result!.session.videoState {
            }
            
            _callManager.removeCall(call: result!.session)
        }
        if sessionId == activeSessionid {
            activeSessionid = CLong(INVALID_SESSION_ID)
        }
        
        _ = mSoundService.stopRingTone()
        _ = mSoundService.stopRingBackTone()
        
        if _callManager.getConnectCallNum() == 0 {
            setLoudspeakerStatus(true)
        }
    }
    
    func onMuteCall(sessionId: CLong, muted _: Bool) {
        let result = _callManager.findCallBySessionID(sessionId)
        if result != nil {
            // update Mute status
        }
    }
    
    func onHoldCall(sessionId: CLong, onHold: Bool) {
        let result = _callManager.findCallBySessionID(sessionId)
        if result != nil, sessionId == activeSessionid {
            if onHold {
                portSIPSDK.setRemoteVideoWindow(sessionId, remoteVideoWindow: nil)
                portSIPSDK.setRemoteScreenWindow(sessionId, remoteScreenWindow: nil)
            } else {
                if(!isConference){
                }
            }
        }
    }
    
    func createConference(_ conferenceVideoWindow: PortSIPVideoRenderView) {
        if _callManager.createConference(conferenceVideoWindow: conferenceVideoWindow, videoWidth: 352, videoHeight: 288, displayLocalVideoInConference: true) {
            isConference = true
        }
    }
    
    func setConferenceVideoWindow(conferenceVideoWindow: PortSIPVideoRenderView) {
        portSIPSDK.setConferenceVideoWindow(conferenceVideoWindow)
    }
    
    func destoryConference(_: UIView) {
        _callManager.destoryConference()
        let result = _callManager.findCallBySessionID(activeSessionid)
        if result != nil && result!.session.holdState {
            _callManager.holdCall(sessionid: result!.session.sessionId, onHold: false)
        }
        isConference = false
    }
    
    private func setupPortSipMethodChannel(with controller: FlutterViewController) {
        let channel = FlutterMethodChannel(name: "port_sip", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            switch call.method {
            case "Login":
                if let args = call.arguments as? [String: Any],
                   let username = args["username"] as? String,
                   let displayName = args["displayName"] as? String,
                   let authName = args["authName"] as? String,
                   let password = args["password"] as? String,
                   let userDomain = args["userDomain"] as? String,
                   let sipServer = args["sipServer"] as? String,
                   let sipServerPort = args["sipServerPort"] as? Int32,
                   let transportType = args["transportType"] as? Int,
                   let srtpType = args["srtpType"] as? Int {
                   self.loginViewController.onLine(username:username, displayName: username, authName: "", password: password, userDomain: userDomain, sipServer: sipServer, sipServerPort: sipServerPort, transportType: 0, srtpType: 0)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                }
            case "Offline":
                self.loginViewController.offLine()
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
