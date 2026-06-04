package com.stayon.app.service.notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import com.stayon.app.R

object NotificationHelper {
    const val CHANNEL_MEDICATION = "medication"
    const val CHANNEL_SLEEP = "sleep"
    const val CHANNEL_MEAL = "meal"
    const val CHANNEL_NIGHT_SNACK = "night_snack"

    fun createNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channels = listOf(
                NotificationChannel(
                    CHANNEL_MEDICATION, "药物提醒",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply { description = "服药提醒与确认" },
                NotificationChannel(
                    CHANNEL_SLEEP, "睡觉提醒",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply { description = "睡前预提醒与到点提醒" },
                NotificationChannel(
                    CHANNEL_MEAL, "饮食提醒",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply { description = "餐前注意事项提醒" },
                NotificationChannel(
                    CHANNEL_NIGHT_SNACK, "夜宵提醒",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply { description = "夜宵控制提醒" }
            )

            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            channels.forEach { manager.createNotificationChannel(it) }
        }
    }
}
