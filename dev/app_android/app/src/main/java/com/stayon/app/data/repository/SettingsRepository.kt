package com.stayon.app.data.repository

import com.stayon.app.data.local.AppDatabase
import com.stayon.app.data.local.toDomain
import com.stayon.app.data.local.toEntity
import com.stayon.app.domain.model.AppSettings
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class SettingsRepository(private val db: AppDatabase) {

    fun getSettings(): Flow<AppSettings?> =
        db.appSettingsDao().getSettings().map { it?.toDomain() }

    suspend fun getSettingsOnce(): AppSettings? =
        db.appSettingsDao().getSettingsOnce()?.toDomain()

    suspend fun saveSettings(settings: AppSettings) {
        db.appSettingsDao().upsert(settings.toEntity())
    }

    suspend fun ensureSettingsExists() {
        if (getSettingsOnce() == null) {
            saveSettings(AppSettings())
        }
    }
}
