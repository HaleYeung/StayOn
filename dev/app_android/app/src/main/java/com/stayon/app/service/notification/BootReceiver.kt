package com.stayon.app.service.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.stayon.app.service.worker.DailyEventWorker

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Rebuild daily schedule after reboot
            val workRequest = OneTimeWorkRequestBuilder<DailyEventWorker>()
                .addTag("boot_rebuild")
                .build()

            WorkManager.getInstance(context).enqueueUniqueWork(
                "boot_rebuild",
                ExistingWorkPolicy.REPLACE,
                workRequest
            )
        }
    }
}
