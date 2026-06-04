package com.stayon.app.domain.enums

enum class ScheduleType(val value: String) {
    DAILY("daily"),
    WEEKLY("weekly");

    companion object {
        fun from(value: String): ScheduleType =
            entries.firstOrNull { it.value == value } ?: DAILY
    }
}
