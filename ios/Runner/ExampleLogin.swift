//import UIKit
//
//private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
//    switch (lhs, rhs) {
//    case let (l?, r?):
//        return l < r
//    case (nil, _?):
//        return true
//    default:
//        return false
//    }
//}
//enum LOGIN_STATUS:Int{
//    case LOGIN_STATUS_OFFLINE,
//         LOGIN_STATUS_LOGIN,
//         LOGIN_STATUS_ONLINE,
//         LOGIN_STATUS_FAILUE
//}
//
//class LoginViewController {
//    
//    private var portSIPSDK: PortSIPSDK!
//    
//    
//    var sipRegistrationStatus = LOGIN_STATUS.LOGIN_STATUS_OFFLINE
//    
//    init(portSIPSDK: PortSIPSDK!, sipRegistrationStatus: LOGIN_STATUS = LOGIN_STATUS.LOGIN_STATUS_OFFLINE) {
//        self.portSIPSDK = portSIPSDK
//        self.sipRegistrationStatus = sipRegistrationStatus
//    }
//    
//    
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
//        let retUser = portSIPSDK.setUser(username, displayName: displayName, authName: authName, password: password, userDomain: userDomain, sipServer: sipServer, sipServerPort: sipServerPort, stunServer: "", stunServerPort: 0, outboundServer: "", outboundServerPort: 0)
//        
//        if retUser != 0 {
//            NSLog("setUser failure ErrorCode = %d", retUser)
//            return "setUser failure ErrorCode = %d"
//        }
//    
//        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        appDelegate.addPushSupportWithPortPBX(true)
//        
//        portSIPSDK.setInstanceId(UIDevice.current.identifierForVendor?.uuidString)
//        // 1 - FrontCamra 0 - BackCamra
//        portSIPSDK.setVideoDeviceId(1)
//        
//        // enable video RTCP nack
//        portSIPSDK.setVideoNackStatus(true)
//        
//        // enable srtp
//        portSIPSDK.setSrtpPolicy(srtp)
//        
//        // Try to register the default identity. Registration refreshment interval is 90 seconds
//        let ret = portSIPSDK.registerServer(90, retryTimes: 0)
//        if ret != 0 {
//            portSIPSDK.unInitialize()
//            NSLog("registerServer failure ErrorCode = %d", ret)
//            return "registerServer failure ErrorCode = %d \(ret)"
//        }
//        
//        if transport == TRANSPORT_TCP ||
//            transport == TRANSPORT_TLS {
//            portSIPSDK.setKeepAliveTime(0)
//        }
//        return "\(ret)"
//    }
//}
