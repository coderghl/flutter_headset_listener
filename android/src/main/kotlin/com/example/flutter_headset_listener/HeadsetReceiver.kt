package com.example.flutter_headset_listener

import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/// HeadSet Unplug and plug receiver
class HeadsetReceiver(private val listener: (HeadsetState) -> Unit) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_HEADSET_PLUG -> {
                when (intent.getIntExtra("state", 0)) {
                    1 -> listener(HeadsetState.Plugged)
                    0 -> listener(HeadsetState.Unplugged)
                }
            }
            BluetoothDevice.ACTION_ACL_CONNECTED -> {
                listener(HeadsetState.BTConnected)
            }
            BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                listener(HeadsetState.BTDisconnected)
            }
        }
    }
}
