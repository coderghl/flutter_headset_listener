package com.example.flutter_headset_listener

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class FlutterHeadsetListenerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var binding : FlutterPlugin.FlutterPluginBinding
    private lateinit var headsetReceiver: HeadsetReceiver

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_headset_listener")
        channel.setMethodCallHandler(this)

        binding = flutterPluginBinding

        headsetReceiver = HeadsetReceiver { headsetState ->
            when (headsetState) {
                is HeadsetState.Plugged -> channel.invokeMethod("onHeadsetPlug", null)
                is HeadsetState.Unplugged -> channel.invokeMethod("onHeadsetUnPlug", null)
                is HeadsetState.BTConnected -> channel.invokeMethod("onBTHeadsetConnect", null)
                is HeadsetState.BTDisconnected -> channel.invokeMethod("onBTHeadsetDisconnect", null)
            }
        }

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_HEADSET_PLUG)
            addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        }

        flutterPluginBinding.applicationContext.registerReceiver(headsetReceiver, filter)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "getBTHeadsetIsConnected" -> {
                val isBluetoothHeadsetOn = isBluetoothHeadsetOn()
                result.success(isBluetoothHeadsetOn)
            }

            "getHeadsetIsPlugged" -> {
                val wiredHeadsetOn = isWiredHeadsetOn()
                result.success(wiredHeadsetOn)
            }

            else -> {}
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        binding.applicationContext.unregisterReceiver(headsetReceiver)
    }

    private fun isWiredHeadsetOn(): Boolean {
        val audioManager = binding.applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return audioManager.isWiredHeadsetOn
    }

    private fun isBluetoothHeadsetOn(): Boolean {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        return bluetoothAdapter != null && bluetoothAdapter.getProfileConnectionState(
            BluetoothProfile.A2DP
        ) == BluetoothProfile.STATE_CONNECTED
    }

}