import 'hcaptcha_flutter_platform_interface.dart';

class HCaptchaFlutter {
  static void setMethodCallHandler(FlutterPluginHandler handler) {
    return HCaptchaFlutterPlatform.instance.setMethodCallHandler(handler);
  }

  static Future<void> show(Map<String, dynamic> config) {
    return HCaptchaFlutterPlatform.instance.show(config);
  }
}
