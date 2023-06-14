import 'package:flutter/services.dart';

class PlatformChannel {
  static const _channel = EventChannel("com.example.app/smsStream");

  Stream smsStream() async* {
    yield* _channel.receiveBroadcastStream();
  }
}
