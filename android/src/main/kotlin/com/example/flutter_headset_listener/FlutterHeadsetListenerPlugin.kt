package com.example.flutter_headset_listener

import android.bluetooth.BluetoothDevice
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class FlutterHeadsetListenerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var headsetReceiver: HeadsetReceiver

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_headset_listener")
    channel.setMethodCallHandler(this)

    // Initialize headset receiver
    headsetReceiver = HeadsetReceiver { headsetState ->
      when (headsetState) {
        is HeadsetState.Plugged -> channel.invokeMethod("onHeadsetPlug", null)
        is HeadsetState.Unplugged -> channel.invokeMethod("onHeadsetUnPlug", null)
        is HeadsetState.BTConnected -> channel.invokeMethod("onBTHeadsetConnect", null)
        is HeadsetState.BTDisconnected -> channel.invokeMethod("onBTHeadsetDisconnect", null)
      }
    }

    // Register receiver for headset and Bluetooth events
    val filter = IntentFilter().apply {
      addAction(Intent.ACTION_HEADSET_PLUG)
      addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
      addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
    }
    flutterPluginBinding.applicationContext.registerReceiver(headsetReceiver, filter)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    // Handle method calls from Flutter if needed

  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    // Unregister receiver
    binding.applicationContext.unregisterReceiver(headsetReceiver)
  }
}