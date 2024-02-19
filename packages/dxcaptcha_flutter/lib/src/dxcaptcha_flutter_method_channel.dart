import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dxcaptcha_flutter_platform_interface.dart';

/// An implementation of [DxCaptchaFlutterPlatform] that uses method channels.
class MethodChannelDxCaptchaFlutter extends DxCaptchaFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('plugins.kjxbyz.com/dxcaptcha_flutter_plugin');

  @override
  void setMethodCallHandler(FlutterPluginHandler handler) {
    methodChannel.setMethodCallHandler(handler);
  }

  @override
  Future<void> show(Map<String, dynamic> config) {
    return methodChannel.invokeMethod<void>('show', config);
  }
}
