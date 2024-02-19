import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hcaptcha_flutter_platform_interface.dart';

/// An implementation of [HCaptchaFlutterPlatform] that uses method channels.
class MethodChannelHCaptchaFlutter extends HCaptchaFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('plugins.kjxbyz.com/hcaptcha_flutter_plugin');

  @override
  void setMethodCallHandler(FlutterPluginHandler handler) {
    methodChannel.setMethodCallHandler(handler);
  }

  @override
  Future<void> show(Map<String, dynamic> config) {
    return methodChannel.invokeMethod<void>('show', config);
  }
}
