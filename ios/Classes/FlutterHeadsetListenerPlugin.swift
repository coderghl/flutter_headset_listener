import Flutter
import UIKit
import AVFoundation

public class FlutterHeadsetListenerPlugin: NSObject, FlutterPlugin {
    private var eventSink: FlutterEventSink?
    private var lastHeadphonesConnected: Bool = false
    private var lastBluetoothConnected: Bool = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterHeadsetListenerPlugin()
        let eventChannel = FlutterEventChannel(name: "flutter_headset_listener", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle method calls here if needed
    }
}

extension FlutterHeadsetListenerPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(notification:)), name: AVAudioSession.routeChangeNotification, object: nil)
        checkHeadsetStatus()
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        return nil
    }

    @objc private func handleRouteChange(notification: Notification) {
        checkHeadsetStatus()
    }

    private func checkHeadsetStatus() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            print("Failed to activate audio session.")
        }

        let currentRoute = audioSession.currentRoute
        var isHeadphonesConnected = false
        var isBluetoothConnected = false

        for output in currentRoute.outputs {
            if output.portType == .bluetoothA2DP || output.portType == .bluetoothLE || output.portType == .bluetoothHFP {
                isBluetoothConnected = true
            }
        }

        if isBluetoothConnected {
            eventSink?("onBTHeadsetConnect")
        } else {
            eventSink?("onBTHeadsetDisconnect")
        }
    }
}
