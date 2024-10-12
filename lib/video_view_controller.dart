import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:port_sip_ios/constants.dart';

class VideoViewController {
  static const MethodChannel _channel = MethodChannel('port_sip');

  Future<void> startVideo(int sessionId) async {
    try {
      await _channel.invokeMethod(Constants.startVideo, {Constants.sessionID: sessionId});
    } on PlatformException catch (e) {
      debugPrint("Failed to start video: '${e.message}'.");
    }
  }

  Future<void> stopVideo(int sessionId) async {
    try {
      await _channel.invokeMethod(Constants.stopVideo, {Constants.sessionID: sessionId});
    } on PlatformException catch (e) {
      debugPrint("Failed to stop video: '${e.message}'.");
    }
  }

  Future<void> toggleSpeaker(bool isSpeakerOn) async {
    try {
      await _channel.invokeMethod(Constants.toggleSpeaker, {Constants.newStatus: isSpeakerOn});
    } on PlatformException catch (e) {
      debugPrint("Failed to toggle speaker: '${e.message}'.");
    }
  }

  Future<void> switchCamera(int cameraId) async {
    try {
      await _channel.invokeMethod(Constants.switchCamera, {Constants.newCamera: cameraId});
    } on PlatformException catch (e) {
      debugPrint("Failed to switch camera: '${e.message}'.");
    }
  }

  Future<void> toggleVideoSending(int sessionId, bool isSending) async {
    try {
      await _channel.invokeMethod(Constants.toggleVideoSending, {
        Constants.sessionID: sessionId,
        Constants.newStatus: isSending
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint("Failed to toggle video sending: '${e.message}'.");
      }
    }
  }

  Future<void> toggleConference(bool isActive) async {
    try {
      await _channel.invokeMethod(Constants.toggleConference, {Constants.isConferenceActive: isActive});
    } on PlatformException catch (e) {
      debugPrint("Failed to toggle conference: '${e.message}'.");
    }
  }
}
