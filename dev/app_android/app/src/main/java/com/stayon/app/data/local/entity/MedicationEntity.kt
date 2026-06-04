package com.stayon.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "medications")
data class MedicationEntity(
    @PrimaryKey val id: String = java.util.UUID.randomUUID().toString(),
    val name: String,
    val dosageText: String? = null,
    val scheduleType: String = "daily",
    val weekdays: String = "[]",
    val timesPerDay: Int = 1,
    val reminderTimes: String = "[]",
    val mealNote: String? = null,
    val note: String? = null,
    val isActive: Boolean = true,
    val snoozeIntervalMinutes: Int = 10,
    val maxSnoozeCount: Int = 1,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)
