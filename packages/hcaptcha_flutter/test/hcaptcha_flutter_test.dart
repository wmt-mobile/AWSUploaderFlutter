import 'package:flutter_test/flutter_test.dart';
// import 'package:hcaptcha_flutter/src/hcaptcha_flutter.dart';
import 'package:hcaptcha_flutter/src/hcaptcha_flutter_platform_interface.dart';
import 'package:hcaptcha_flutter/src/hcaptcha_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHCaptchaFlutterPlatform
    with MockPlatformInterfaceMixin
    implements HCaptchaFlutterPlatform {

  @override
  void setMethodCallHandler(FlutterPluginHandler handler) {
    // TODO: implement setMethodCallHandler
  }

  @override
  Future<void> show(Map<String, dynamic> config) => Future.value();
}

void main() {
  final HCaptchaFlutterPlatform initialPlatform = HCaptchaFlutterPlatform.instance;

  test('$MethodChannelHCaptchaFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHCaptchaFlutter>());
  });

  test('show', () async {
    MockHCaptchaFlutterPlatform fakePlatform = MockHCaptchaFlutterPlatform();
    HCaptchaFlutterPlatform.instance = fakePlatform;

    // TODO(kjxbyz): add tests
    // expect(await HCaptchaFlutter.show({}), '42');
  });
}
