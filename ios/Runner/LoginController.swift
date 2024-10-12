import UIKit

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

enum LOGIN_STATUS: Int {
    case LOGIN_STATUS_OFFLINE,
         LOGIN_STATUS_LOGIN,
         LOGIN_STATUS_ONLINE,
         LOGIN_STATUS_FAILUE
}

class LoginViewController {
    
    private var portSIPSDK: PortSIPSDK!
    private var sipInitialized = false
    var sipRegistrationStatus = LOGIN_STATUS.LOGIN_STATUS_OFFLINE
    
    var autoRegisterRetryTimes: Int = 0
    var autoRegisterTimer: Timer?
    var srtpItems: [String] = ["NONE", "FORCE", "PREFER"]
    var transPortItems: [String] = ["UDP", "TLS", "TCP"]
        
    init(portSIPSDK: PortSIPSDK!) {
        self.portSIPSDK = portSIPSDK
        self.sipInitialized = false
        self.sipRegistrationStatus = LOGIN_STATUS.LOGIN_STATUS_OFFLINE
        self.autoRegisterRetryTimes = 0
    }
    
    
    func onLine(username: String, displayName: String, authName: String, password: String, userDomain: String, sipServer: String, sipServerPort: Int32, transportType: Int, srtpType: Int)  {
        
        if sipInitialized {
            print("You already registered, go offline first!")
            return
        }
        
        var transport = TRANSPORT_UDP
//        switch userData["transport"] {
//        case "UDP":
//            transport = TRANSPORT_UDP
//        case "TLS":
//            transport = TRANSPORT_TLS
//        case "TCP":
//            transport = TRANSPORT_TCP
//        default:
//            break
//        }
        
        var srtp = SRTP_POLICY_NONE
//        switch userData["srtp"] {
//        case "FORCE":
//            srtp = SRTP_POLICY_FORCE
//        case "PREFER":
//            srtp = SRTP_POLICY_PREFER
//        default:
//            srtp = SRTP_POLICY_NONE
//        }
        
        let localPort = 10002
        let loaclIPaddress = "0.0.0.0"
        
        let ret = portSIPSDK.initialize(transport, localIP: loaclIPaddress, localSIPPort: Int32(localPort), loglevel: PORTSIP_LOG_NONE, logPath: "", maxLine: 8, agent: "PortSIP SDK for IOS", audioDeviceLayer: 0, videoDeviceLayer: 0, tlsCertificatesRootPath: "", tlsCipherList: "", verifyTLSCertificate: false, dnsServers: "")
        
        if ret != 0 {
            print("Initialize failure ErrorCode = \(ret)")
            return
        }
        let retUser = portSIPSDK.setUser(username, displayName: displayName, authName: authName, password: password, userDomain: userDomain, sipServer: sipServer, sipServerPort: sipServerPort, stunServer: "", stunServerPort: 0, outboundServer: "", outboundServerPort: 0)
        
        if retUser != 0 {
            print("Set user failure ErrorCode = \(retUser)")
            return
        }
        
        sipInitialized = true
        sipRegistrationStatus = LOGIN_STATUS.LOGIN_STATUS_LOGIN
        
        portSIPSDK.registerServer(90, retryTimes: 0)
        print("Registration initiated...")
    }
    
    func offLine() {
        if sipInitialized {
            portSIPSDK.unRegisterServer(90)
            portSIPSDK.unInitialize()
            sipInitialized = false
            sipRegistrationStatus = LOGIN_STATUS.LOGIN_STATUS_OFFLINE
        }
        print("Offline and Unregistered")
    }
    
    func refreshRegister() {
        switch sipRegistrationStatus {
        case .LOGIN_STATUS_OFFLINE:
            break
        case .LOGIN_STATUS_LOGIN:
            break
        case .LOGIN_STATUS_ONLINE:
            portSIPSDK.refreshRegistration(0)
            print("Refresh Registration...")
        case .LOGIN_STATUS_FAILUE:
            portSIPSDK.unRegisterServer(90)
            portSIPSDK.unInitialize()
            sipInitialized = false
        }
    }
    
    func unRegister() {
        if sipRegistrationStatus == .LOGIN_STATUS_LOGIN || sipRegistrationStatus == .LOGIN_STATUS_ONLINE {
            portSIPSDK.unRegisterServer(90)
            print("Unregistered when in background")
            sipRegistrationStatus = .LOGIN_STATUS_FAILUE
        }
    }
    
    func onRegisterSuccess(statusText: String) {
        print("Registration success: \(statusText)")
        sipRegistrationStatus = .LOGIN_STATUS_ONLINE
        autoRegisterRetryTimes = 0
    }
    
    func onRegisterFailure(statusCode: CInt, statusText: String) {
        print("Registration failure: \(statusText)")
        
        sipRegistrationStatus = .LOGIN_STATUS_FAILUE
        
        if statusCode != 401, statusCode != 403, statusCode != 404 {
            var interval = TimeInterval(autoRegisterRetryTimes * 2 + 1)
            interval = min(interval, 60)
            autoRegisterRetryTimes += 1
            
        }
    }
}
