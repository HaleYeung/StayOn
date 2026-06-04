package com.stayon.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "sleep_events")
data class SleepEventEntity(
    @PrimaryKey val id: String = java.util.UUID.randomUUID().toString(),
    val date: String,
    val targetBedtime: Long,
    val preReminderAt: Long,
    val finalReminderAt: Long,
    val status: String = "pending",
    val confirmedAt: Long? = null,
    val snoozeCount: Int = 0,
    val maxSnoozeCount: Int = 1,
    val lastNotificationAt: Long? = null,
    val createdAt: Long = System.currentTimeMillis()
)
