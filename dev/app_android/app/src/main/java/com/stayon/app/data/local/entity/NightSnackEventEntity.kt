package com.stayon.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "night_snack_events")
data class NightSnackEventEntity(
    @PrimaryKey val id: String = java.util.UUID.randomUUID().toString(),
    val date: String,
    val reminderAt: Long,
    val status: String = "unset",
    val recordedAt: Long? = null
)
