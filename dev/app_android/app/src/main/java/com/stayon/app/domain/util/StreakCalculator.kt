package com.stayon.app.domain.util

import com.stayon.app.domain.model.*

object StreakCalculator {

    fun currentStreak(
        medicationEvents: List<MedicationEvent>,
        sleepEvents: List<SleepEvent>,
        mealEvents: List<MealEvent>,
        activeMealTypes: Set<String>
    ): Int = calculateStreak(medicationEvents, sleepEvents, mealEvents, activeMealTypes)

    fun longestStreak(
        medicationEvents: List<MedicationEvent>,
        sleepEvents: List<SleepEvent>,
        mealEvents: List<MealEvent>,
        activeMealTypes: Set<String>
    ): Int {
        var longest = 0
        var current = 0
        for (dayOffset in 0..365) {
            if (isDayCompleted(dayOffset, medicationEvents, sleepEvents, mealEvents, activeMealTypes)) {
                current++
                longest = maxOf(longest, current)
            } else {
                current = 0
            }
        }
        return longest
    }

    private fun calculateStreak(
        medicationEvents: List<MedicationEvent>,
        sleepEvents: List<SleepEvent>,
        mealEvents: List<MealEvent>,
        activeMealTypes: Set<String>
    ): Int {
        var streak = 0
        for (dayOffset in 0..365) {
            if (isDayCompleted(dayOffset, medicationEvents, sleepEvents, mealEvents, activeMealTypes)) {
                streak++
            } else {
                break
            }
        }
        return streak
    }

    private fun dayRange(dayOffset: Int): Pair<Long, Long> {
        val today = java.time.LocalDate.now()
        val date = today.minusDays(dayOffset.toLong())
        val start = date.atStartOfDay(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli()
        val end = date.plusDays(1).atStartOfDay(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli()
        return start to end
    }

    fun isDayCompleted(
        dayOffset: Int,
        medicationEvents: List<MedicationEvent>,
        sleepEvents: List<SleepEvent>,
        mealEvents: List<MealEvent>,
        activeMealTypes: Set<String>
    ): Boolean {
        val (dayStart, dayEnd) = dayRange(dayOffset)
        val dateStr = java.time.LocalDate.now().minusDays(dayOffset.toLong())
            .format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE)

        val meds = medicationEvents.filter { it.scheduledAt in dayStart until dayEnd }
        if (meds.any { it.status == "pending" || it.status == "unconfirmed" }) return false

        val sleeps = sleepEvents.filter { it.date == dateStr }
        if (sleeps.isNotEmpty() && sleeps.none { it.status == "confirmed" }) return false

        val meals = mealEvents.filter { it.scheduledAt in dayStart until dayEnd }
        for (mealType in activeMealTypes) {
            val meal = meals.firstOrNull { it.mealType == mealType }
            if (meal == null || meal.status != "acknowledged") return false
        }

        return true
    }
}
