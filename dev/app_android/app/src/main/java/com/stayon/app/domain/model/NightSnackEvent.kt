package com.stayon.app.domain.model

data class NightSnackEvent(
    val id: String = java.util.UUID.randomUUID().toString(),
    val date: String,
    val reminderAt: Long,
    val status: String = "unset",
    val recordedAt: Long? = null
)
