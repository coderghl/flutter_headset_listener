import Flutter
import UIKit
import AVFoundation
import NotificationCenter

public class FlutterHeadsetListenerPlugin: NSObject, FlutterPlugin {
    private var channel : FlutterMethodChannel?

    public override init(){
        super.init()
        initHeadsetReceiver()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_headset_listener", binaryMessenger: registrar.messenger())
        let instance = FlutterHeadsetListenerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.channel = channel
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getBTHeadsetIsConnected":
            result(getBTHeadsetIsConnected())
        case "getHeadsetIsPlugged":
            result(getHeadsetIsPlugged())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func initHeadsetReceiver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        updateBluetoothHeadsetConnection()
    }


    func getBTHeadsetIsConnected() -> Bool {
        let session = AVAudioSession.sharedInstance()
        let outputs = session.currentRoute.outputs
        
        for output in outputs {
            if output.portType == AVAudioSession.Port.bluetoothA2DP || output.portType == AVAudioSession.Port.bluetoothHFP {
                return true
            }
        }
        
        return false
    }

    func getHeadsetIsPlugged() -> Bool {
        let session = AVAudioSession.sharedInstance()
        let outputs = session.currentRoute.outputs
        
        for output in outputs {
            if output.portType == AVAudioSession.Port.headphones {
                return true
            }
        }
        
        return false
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        switch reason {
        case .newDeviceAvailable, .oldDeviceUnavailable, .routeConfigurationChange:
            updateBluetoothHeadsetConnection()
            updateWiredHeadsetConnection()
        default:
            break
        }
    }
    
    // BT HEADSET
    private func updateBluetoothHeadsetConnection() {
        let session = AVAudioSession.sharedInstance()
        let outputs = session.currentRoute.outputs
        var isConnected = false
        
        for output in outputs {
            if output.portType == AVAudioSession.Port.bluetoothA2DP || output.portType == AVAudioSession.Port.bluetoothHFP {
                isConnected = true
                break
            }
        }
        if(isConnected){
            channel?.invokeMethod("onBTHeadsetConnect", arguments: isConnected)
        }else{
            channel?.invokeMethod("onBTHeadsetDisconnect", arguments: isConnected)
        }
        
    }

    // Headset
    private func updateWiredHeadsetConnection() {
        let session = AVAudioSession.sharedInstance()
        let outputs = session.currentRoute.outputs
        var isPlugged = false
        
        for output in outputs {
            if output.portType == AVAudioSession.Port.headphones {
                isPlugged = true
                break
            }
        }
        
        if(isPlugged){
            channel?.invokeMethod("onHeadsetPlug", arguments: isPlugged)
        }else{
            channel?.invokeMethod("onHeadsetUnPlug", arguments: isPlugged)
        }
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}