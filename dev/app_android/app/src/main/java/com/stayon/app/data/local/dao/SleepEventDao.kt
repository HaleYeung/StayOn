package com.stayon.app.data.local.dao

import androidx.room.*
import com.stayon.app.data.local.entity.SleepEventEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface SleepEventDao {
    @Query("SELECT * FROM sleep_events WHERE date >= :dayStart AND date < :dayEnd ORDER BY date ASC")
    fun getEventsForDay(dayStart: String, dayEnd: String): Flow<List<SleepEventEntity>>

    @Query("SELECT COUNT(*) FROM sleep_events WHERE date >= :today")
    suspend fun getEventCountSince(today: String): Int

    @Query("SELECT * FROM sleep_events ORDER BY date DESC")
    fun getAllEvents(): Flow<List<SleepEventEntity>>

    @Query("SELECT * FROM sleep_events WHERE id = :id")
    suspend fun getById(id: String): SleepEventEntity?

    @Upsert
    suspend fun upsert(event: SleepEventEntity)

    @Query("UPDATE sleep_events SET status = 'unconfirmed' WHERE date < :today AND status = 'pending'")
    suspend fun settlePendingBefore(today: String)
}
