package com.stayon.app.domain.enums

enum class NightSnackStatus(val value: String, val displayName: String) {
    UNSET("unset", "未记录"),
    NO_SNACK("noSnack", "没吃"),
    ATE_SNACK("ateSnack", "吃了");

    companion object {
        fun from(value: String): NightSnackStatus =
            entries.firstOrNull { it.value == value } ?: UNSET
    }
}
