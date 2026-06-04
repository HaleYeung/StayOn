package com.stayon.app.data.local.dao

import androidx.room.*
import com.stayon.app.data.local.entity.MealEventEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface MealEventDao {
    @Query("SELECT * FROM meal_events WHERE scheduledAt >= :dayStart AND scheduledAt < :dayEnd ORDER BY scheduledAt ASC")
    fun getEventsForDay(dayStart: Long, dayEnd: Long): Flow<List<MealEventEntity>>

    @Query("SELECT COUNT(*) FROM meal_events WHERE scheduledAt >= :dayStart AND scheduledAt < :dayEnd")
    suspend fun getEventCountForDay(dayStart: Long, dayEnd: Long): Int

    @Query("SELECT * FROM meal_events ORDER BY scheduledAt DESC")
    fun getAllEvents(): Flow<List<MealEventEntity>>

    @Upsert
    suspend fun upsert(event: MealEventEntity)

    @Query("UPDATE meal_events SET status = 'unconfirmed' WHERE scheduledAt < :before AND status = 'pending'")
    suspend fun settlePendingBefore(before: Long)
}
