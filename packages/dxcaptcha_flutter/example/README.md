# dxcaptcha_flutter_example

![Pub Version](https://img.shields.io/pub/v/dxcaptcha_flutter)

## Getting Started

```dart
DxCaptchaFlutter.setMethodCallHandler((MethodCall call) async {
  if (call.method == 'success' && call.arguments != null) {
    final res = call.arguments as Map<dynamic, dynamic>;
    final dxToken = res['token'] as String?;
  } else if (call.method == 'error') {
    
  }
});
```

```dart
await DxCaptchaFlutter.show({
  'appId': '26ba29b6a3744dbebee8e46fbe3f311a',
  'language': 'en',
});
```
