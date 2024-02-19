import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dxcaptcha_flutter_method_channel.dart';

typedef FlutterPluginHandler = Future<dynamic> Function(MethodCall call);

abstract class DxCaptchaFlutterPlatform extends PlatformInterface {
  /// Constructs a DxCaptchaFlutterPlatform.
  DxCaptchaFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static DxCaptchaFlutterPlatform _instance = MethodChannelDxCaptchaFlutter();

  /// The default instance of [DxCaptchaFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelDxCaptchaFlutter].
  static DxCaptchaFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DxCaptchaFlutterPlatform] when
  /// they register themselves.
  static set instance(DxCaptchaFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void setMethodCallHandler(FlutterPluginHandler handler);

  Future<void> show(Map<String, dynamic> config);
}
