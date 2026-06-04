package com.stayon.app.domain.model

data class SleepPlan(
    val id: String = java.util.UUID.randomUUID().toString(),
    val bedtimeHour: Int = 23,
    val bedtimeMinute: Int = 30,
    val preReminderMinutes: Int = 30,
    val snoozeIntervalMinutes: Int = 10,
    val maxSnoozeCount: Int = 1,
    val isActive: Boolean = true,
    val updatedAt: Long = System.currentTimeMillis()
)
