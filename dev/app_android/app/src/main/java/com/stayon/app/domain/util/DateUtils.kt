package com.stayon.app.domain.util

import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter

object DateUtils {
    fun todayStartMillis(): Long =
        LocalDate.now().atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()

    fun tomorrowStartMillis(): Long =
        LocalDate.now().plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()

    fun todayDateString(): String = LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE)

    fun combine(date: LocalDate, time: LocalTime): Long =
        date.atTime(time).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()

    fun formatTime(millis: Long): String {
        val time = java.time.LocalTime.from(
            java.time.Instant.ofEpochMilli(millis).atZone(ZoneId.systemDefault())
        )
        return time.format(DateTimeFormatter.ofPattern("HH:mm"))
    }

    fun formatDate(millis: Long): String {
        val date = java.time.LocalDate.from(
            java.time.Instant.ofEpochMilli(millis).atZone(ZoneId.systemDefault())
        )
        return date.format(DateTimeFormatter.ofPattern("M/d"))
    }
}
