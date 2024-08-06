import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'headset_state.dart';

class FlutterHeadsetListener {
  static const MethodChannel _channel =
      MethodChannel('flutter_headset_listener');
  static const EventChannel _eventChannel =
      EventChannel('flutter_headset_listener');

  final StreamController<HeadsetState> _controller =
      StreamController<HeadsetState>.broadcast();

  Stream<HeadsetState> get headsetStateStream => _controller.stream;

  void dispose() {
    _controller.close();
  }

  FlutterHeadsetListener() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onHeadsetPlug':
          _controller.add(HeadsetState.plugged);
          break;
        case 'onHeadsetUnPlug':
          _controller.add(HeadsetState.unPlugged);
          break;
        case 'onBTHeadsetConnect':
          _controller.add(HeadsetState.btConnected);
          break;
        case 'onBTHeadsetDisconnect':
          _controller.add(HeadsetState.btDisconnected);
          break;
      }
    });

    _eventChannel.receiveBroadcastStream().listen((event) {
      debugPrint("receiveBroadcastStream: $event");
      switch (event) {
        case 'onHeadsetPlug':
          _controller.add(HeadsetState.plugged);
          break;
        case 'onHeadsetUnPlug':
          _controller.add(HeadsetState.unPlugged);
          break;
        case 'onBTHeadsetConnect':
          _controller.add(HeadsetState.btConnected);
          break;
        case 'onBTHeadsetDisconnect':
          _controller.add(HeadsetState.btDisconnected);
          break;
      }
    });
  }
}
