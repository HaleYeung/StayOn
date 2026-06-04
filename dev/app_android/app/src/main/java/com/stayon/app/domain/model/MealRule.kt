package com.stayon.app.domain.model

data class MealRule(
    val id: String = java.util.UUID.randomUUID().toString(),
    val mealType: String,
    val reminderHour: Int,
    val reminderMinute: Int,
    val templateTags: List<String> = emptyList(),
    val customNote: String? = null,
    val isActive: Boolean = true,
    val updatedAt: Long = System.currentTimeMillis()
)
