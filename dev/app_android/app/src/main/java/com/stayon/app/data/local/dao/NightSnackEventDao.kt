package com.stayon.app.data.local.dao

import androidx.room.*
import com.stayon.app.data.local.entity.NightSnackEventEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface NightSnackEventDao {
    @Query("SELECT * FROM night_snack_events ORDER BY date DESC")
    fun getAllEvents(): Flow<List<NightSnackEventEntity>>

    @Query("SELECT * FROM night_snack_events WHERE date = :date LIMIT 1")
    suspend fun getByDate(date: String): NightSnackEventEntity?

    @Query("SELECT COUNT(*) FROM night_snack_events WHERE date >= :today")
    suspend fun getEventCountSince(today: String): Int

    @Upsert
    suspend fun upsert(event: NightSnackEventEntity)

    @Query("DELETE FROM night_snack_events WHERE date < :before")
    suspend fun deleteOldEvents(before: String)
}
