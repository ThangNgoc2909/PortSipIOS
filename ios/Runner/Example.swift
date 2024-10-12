//import UIKit
//import Flutter
//import PortSIPVoIPSDK
//
//@UIApplicationMain
//class AppDelegate: FlutterAppDelegate, PortSIPEventDelegate {
//    func onInviteIncoming(_ sessionId: Int, callerDisplayName: String!, caller: String!, calleeDisplayName: String!, callee: String!, audioCodecs: String!, videoCodecs: String!, existsAudio: Bool, existsVideo: Bool, sipMessage: String!) {
//        
//    }
//    
//    func onInviteTrying(_ sessionId: Int) {
//        
//    }
//    
//    func onInviteSessionProgress(_ sessionId: Int, audioCodecs: String!, videoCodecs: String!, existsEarlyMedia: Bool, existsAudio: Bool, existsVideo: Bool, sipMessage: String!) {
//        
//    }
//    
//    func onInviteRinging(_ sessionId: Int, statusText: String!, statusCode: Int32, sipMessage: String!) {
//        
//    }
//    
//    func onInviteAnswered(_ sessionId: Int, callerDisplayName: String!, caller: String!, calleeDisplayName: String!, callee: String!, audioCodecs: String!, videoCodecs: String!, existsAudio: Bool, existsVideo: Bool, sipMessage: String!) {
//        
//    }
//    
//    func onInviteFailure(_ sessionId: Int, callerDisplayName: String!, caller: String!, calleeDisplayName: String!, callee: String!, reason: String!, code: Int32, sipMessage: String!) {
//        
//    }
//    
//    func onInviteUpdated(_ sessionId: Int, audioCodecs: String!, videoCodecs: String!, screenCodecs: String!, existsAudio: Bool, existsVideo: Bool, existsScreen: Bool, sipMessage: String!) {
//        
//    }
//    
//    func onInviteConnected(_ sessionId: Int) {
//        
//    }
//    
//    func onInviteBeginingForward(_ forwardTo: String!) {
//        
//    }
//    
//    func onInviteClosed(_ sessionId: Int, sipMessage: String!) {
//        
//    }
//    
//    func onDialogStateUpdated(_ BLFMonitoredUri: String!, blfDialogState BLFDialogState: String!, blfDialogId BLFDialogId: String!, blfDialogDirection BLFDialogDirection: String!) {
//        
//    }
//    
//    func onRemoteHold(_ sessionId: Int) {
//        
//    }
//    
//    func onRemoteUnHold(_ sessionId: Int, audioCodecs: String!, videoCodecs: String!, existsAudio: Bool, existsVideo: Bool) {
//        
//    }
//    
//    func onReceivedRefer(_ sessionId: Int, referId: Int, to: String!, from: String!, referSipMessage: String!) {
//        
//    }
//    
//    func onReferAccepted(_ sessionId: Int) {
//        
//    }
//    
//    func onReferRejected(_ sessionId: Int, reason: String!, code: Int32) {
//        
//    }
//    
//    func onTransferTrying(_ sessionId: Int) {
//        
//    }
//    
//    func onTransferRinging(_ sessionId: Int) {
//        
//    }
//    
//    func onACTVTransferSuccess(_ sessionId: Int) {
//        
//    }
//    
//    func onACTVTransferFailure(_ sessionId: Int, reason: String!, code: Int32) {
//        
//    }
//    
//    func onReceivedSignaling(_ sessionId: Int, message: String!) {
//        
//    }
//    
//    func onSendingSignaling(_ sessionId: Int, message: String!) {
//        
//    }
//    
//    func onWaitingVoiceMessage(_ messageAccount: String!, urgentNewMessageCount: Int32, urgentOldMessageCount: Int32, newMessageCount: Int32, oldMessageCount: Int32) {
//        
//    }
//    
//    func onWaitingFaxMessage(_ messageAccount: String!, urgentNewMessageCount: Int32, urgentOldMessageCount: Int32, newMessageCount: Int32, oldMessageCount: Int32) {
//        
//    }
//    
//    func onRecvDtmfTone(_ sessionId: Int, tone: Int32) {
//        
//    }
//    
//    func onRecvOptions(_ optionsMessage: String!) {
//        
//    }
//    
//    func onRecvInfo(_ infoMessage: String!) {
//        
//    }
//    
//    func onRecvNotifyOfSubscription(_ subscribeId: Int, notifyMessage: String!, messageData: UnsafeMutablePointer<UInt8>!, messageDataLength: Int32) {
//        
//    }
//    
//    func onPresenceRecvSubscribe(_ subscribeId: Int, fromDisplayName: String!, from: String!, subject: String!) {
//        
//    }
//    
//    func onPresenceOnline(_ fromDisplayName: String!, from: String!, stateText: String!) {
//        
//    }
//    
//    func onPresenceOffline(_ fromDisplayName: String!, from: String!) {
//        
//    }
//    
//    func onRecvMessage(_ sessionId: Int, mimeType: String!, subMimeType: String!, messageData: UnsafeMutablePointer<UInt8>!, messageDataLength: Int32) {
//        
//    }
//    
//    func onRecvOutOfDialogMessage(_ fromDisplayName: String!, from: String!, toDisplayName: String!, to: String!, mimeType: String!, subMimeType: String!, messageData: UnsafeMutablePointer<UInt8>!, messageDataLength: Int32, sipMessage: String!) {
//        
//    }
//    
//    func onSendMessageSuccess(_ sessionId: Int, messageId: Int, sipMessage: String!) {
//        
//    }
//    
//    func onSendMessageFailure(_ sessionId: Int, messageId: Int, reason: String!, code: Int32, sipMessage: String!) {
//        
//    }
//    
//    func onSendOutOfDialogMessageSuccess(_ messageId: Int, fromDisplayName: String!, from: String!, toDisplayName: String!, to: String!, sipMessage: String!) {
//        
//    }
//    
//    func onSendOutOfDialogMessageFailure(_ messageId: Int, fromDisplayName: String!, from: String!, toDisplayName: String!, to: String!, reason: String!, code: Int32, sipMessage: String!) {
//        
//    }
//    
//    func onSubscriptionFailure(_ subscribeId: Int, statusCode: Int32) {
//        
//    }
//    
//    func onSubscriptionTerminated(_ subscribeId: Int) {
//        
//    }
//    
//    func onPlayFileFinished(_ sessionId: Int, fileName: String!) {
//        
//    }
//    
//    func onStatistics(_ sessionId: Int, stat: String!) {
//        
//    }
//    
//    func onRTPPacketCallback(_ sessionId: Int, mediaType: Int32, direction: DIRECTION_MODE, rtpPacket RTPPacket: UnsafeMutablePointer<UInt8>!, packetSize: Int32) {
//        
//    }
//    
//    func onAudioRawCallback(_ sessionId: Int, audioCallbackMode: Int32, data: UnsafeMutablePointer<UInt8>!, dataLength: Int32, samplingFreqHz: Int32) {
//        
//    }
//    
//    func onVideoRawCallback(_ sessionId: Int, videoCallbackMode: Int32, width: Int32, height: Int32, data: UnsafeMutablePointer<UInt8>!, dataLength: Int32) -> Int32 {
//        return Int32(123)
//    }
//    
//    var portSipSDK: PortSIPSDK!
//    var loginController: LoginViewController!
//    override func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//        GeneratedPluginRegistrant.register(with: self)
//        if let controller = window?.rootViewController as? FlutterViewController {
//            setupPortSipMethodChannel(with: controller)
//        }
//        initializeSDK()
//        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
//    
//    func initializeSDK() {
//        portSipSDK = PortSIPSDK()
//        portSipSDK.enableCallKit(true)
//        portSipSDK.initialize(
//           TRANSPORT_TCP, localIP: "0.0.0.0", localSIPPort: Int32(10002), loglevel: PORTSIP_LOG_NONE, logPath: "",
//           maxLine: 8, agent: "PortSIP SDK for IOS", audioDeviceLayer: 0, videoDeviceLayer: 0,
//           tlsCertificatesRootPath: "", tlsCipherList: "", verifyTLSCertificate: false, dnsServers: "")
//
//         // những cấu hình liên quan đến Audio
//        portSipSDK.addAudioCodec(AUDIOCODEC_OPUS)
//        portSipSDK.addAudioCodec(AUDIOCODEC_G729)
//        portSipSDK.addAudioCodec(AUDIOCODEC_PCMA)
//        portSipSDK.addAudioCodec(AUDIOCODEC_PCMU)
//        portSipSDK.setAudioSamples(20, maxPtime: 60)
//
//         // những cấu hình liên quan đến Video
//        portSipSDK.addVideoCodec(VIDEO_CODEC_H264)
//        portSipSDK.addVideoCodec(VIDEO_CODEC_H263_1998)
//        portSipSDK.addVideoCodec(VIDEO_CODEC_VP8)
//        portSipSDK.addVideoCodec(VIDEO_CODEC_VP9)
//        portSipSDK.setVideoBitrate(-1, bitrateKbps: 512)
//        portSipSDK.setVideoFrameRate(-1, frameRate: 20)
//        portSipSDK.setVideoResolution(480, height: 640)
//        portSipSDK.setVideoNackStatus(true)
//        portSipSDK.setInstanceId(UIDevice.current.identifierForVendor?.uuidString)
//
//        portSipSDK.setLicenseKey("PORTSIP_TEST_LICENSE")
//        loginController = LoginViewController(portSIPSDK: portSipSDK)
//    }
//    
//    private func setupPortSipMethodChannel(with controller: FlutterViewController) {
//        let channel = FlutterMethodChannel(name: "port_sip", binaryMessenger: controller.binaryMessenger)
//        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
//            guard let self = self else { return }
//            
//            
//            switch call.method {
//            case "Login":
//                // Extract arguments from the Flutter call
//                if let args = call.arguments as? [String: Any],
//                   let username = args["username"] as? String,
//                   let displayName = args["displayName"] as? String,
//                   let authName = args["authName"] as? String,
//                   let password = args["password"] as? String,
//                   let userDomain = args["userDomain"] as? String,
//                   let sipServer = args["sipServer"] as? String,
//                   let sipServerPort = args["sipServerPort"] as? Int32,
//                   let transportType = args["transportType"] as? Int,
//                   let srtpType = args["srtpType"] as? Int {
//                    
//                    let response = onLine(username: username, displayName: username, authName: authName, password: password, userDomain: userDomain, sipServer: sipServer, sipServerPort: sipServerPort, transportType: transportType, srtpType: srtpType)
//                    result(response)
//                } else {
//                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
//                }
//            default:
//                result(FlutterMethodNotImplemented)
//            }
//        }
//    }
//    
//    func onRegisterSuccess(_ statusText: String!, statusCode: Int32, sipMessage: String!) {
//        print("12312313123")
//        NSLog("onRegisterSuccess")
//    }
//
//    func onRegisterFailure(_ statusText: String!, statusCode: Int32, sipMessage: String!) {
//        print("12312313123")
//    }
//
//    
//    func addPushSupportWithPortPBX(_ enablePush: Bool) {
//        let _VoIPPushToken = "0a6773e98a4732ee0e8b29197797b7c7aebfaf6606f8f5465807977fff15c3aa"
//        let _APNsPushToken = "9f8e110e10a702fb63a70dd74f8a912da992762da5cc0940767a7e8e5aec0b65"
//        // This VoIP Push is only work with PortPBX(https://www.portsip.com/portsip-pbx/)
//        // if you want work with other PBX, please contact your PBX Provider
//
//        let bundleIdentifier: String = Bundle.main.bundleIdentifier!
//        portSipSDK.clearAddedSipMessageHeaders()
//        let token = NSString(format: "%@|%@", _VoIPPushToken, _APNsPushToken)
//        if enablePush {
//            let pushMessage: String = NSString(format: "device-os=ios;device-uid=%@;allow-call-push=true;allow-message-push=true;app-id=%@", token, bundleIdentifier) as String
//
//            print("Enable pushMessage:{\(pushMessage)}")
//
//            portSipSDK.addSipMessageHeader(-1, methodName: "REGISTER", msgType: 1, headerName: "X-Push", headerValue: pushMessage)
//        } else {
//            let pushMessage: String = NSString(format: "device-os=ios;device-uid=%@;allow-call-push=false;allow-message-push=false;app-id=%@", token, bundleIdentifier) as String
//
//            print("Disable pushMessage:{\(pushMessage)}")
//
//            portSipSDK.addSipMessageHeader(-1, methodName: "REGISTER", msgType: 1, headerName: "X-Push", headerValue: pushMessage)
//        }
//    }
//    func onLine(username: String, displayName: String, authName: String, password: String, userDomain: String, sipServer: String, sipServerPort: Int32, transportType: Int, srtpType: Int) -> String {
//        if username.isEmpty {
//            return "Please enter user name!"
//        }
//        
//        if password.isEmpty {
//            return "Please enter password"
//        }
//        
//        if sipServer.isEmpty {
//            return "Please enter SIP Server"
//        }
//        
//        var transport = TRANSPORT_UDP
//        switch transportType {
//        case 0:
//            transport = TRANSPORT_UDP
//        case 1:
//            transport = TRANSPORT_TLS
//        case 2:
//            transport = TRANSPORT_TCP
//        default:
//            break
//        }
//        
//        var srtp = SRTP_POLICY_NONE
//        switch srtpType {
//        case 0:
//            srtp = SRTP_POLICY_NONE
//        case 1:
//            srtp = SRTP_POLICY_FORCE
//        case 2:
//            srtp = SRTP_POLICY_PREFER
//        default:
//            break
//        }
//        
//        UserDefaults.standard.set(username, forKey: "kUserName")
//        UserDefaults.standard.set(authName, forKey: "kAuthName")
//        UserDefaults.standard.set(password, forKey: "kPassword")
//        UserDefaults.standard.set(userDomain, forKey: "kUserDomain")
//        UserDefaults.standard.set(sipServer, forKey: "kSIPServer")
//        UserDefaults.standard.set(sipServerPort, forKey: "kSIPServerPort")
//        UserDefaults.standard.set(transportType, forKey: "kTRANSPORT")
//
//    
//        let retUser = portSipSDK.setUser(username, displayName: displayName, authName: authName, password: password, userDomain: userDomain, sipServer: sipServer, sipServerPort: sipServerPort, stunServer: "", stunServerPort: 0, outboundServer: "", outboundServerPort: 0)
//        
//        if retUser != 0 {
//            NSLog("setUser failure ErrorCode = %d", retUser)
//            return "setUser failure ErrorCode = %d"
//        }
//    
//            addPushSupportWithPortPBX(true)
//        
//        portSipSDK.setInstanceId(UIDevice.current.identifierForVendor?.uuidString)
//        // 1 - FrontCamra 0 - BackCamra
//        portSipSDK.setVideoDeviceId(1)
//        
//        // enable video RTCP nack
//        portSipSDK.setVideoNackStatus(true)
//        
//        // enable srtp
//        portSipSDK.setSrtpPolicy(srtp)
//        
//        // Try to register the default identity. Registration refreshment interval is 90 seconds
//        let ret = portSipSDK.registerServer(90, retryTimes: 0)
//        print("ret: \(ret)")
//        if ret != 0 {
//            portSipSDK.unInitialize()
//            NSLog("registerServer failure ErrorCode = %d", ret)
//            return "registerServer failure ErrorCode = %d \(ret)"
//        }
//        
//        if transport == TRANSPORT_TCP ||
//            transport == TRANSPORT_TLS {
//            portSipSDK.setKeepAliveTime(0)
//        }
//        return "\(ret)"
//    }
//}
