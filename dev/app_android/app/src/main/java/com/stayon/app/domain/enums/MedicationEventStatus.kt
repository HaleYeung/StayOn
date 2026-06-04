package com.stayon.app.domain.enums

enum class MedicationEventStatus(val value: String, val displayName: String) {
    PENDING("pending", "待确认"),
    DONE("done", "已吃"),
    SKIPPED("skipped", "跳过"),
    UNCONFIRMED("unconfirmed", "未确认");

    companion object {
        fun from(value: String): MedicationEventStatus =
            entries.firstOrNull { it.value == value } ?: PENDING
    }
}
