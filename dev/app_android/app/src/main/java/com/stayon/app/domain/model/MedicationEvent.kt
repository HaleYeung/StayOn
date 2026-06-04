package com.stayon.app.domain.model

data class MedicationEvent(
    val id: String = java.util.UUID.randomUUID().toString(),
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
