import 'dxcaptcha_flutter_platform_interface.dart';

class DxCaptchaFlutter {
  static void setMethodCallHandler(FlutterPluginHandler handler) {
    return DxCaptchaFlutterPlatform.instance.setMethodCallHandler(handler);
  }

  static Future<void> show(Map<String, dynamic> config) {
    return DxCaptchaFlutterPlatform.instance.show(config);
  }
}
