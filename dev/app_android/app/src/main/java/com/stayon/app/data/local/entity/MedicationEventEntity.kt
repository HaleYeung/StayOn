package com.stayon.app.data.local.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "medication_events",
    indices = [Index(value = ["medicationId"])]
)
data class MedicationEventEntity(
    @PrimaryKey val id: String = java.util.UUID.randomUUID().toString(),
    val medicationId: String,
    val medicationName: String = "",
    val dosageText: String? = null,
    val scheduledAt: Long,
    val status: String = "pending",
    val confirmedAt: Long? = null,
    val skippedAt: Long? = null,
    val snoozeCount: Int = 0,
    val maxSnoozeCount: Int = 1,
    val lastNotificationAt: Long? = null,
    val createdAt: Long = System.currentTimeMillis()
)
