package com.kangleiinovations.careitsafe

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Only create the notification channel on Android Oreo (API 26) and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "my_foreground",  // Channel ID used in Dart for the background service
                "Safe Mode",  // Name displayed to the user
                NotificationManager.IMPORTANCE_DEFAULT  // Importance level of notifications
            )
            channel.description = "This channel is used for background syncing notifications."

            // Register the channel with the system
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
}
