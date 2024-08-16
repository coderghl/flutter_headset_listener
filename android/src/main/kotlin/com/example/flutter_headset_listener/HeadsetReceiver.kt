package com.example.flutter_headset_listener

import android.bluetooth.BluetoothAdapter
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
            BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED -> {
                when (intent.extras?.getInt(BluetoothAdapter.EXTRA_CONNECTION_STATE)) {
                    BluetoothAdapter.STATE_CONNECTED -> {
                        listener(HeadsetState.BTConnected)
                    }

                    BluetoothAdapter.STATE_DISCONNECTED -> {
                        listener(HeadsetState.BTDisconnected)
                    }
                }
            }
            BluetoothAdapter.ACTION_STATE_CHANGED -> {
                if (intent.extras?.getInt(BluetoothAdapter.EXTRA_STATE) == BluetoothAdapter.STATE_OFF) {
                    listener(HeadsetState.BTDisconnected)
                }
            }
        }
    }
}