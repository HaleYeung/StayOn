package com.stayon.app.domain.enums

enum class MealEventStatus(val value: String, val displayName: String) {
    PENDING("pending", "待确认"),
    ACKNOWLEDGED("acknowledged", "已确认"),
    UNCONFIRMED("unconfirmed", "未确认");

    companion object {
        fun from(value: String): MealEventStatus =
            entries.firstOrNull { it.value == value } ?: PENDING
    }
}
