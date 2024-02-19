import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:dxcaptcha_flutter/src/dxcaptcha_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // MethodChannelDxCaptchaFlutter platform = MethodChannelDxCaptchaFlutter();
  const MethodChannel channel = MethodChannel('plugins.kjxbyz.com/dxcaptcha_flutter_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('show', () async {
    // TODO(kjxbyz): add tests
    // expect(await platform.show({}), '42');
  });
}
