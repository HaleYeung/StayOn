package com.stayon.app.data.local.dao

import androidx.room.*
import com.stayon.app.data.local.entity.MedicationEventEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface MedicationEventDao {
    @Query("SELECT * FROM medication_events WHERE scheduledAt >= :dayStart AND scheduledAt < :dayEnd ORDER BY scheduledAt ASC")
    fun getEventsForDay(dayStart: Long, dayEnd: Long): Flow<List<MedicationEventEntity>>

    @Query("SELECT COUNT(*) FROM medication_events WHERE scheduledAt >= :dayStart AND scheduledAt < :dayEnd")
    suspend fun getEventCountForDay(dayStart: Long, dayEnd: Long): Int

    @Query("SELECT * FROM medication_events ORDER BY scheduledAt DESC")
    fun getAllEvents(): Flow<List<MedicationEventEntity>>

    @Query("SELECT * FROM medication_events WHERE id = :id")
    suspend fun getById(id: String): MedicationEventEntity?

    @Upsert
    suspend fun upsert(event: MedicationEventEntity)

    @Query("UPDATE medication_events SET status = :status, confirmedAt = :confirmedAt WHERE id = :id")
    suspend fun updateStatus(id: String, status: String, confirmedAt: Long?)

    @Query("UPDATE medication_events SET status = 'unconfirmed' WHERE scheduledAt < :before AND status = 'pending'")
    suspend fun settlePendingBefore(before: Long)
}
