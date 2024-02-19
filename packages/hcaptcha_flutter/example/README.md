# hcaptcha_flutter_example

![Pub Version](https://img.shields.io/pub/v/hcaptcha_flutter)

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
