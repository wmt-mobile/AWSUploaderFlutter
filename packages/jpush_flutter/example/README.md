# jpush_flutter_example

[![Pub Version](https://img.shields.io/pub/v/hcaptcha_flutter)](https://pub.dev/packages/hcaptcha_flutter)

Demonstrates how to use the jpush_flutter plugin.

Android点击通知打开:

`intent:#Intent;action=com.kjxbyz.plugins.jpush_flutter_example/com.kjxbyz.plugins.jpush.OpenClickActivity;component=com.kjxbyz.plugins.jpush_flutter_example/com.kjxbyz.plugins.jpush.OpenClickActivity;end`



## Getting Started

```dart
HCaptchaFlutter.setMethodCallHandler((MethodCall call) async {
  if (kDebugMode) {
    print('method: ${call.method}, arguments: ${call.arguments}');
  }

  if (call.method == 'success' && call.arguments != null) {
    final res = call.arguments as Map<dynamic, dynamic>;
    final token = res['token'] as String?;
  }
});
```

```dart
await HCaptchaFlutter.show({
  'siteKey': 'your site key',
  'language': 'en',
});
```
