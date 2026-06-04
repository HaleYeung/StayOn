package com.stayon.app

import android.app.Application
import android.util.Log
import com.stayon.app.data.local.AppDatabase

class StayOnApplication : Application() {

    lateinit var database: AppDatabase
        private set

    override fun onCreate() {
        super.onCreate()
        try {
            database = AppDatabase.getInstance(this)
            Log.d("StayOn", "Database initialized")
        } catch (e: Exception) {
            Log.e("StayOn", "Database init failed", e)
        }
    }
}
