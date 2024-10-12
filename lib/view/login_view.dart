import 'package:flutter/material.dart';
import 'package:port_sip_ios/controller/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final sipAddressController = TextEditingController();
  final serverPortController = TextEditingController();
  final domainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    LoginController.platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onRegisterSuccess':
          String statusText = call.arguments['statusText'];
          int statusCode = call.arguments['statusCode'];
          // Handle registration success (update UI, show message, etc.)
          debugPrint("Registration Success: $statusText, Code: $statusCode");
          break;

        case 'onRegisterFailure':
          String statusText = call.arguments['statusText'];
          int statusCode = call.arguments['statusCode'];
          // Handle registration failure (update UI, show message, etc.)
          debugPrint("Registration Failed: $statusText, Code: $statusCode");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // const Text(
              //   "Login to Port SIP",
              //   style: TextStyle(fontSize: 20),
              // ),
              // const SizedBox(height: 20),
              // TextField(
              //   controller: userNameController,
              //   decoration: const InputDecoration(
              //     labelText: 'Username',
              //   ),
              // ),
              // const SizedBox(height: 20),
              // TextField(
              //   controller: passwordController,
              //   decoration: const InputDecoration(
              //     labelText: 'Password',
              //   ),
              // ),
              // const SizedBox(height: 20),
              // TextField(
              //   controller: sipAddressController,
              //   decoration: const InputDecoration(
              //     labelText: 'SIP Address',
              //   ),
              // ),
              // const SizedBox(height: 20),
              // TextField(
              //   controller: serverPortController,
              //   decoration: const InputDecoration(
              //     labelText: 'Server Port',
              //   ),
              // ),
              // const SizedBox(height: 20),
              // TextField(
              //   controller: domainController,
              //   decoration: const InputDecoration(
              //     labelText: 'Domain',
              //   ),
              // ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final res = await LoginController().online(
                            username: '200011',
                            displayName: '200011',
                            authName: '',
                            password: "Test@1#\$",
                            userDomain: 'voice.omicx.vn',
                            sipServer: 'portsip.omicx.vn',
                            sipServerPort: 5060,
                            transportType: 0,
                            srtpType: 0);
                        print(res);
                      },
                      child: const Text(
                        "Online",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        LoginController().offline();
                      },
                      child: const Text(
                        "Offline",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
