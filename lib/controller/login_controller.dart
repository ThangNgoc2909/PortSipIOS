import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginController {
  static const platform = MethodChannel('port_sip');

  LoginController._();

  static final LoginController _instance = LoginController._();

  factory LoginController() {
    return _instance;
  }

  Future<String> online({
    required String username,
    required String displayName,
    required String authName,
    required String password,
    required String userDomain,
    required String sipServer,
    required int sipServerPort,
    required int transportType,
    required int srtpType,
  }) async {
    try {
      final String result = await platform.invokeMethod(
        'Login',
        {
          'username': username,
          'displayName': displayName,
          'authName': authName,
          'password': password,
          'userDomain': userDomain,
          'sipServer': sipServer,
          'sipServerPort': sipServerPort,
          'transportType': transportType,
          'srtpType': srtpType,
        },
      );
      return result;
    } on PlatformException catch (e) {
      return "Failed to call onLine: '${e.message}'.";
    }
  }

  Future<void> offline() async {
    try {
      await platform.invokeMethod('Offline');
    } on PlatformException catch (e) {
      debugPrint("Failed to call onLine: '${e.message}'.");
    }
  }
}
