package com.stayon.app.domain.enums

enum class ToneStyle(val value: String, val displayName: String, val description: String) {
    LIGHT_SUPERVISION("light_supervision", "轻监督", "轻微吐槽风格，带点调侃"),
    GENTLE("gentle", "温和提醒", "温和鼓励，不施加压力"),
    SERIOUS("serious", "严肃提醒", "直接严肃，不容忽视");

    companion object {
        fun from(value: String): ToneStyle =
            entries.firstOrNull { it.value == value } ?: LIGHT_SUPERVISION

        val defaultTags = listOf(
            "少糖", "少盐", "少油", "控碳水",
            "控主食", "不喝含糖饮料", "少吃加工食品", "不吃夜宵"
        )
    }
}
