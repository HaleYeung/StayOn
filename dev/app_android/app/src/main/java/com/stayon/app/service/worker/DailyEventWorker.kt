package com.stayon.app.service.worker

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.stayon.app.StayOnApplication
import com.stayon.app.data.local.EventGenerator

class DailyEventWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        val db = (applicationContext as StayOnApplication).database
        EventGenerator.generateFromPlans(db)
        return Result.success()
    }
}
