import 'package:flutter_test/flutter_test.dart';
// import 'package:dxcaptcha_flutter/src/dxcaptcha_flutter.dart';
import 'package:dxcaptcha_flutter/src/dxcaptcha_flutter_method_channel.dart';
import 'package:dxcaptcha_flutter/src/dxcaptcha_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDxCaptchaFlutterPlatform
    with MockPlatformInterfaceMixin
    implements DxCaptchaFlutterPlatform {
  @override
  void setMethodCallHandler(FlutterPluginHandler handler) {
    // TODO: implement setMethodCallHandler
  }

  @override
  Future<void> show(Map<String, dynamic> config) => Future.value();
}

void main() {
  final DxCaptchaFlutterPlatform initialPlatform =
      DxCaptchaFlutterPlatform.instance;

  test('$MethodChannelDxCaptchaFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDxCaptchaFlutter>());
  });

  test('show', () async {
    MockDxCaptchaFlutterPlatform fakePlatform = MockDxCaptchaFlutterPlatform();
    DxCaptchaFlutterPlatform.instance = fakePlatform;

    // TODO(kjxbyz): add tests
    // expect(await DxCaptchaFlutter.show({});, '42');
  });
}
