package com.stayon.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "meal_rules")
data class MealRuleEntity(
    @PrimaryKey val id: String = java.util.UUID.randomUUID().toString(),
    val mealType: String,
    val reminderHour: Int,
    val reminderMinute: Int,
    val templateTags: String = "[]",
    val customNote: String? = null,
    val isActive: Boolean = true,
    val updatedAt: Long = System.currentTimeMillis()
)
