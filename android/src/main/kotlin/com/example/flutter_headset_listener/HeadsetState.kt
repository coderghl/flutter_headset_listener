package com.example.flutter_headset_listener


sealed class HeadsetState {
    object Plugged : HeadsetState()
    object Unplugged : HeadsetState()
    object BTConnected : HeadsetState()
    object BTDisconnected : HeadsetState()
}