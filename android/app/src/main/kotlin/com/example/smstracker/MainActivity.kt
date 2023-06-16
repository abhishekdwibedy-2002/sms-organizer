package com.example.smstracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Telephony
import android.telephony.SmsMessage
import android.provider.ContactsContract
import android.net.Uri
import android.util.Log
import android.database.Cursor
import android.provider.ContactsContract.PhoneLookup
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
                        val senderName = getContactName(context, senderNumber)
                        val messageBody = smsMessage.messageBody
                        val smsData = mapOf(
                            "senderName" to senderName,
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
    
    private fun getContactName(context: Context?, phoneNumber: String?): String {
        if (phoneNumber.isNullOrEmpty()) {
        return ""
    }
        val uri = Uri.withAppendedPath(ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phoneNumber))
        val projection = arrayOf(PhoneLookup.DISPLAY_NAME)

        var contactName = ""
        val cursor: Cursor? = context?.contentResolver?.query(uri, projection, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                contactName = it.getString(it.getColumnIndex(PhoneLookup.DISPLAY_NAME))
            }
        }

        // If contactName is empty, return the phoneNumber
        if (contactName.isEmpty()) {
            return phoneNumber
        }

        return contactName
    }

}
