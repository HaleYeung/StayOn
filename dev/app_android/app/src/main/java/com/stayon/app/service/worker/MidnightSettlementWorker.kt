package com.stayon.app.service.worker

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.stayon.app.StayOnApplication

class MidnightSettlementWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        val db = (applicationContext as StayOnApplication).database
        val today = java.time.LocalDate.now()
        val todayStart = today.atStartOfDay(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli()

        // Settle all pending events from yesterday to unconfirmed
        db.medicationEventDao().settlePendingBefore(todayStart)
        db.sleepEventDao().settlePendingBefore(today.toString())
        db.mealEventDao().settlePendingBefore(todayStart)

        return Result.success()
    }
}
