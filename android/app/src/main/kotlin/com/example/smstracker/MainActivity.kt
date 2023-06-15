package com.example.smstracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Telephony
import android.telephony.SmsMessage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val smsReceiver = object : BroadcastReceiver(), EventChannel.StreamHandler {
            private var eventSink: EventChannel.EventSink? = null

            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }

            override fun onReceive(context: Context?, intent: Intent?) {
                val smsBundle = intent?.extras
                if (smsBundle != null) {
                    val pdus = smsBundle.get("pdus") as Array<*>
                    for (pdu in pdus) {
                        val smsMessage = SmsMessage.createFromPdu(pdu as ByteArray)
                        val senderNumber = smsMessage.originatingAddress
                        val messageBody = smsMessage.messageBody
                        val smsData = mapOf(
                            "senderNumber" to senderNumber,
                            "messageBody" to messageBody
                        )
                        eventSink?.success(smsData)
                    }
                }
            }
        }

        registerReceiver(smsReceiver, IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION))
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/smsStream")
            .setStreamHandler(smsReceiver)
    }
}
