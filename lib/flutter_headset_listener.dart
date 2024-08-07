import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'headset_state.dart';

class FlutterHeadsetListener {
  static const MethodChannel _channel =
      MethodChannel('flutter_headset_listener');

  final StreamController<HeadsetState> _controller =
      StreamController<HeadsetState>.broadcast();

  Stream<HeadsetState> get headsetStateStream => _controller.stream;

  Future<bool> getBTHeadsetIsConnected() async {
    return await _channel.invokeMethod('getBTHeadsetIsConnected');
  }

  Future<bool> getHeadsetIsPlugged() async {
    return await _channel.invokeMethod('getHeadsetIsPlugged');
  }

  Future<bool> requestPermission() async {
    if (Platform.isIOS) return true;

    return await Permission.bluetoothConnect.request().isGranted;
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
  }

  void dispose() {
    _controller.close();
  }
}
