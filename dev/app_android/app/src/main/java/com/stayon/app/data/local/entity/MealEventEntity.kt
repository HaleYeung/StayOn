package com.stayon.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "meal_events")
data class MealEventEntity(
    @PrimaryKey val id: String = java.util.UUID.randomUUID().toString(),
    val mealType: String,
    val scheduledAt: Long,
    val status: String = "pending",
    val acknowledgedAt: Long? = null,
    val noteSnapshot: String? = null,
    val tagsSnapshot: String = "[]",
    val createdAt: Long = System.currentTimeMillis()
)
