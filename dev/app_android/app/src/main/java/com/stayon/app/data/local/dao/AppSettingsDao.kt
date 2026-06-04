package com.stayon.app.data.local.dao

import androidx.room.*
import com.stayon.app.data.local.entity.AppSettingsEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface AppSettingsDao {
    @Query("SELECT * FROM app_settings LIMIT 1")
    fun getSettings(): Flow<AppSettingsEntity?>

    @Query("SELECT * FROM app_settings LIMIT 1")
    suspend fun getSettingsOnce(): AppSettingsEntity?

    @Upsert
    suspend fun upsert(settings: AppSettingsEntity)
}
