package com.stayon.app.domain.util

import com.stayon.app.domain.enums.ToneStyle

object NotificationTextBuilder {

    var currentStyle: ToneStyle = ToneStyle.LIGHT_SUPERVISION

    fun medicationTitle(): String = when (currentStyle) {
        ToneStyle.LIGHT_SUPERVISION -> "该吃药了，别拖。"
        ToneStyle.GENTLE -> "该吃药了，记得按时。"
        ToneStyle.SERIOUS -> "请立即服药！"
    }

    fun medicationBody(name: String, dosage: String?): String =
        if (!dosage.isNullOrEmpty()) "$name $dosage" else name

    fun sleepPreTitle(): String = when (currentStyle) {
        ToneStyle.LIGHT_SUPERVISION -> "差不多该收了。"
        ToneStyle.GENTLE -> "准备睡觉了。"
        ToneStyle.SERIOUS -> "请注意休息时间。"
    }

    fun sleepPreBody(minutes: Int): String = when (currentStyle) {
        ToneStyle.LIGHT_SUPERVISION -> "${minutes}分钟后准备睡觉，别又拖到太晚。"
        ToneStyle.GENTLE -> "${minutes}分钟后该休息了，早点睡。"
        ToneStyle.SERIOUS -> "您将在${minutes}分钟后到达目标就寝时间。"
    }

    fun sleepTitle(): String = when (currentStyle) {
        ToneStyle.LIGHT_SUPERVISION -> "到点了，该睡了。"
        ToneStyle.GENTLE -> "到睡觉时间了。"
        ToneStyle.SERIOUS -> "就寝时间已到。"
    }

    fun sleepBody(): String = when (currentStyle) {
        ToneStyle.LIGHT_SUPERVISION -> "今晚别乱来，按时收工。"
        ToneStyle.GENTLE -> "好好休息，明天会更好。"
        ToneStyle.SERIOUS -> "睡眠不足影响健康，请立即休息。"
    }

    fun mealTitle(): String = when (currentStyle) {
        ToneStyle.LIGHT_SUPERVISION -> "吃之前先看一眼。"
        ToneStyle.GENTLE -> "吃饭前注意一下。"
        ToneStyle.SERIOUS -> "饮食提醒。"
    }

    fun mealBody(tags: List<String>, note: String?): String =
        (tags + if (!note.isNullOrEmpty()) listOf(note) else emptyList()).joinToString("，")

    fun nightSnackTitle(): String = when (currentStyle) {
        ToneStyle.LIGHT_SUPERVISION -> "今晚夜宵就算了。"
        ToneStyle.GENTLE -> "晚上少吃点。"
        ToneStyle.SERIOUS -> "请控制夜宵摄入。"
    }

    fun nightSnackBody(): String = when (currentStyle) {
        ToneStyle.LIGHT_SUPERVISION -> "现在忍住，明天会感谢你。"
        ToneStyle.GENTLE -> "早点休息，对胃好。"
        ToneStyle.SERIOUS -> "夜宵会增加身体负担。"
    }
}
