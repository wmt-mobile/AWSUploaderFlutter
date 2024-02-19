import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hcaptcha_flutter/hcaptcha_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HCaptcha Plugin'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () async {
              HCaptchaFlutter.setMethodCallHandler((MethodCall call) async {
                if (kDebugMode) {
                  print('method: ${call.method}, arguments: ${call.arguments}');
                }

                if (call.method == 'success' && call.arguments != null) {
                  final res = call.arguments as Map<dynamic, dynamic>;
                  final token = res['token'] as String?;
                  log('token: $token');
                }
              });
              await HCaptchaFlutter.show({
                'siteKey': 'a5f74b19-9e45-40e0-b45d-47ff91b7a6c2',
                'language': 'en',
              });
            },
            child: const Text('Show Captcha'),
          ),
        ),
      ),
    );
  }
}
