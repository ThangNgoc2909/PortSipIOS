import 'package:flutter/material.dart';
import 'package:port_sip_ios/video_view_controller.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  final VideoViewController _videoViewController = VideoViewController();
  final int _sessionId = 896337694374756352;
  bool _isSpeakerOn = false;
  bool _isVideoSending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Port SIP Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Session ID: $_sessionId'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _videoViewController.startVideo(_sessionId),
              child: const Text('Start Video'),
            ),
            ElevatedButton(
              onPressed: () => _videoViewController.stopVideo(_sessionId),
              child: const Text('Stop Video'),
            ),
            ElevatedButton(
              onPressed: () {
                _isSpeakerOn = !_isSpeakerOn;
                _videoViewController.toggleSpeaker(_isSpeakerOn);
              },
              child:
                  Text(_isSpeakerOn ? 'Turn Off Speaker' : 'Turn On Speaker'),
            ),
            ElevatedButton(
              onPressed: () => _videoViewController.switchCamera(0),
              // 0 for back, 1 for front
              child: const Text('Switch to Back Camera'),
            ),
            ElevatedButton(
              onPressed: () {
                _isVideoSending = !_isVideoSending;
                _videoViewController.toggleVideoSending(
                    _sessionId, _isVideoSending);
              },
              child: Text(_isVideoSending
                  ? 'Pause Sending Video'
                  : 'Start Sending Video'),
            ),
            ElevatedButton(
              onPressed: () => _videoViewController.toggleConference(true),
              child: const Text('Start Conference'),
            ),
          ],
        ),
      ),
    );
  }
}
