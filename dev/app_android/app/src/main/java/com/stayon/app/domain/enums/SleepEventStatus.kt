package com.stayon.app.domain.enums

enum class SleepEventStatus(val value: String, val displayName: String) {
    PENDING("pending", "待确认"),
    CONFIRMED("confirmed", "晚安"),
    UNCONFIRMED("unconfirmed", "未确认");

    companion object {
        fun from(value: String): SleepEventStatus =
            entries.firstOrNull { it.value == value } ?: PENDING
    }
}
