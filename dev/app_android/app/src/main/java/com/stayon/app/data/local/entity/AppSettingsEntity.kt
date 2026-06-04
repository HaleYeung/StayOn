package com.stayon.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "app_settings")
data class AppSettingsEntity(
    @PrimaryKey val id: String = java.util.UUID.randomUUID().toString(),
    val defaultSnoozeMinutes: Int = 10,
    val defaultMaxSnoozeCount: Int = 1,
    val toneStyle: String = "light_supervision",
    val hasSeenNotificationPrompt: Boolean = false,
    val mealTemplateTags: String = "[]"
)
