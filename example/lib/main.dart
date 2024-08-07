import 'package:flutter/material.dart';
import 'package:flutter_headset_listener/flutter_headset_listener.dart';
import 'package:flutter_headset_listener/headset_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeApp(),
    );
  }
}

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  bool btHeadsetIsConnect = false;
  bool headsetIsConnect = false;

  var flutterHeadsetListener = FlutterHeadsetListener();
  void init() async {
    await flutterHeadsetListener.requestPermission();

    btHeadsetIsConnect = await flutterHeadsetListener.getBTHeadsetIsConnected();

    flutterHeadsetListener.headsetStateStream.listen((event) {
      debugPrint(event.toString());
      if (event == HeadsetState.btConnected) {
        setState(() {
          btHeadsetIsConnect = true;
        });
      }

      if (event == HeadsetState.btDisconnected) {
        setState(() {
          btHeadsetIsConnect = false;
        });
      }

      if (event == HeadsetState.plugged) {
        setState(() {
          headsetIsConnect = true;
        });
      }

      if (event == HeadsetState.unPlugged) {
        setState(() {
          headsetIsConnect = false;
        });
      }
    });
    setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("BTHeadsetConnect: $btHeadsetIsConnect"),
            Text("headsetIsConnect: $headsetIsConnect"),
          ],
        ),
      ),
    );
  }
}
