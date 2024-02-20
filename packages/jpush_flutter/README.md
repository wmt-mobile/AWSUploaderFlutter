# JPush Flutter

[![Pub Version](https://img.shields.io/pub/v/jpush_flutter2)](https://pub.dev/packages/jpush_flutter2)

## Getting Started

```dart
JPushFlutter.setDebugMode(debugMode: true);
JPushFlutter.init('', 'developer-default');

JPushFlutter.setMethodCallHandler((call) async {
  if (call.method == 'notificationClick') {
    if (kDebugMode) {
      print('setMethodCallHandler: ${call.arguments}');
    }
  }
});
```
