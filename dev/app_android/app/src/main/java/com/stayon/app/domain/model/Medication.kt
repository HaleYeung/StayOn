package com.stayon.app.domain.model

data class Medication(
    val id: String = java.util.UUID.randomUUID().toString(),
    val name: String,
    val dosageText: String? = null,
    val scheduleType: String = "daily",
    val weekdays: List<Int> = emptyList(),
    val timesPerDay: Int = 1,
    val reminderTimes: List<java.time.LocalTime> = emptyList(),
    val mealNote: String? = null,
    val note: String? = null,
    val isActive: Boolean = true,
    val snoozeIntervalMinutes: Int = 10,
    val maxSnoozeCount: Int = 1,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)
