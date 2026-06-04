package com.stayon.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "sleep_plans")
data class SleepPlanEntity(
    @PrimaryKey val id: String = java.util.UUID.randomUUID().toString(),
    val bedtimeHour: Int,
    val bedtimeMinute: Int,
    val preReminderMinutes: Int = 30,
    val snoozeIntervalMinutes: Int = 10,
    val maxSnoozeCount: Int = 1,
    val isActive: Boolean = true,
    val updatedAt: Long = System.currentTimeMillis()
)
