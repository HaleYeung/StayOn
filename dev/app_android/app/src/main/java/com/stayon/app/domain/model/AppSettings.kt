package com.stayon.app.domain.model

data class AppSettings(
    val id: String = java.util.UUID.randomUUID().toString(),
    val defaultSnoozeMinutes: Int = 10,
    val defaultMaxSnoozeCount: Int = 1,
    val toneStyle: String = "light_supervision",
    val hasSeenNotificationPrompt: Boolean = false,
    val mealTemplateTags: List<String> = listOf(
        "少糖", "少盐", "少油", "控碳水",
        "控主食", "不喝含糖饮料", "少吃加工食品", "不吃夜宵"
    )
)
