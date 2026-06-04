package com.stayon.app.domain.enums

enum class MealType(val value: String, val displayName: String) {
    BREAKFAST("breakfast", "早餐"),
    LUNCH("lunch", "午餐"),
    DINNER("dinner", "晚餐"),
    NIGHT_SNACK("nightSnack", "夜宵");

    companion object {
        fun from(value: String): MealType =
            entries.firstOrNull { it.value == value } ?: BREAKFAST
    }
}
