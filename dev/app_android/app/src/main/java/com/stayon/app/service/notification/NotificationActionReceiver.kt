package com.stayon.app.service.notification

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.stayon.app.R

class NotificationActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: return
        val body = intent.getStringExtra("body") ?: ""
        val category = intent.getStringExtra("category") ?: "medication"
        val actionType = intent.getStringExtra("actionType")
        val eventId = intent.getStringExtra("eventId")

        val notificationId = when (category) {
            "medication" -> 1000
            "sleep" -> 2000
            "meal" -> 3000
            "night_snack" -> 4000
            else -> 5000
        }.let { it + (eventId?.hashCode() ?: 0) }

        val channelId = when (category) {
            "medication" -> NotificationHelper.CHANNEL_MEDICATION
            "sleep" -> NotificationHelper.CHANNEL_SLEEP
            "meal" -> NotificationHelper.CHANNEL_MEAL
            "night_snack" -> NotificationHelper.CHANNEL_NIGHT_SNACK
            else -> NotificationHelper.CHANNEL_MEDICATION
        }

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)

        // Add action buttons based on category
        when (category) {
            "medication" -> {
                builder.addAction(0, "已吃", createActionIntent(context, "DONE", eventId))
                builder.addAction(0, "稍后提醒", createActionIntent(context, "SNOOZE", eventId))
                builder.addAction(0, "跳过", createActionIntent(context, "SKIP", eventId))
            }
            "sleep" -> {
                builder.addAction(0, "晚安", createActionIntent(context, "GOOD_NIGHT", eventId))
                builder.addAction(0, "稍后提醒", createActionIntent(context, "SNOOZE", eventId))
            }
            "meal" -> {
                // No action buttons per PRD - just opens app
            }
            "night_snack" -> {
                // No action buttons per PRD - just opens app
            }
        }

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId, builder.build())
    }

    private fun createActionIntent(context: Context, action: String, eventId: String?): PendingIntent {
        val intent = Intent(context, javaClass).apply {
            putExtra("action", action)
            putExtra("eventId", eventId)
        }
        return PendingIntent.getBroadcast(
            context,
            action.hashCode() + (eventId?.hashCode() ?: 0),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
