package com.stayon.app.data.local

import com.stayon.app.data.local.entity.*
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId

object EventGenerator {

    suspend fun generateFromPlans(db: AppDatabase) {
        val today = LocalDate.now()
        val todayStart = today.atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()
        val tomorrowStart = today.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()

        // Medication events
        // Using direct entity queries since we can't get Flow in worker
        val eventCount = db.medicationEventDao().getEventCountForDay(todayStart, tomorrowStart)
        if (eventCount == 0) {
            val meds = db.medicationDao().getAllMedicationsOnce()
            for (med in meds) {
                if (!med.isActive) continue
                if (med.scheduleType == "weekly") {
                    val todayWeekday = today.dayOfWeek.value // 1=Mon ... 7=Sun
                    val weekdays = try {
                        com.google.gson.Gson().fromJson(med.weekdays, Array<Int>::class.java).toList()
                    } catch (_: Exception) { emptyList() }
                    if (todayWeekday !in weekdays) continue
                }
                val times = try {
                    com.google.gson.Gson().fromJson(med.reminderTimes, Array<String>::class.java).toList()
                } catch (_: Exception) { emptyList() }
                for (timeStr in times) {
                    val time = try { LocalTime.parse(timeStr) } catch (_: Exception) { continue }
                    val scheduledAt = today.atTime(time).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
                    db.medicationEventDao().upsert(MedicationEventEntity(
                        medicationId = med.id, medicationName = med.name,
                        dosageText = med.dosageText, scheduledAt = scheduledAt,
                        status = "pending", maxSnoozeCount = med.maxSnoozeCount
                    ))
                }
            }
        }

        // Sleep event
        val sleepEventCount = db.sleepEventDao().getEventCountSince(today.toString())
        if (sleepEventCount == 0) {
            val plan = db.sleepPlanDao().getSleepPlanOnce()
            if (plan != null && plan.isActive) {
                val bedtime = today.atTime(plan.bedtimeHour, plan.bedtimeMinute)
                    .atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
                val preTime = bedtime - (plan.preReminderMinutes * 60_000L)
                db.sleepEventDao().upsert(SleepEventEntity(
                    date = today.toString(), targetBedtime = bedtime,
                    preReminderAt = preTime, finalReminderAt = bedtime,
                    status = "pending", maxSnoozeCount = plan.maxSnoozeCount
                ))
            }
        }

        // Meal events (excluding nightSnack)
        val mealEventCount = db.mealEventDao().getEventCountForDay(todayStart, tomorrowStart)
        if (mealEventCount == 0) {
            val rules = db.mealRuleDao().getAllRulesOnce()
            for (rule in rules) {
                if (!rule.isActive || rule.mealType == "nightSnack") continue
                val scheduledAt = today.atTime(rule.reminderHour, rule.reminderMinute)
                    .atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
                db.mealEventDao().upsert(MealEventEntity(
                    mealType = rule.mealType, scheduledAt = scheduledAt,
                    status = "pending", tagsSnapshot = rule.templateTags,
                    noteSnapshot = rule.customNote
                ))
            }
        }

        // Night snack event
        val nsCount = db.nightSnackEventDao().getEventCountSince(today.toString())
        if (nsCount == 0) {
            val nsRule = db.mealRuleDao().getByMealType("nightSnack")
            if (nsRule != null && nsRule.isActive) {
                val reminderAt = today.atTime(nsRule.reminderHour, nsRule.reminderMinute)
                    .atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
                db.nightSnackEventDao().upsert(NightSnackEventEntity(
                    date = today.toString(), reminderAt = reminderAt,
                    status = "unset"
                ))
            }
        }
    }
}
