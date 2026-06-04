package com.stayon.app.domain.model

data class MealEvent(
    val id: String = java.util.UUID.randomUUID().toString(),
    val mealType: String,
    val scheduledAt: Long,
    val status: String = "pending",
    val acknowledgedAt: Long? = null,
    val noteSnapshot: String? = null,
    val tagsSnapshot: List<String> = emptyList(),
    val createdAt: Long = System.currentTimeMillis()
)
