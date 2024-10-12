import Foundation
import PortSIPVoIPSDK

class VideoManager {
    private var mCameraDeviceId: Int = 1 // 1 - FrontCamra, 0 - BackCamra
    private var mLocalVideoWidth: Int = 352
    private var mLocalVideoHeight: Int = 288
    private var isStartVideo = false
    private var isInitVideo = false
    private var sessionId: Int = 0
    private var shareInSmallWindow = true

    private var portSIPSDK: PortSIPSDK!

    init(portSIPSDK: PortSIPSDK) {
        self.portSIPSDK = portSIPSDK
    }

    func startVideo(sessionID: Int) {
        isStartVideo = true
        sessionId = sessionID
        shareInSmallWindow = true
        checkDisplayVideo()
    }

    func stopVideo() {
        isStartVideo = false
        checkDisplayVideo()
    }

    func toggleSpeaker() -> String {
        let currentStatus = false
        let newStatus = !currentStatus
        portSIPSDK.setLoudspeakerStatus(newStatus)
        return newStatus ? "Headphone" : "Speaker"
    }

    func switchCamera() -> String {
        if mCameraDeviceId == 1 {
            if portSIPSDK.setVideoDeviceId(0) == 0 {
                mCameraDeviceId = 0
                return "FrontCamera"
            }
        } else {
            if portSIPSDK.setVideoDeviceId(1) == 0 {
                mCameraDeviceId = 1
                return "BackCamera"
            }
        }
        return mCameraDeviceId == 1 ? "BackCamera" : "FrontCamera"
    }

    func toggleVideoSending() -> String {
        if isStartVideo {
            portSIPSDK.sendVideo(sessionId, sendState: false)
            isStartVideo = false
            return "StartSending"
        } else {
            portSIPSDK.sendVideo(sessionId, sendState: true)
            isStartVideo = true
            return "PauseSending"
        }
    }

    func toggleConference(isConferenceActive: Bool) -> Bool {
        print("131231")
        if isConferenceActive {
            portSIPSDK.setConferenceVideoWindow(nil)
            portSIPSDK.setRemoteVideoWindow(sessionId, remoteVideoWindow: nil)
            return false
        } else {
            portSIPSDK.setConferenceVideoWindow(nil)
            portSIPSDK.setRemoteVideoWindow(sessionId, remoteVideoWindow: nil)
            return true
        }
    }

    private func checkDisplayVideo() {
        guard isInitVideo else { return }

        if isStartVideo {
            portSIPSDK.displayLocalVideo(true, mirror: mCameraDeviceId == 0, localVideoWindow: nil)
            portSIPSDK.sendVideo(sessionId, sendState: true)
        } else {
            portSIPSDK.displayLocalVideo(false, mirror: false, localVideoWindow: nil)
            portSIPSDK.setRemoteVideoWindow(sessionId, remoteVideoWindow: nil)
            portSIPSDK.setRemoteScreenWindow(sessionId, remoteScreenWindow: nil)
        }
    }

    func updateLocalVideoCaptureSize(width: Int, height: Int) {
        guard width > 0, height > 0 else { return }

        if mLocalVideoHeight != height || mLocalVideoWidth != width {
            mLocalVideoWidth = width
            mLocalVideoHeight = height
            print("Updated local video capture size: width=\(width), height=\(height)")
        }
    }
}
