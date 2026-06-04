package com.stayon.app.data.local

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.stayon.app.data.local.entity.*
import com.stayon.app.domain.model.*
import java.time.LocalTime

private val gson = Gson()

private inline fun <reified T> fromJsonList(json: String): List<T> {
    return try {
        gson.fromJson(json, object : TypeToken<List<T>>() {}.type) ?: emptyList()
    } catch (_: Exception) {
        emptyList()
    }
}

// ── Medication ──

fun MedicationEntity.toDomain() = Medication(
    id = id, name = name, dosageText = dosageText,
    scheduleType = scheduleType,
    weekdays = fromJsonList<Int>(weekdays),
    timesPerDay = timesPerDay,
    reminderTimes = fromJsonList<String>(reminderTimes).mapNotNull { timeStr ->
        try { LocalTime.parse(timeStr) } catch (_: Exception) { null }
    },
    mealNote = mealNote, note = note, isActive = isActive,
    snoozeIntervalMinutes = snoozeIntervalMinutes, maxSnoozeCount = maxSnoozeCount,
    createdAt = createdAt, updatedAt = updatedAt
)

fun Medication.toEntity() = MedicationEntity(
    id = id, name = name, dosageText = dosageText,
    scheduleType = scheduleType,
    weekdays = gson.toJson(weekdays),
    timesPerDay = timesPerDay,
    reminderTimes = gson.toJson(reminderTimes.map { it.toString() }),
    mealNote = mealNote, note = note, isActive = isActive,
    snoozeIntervalMinutes = snoozeIntervalMinutes, maxSnoozeCount = maxSnoozeCount,
    createdAt = createdAt, updatedAt = updatedAt
)

// ── MedicationEvent ──

fun MedicationEventEntity.toDomain() = MedicationEvent(
    id = id, medicationId = medicationId, medicationName = medicationName,
    dosageText = dosageText, scheduledAt = scheduledAt, status = status,
    confirmedAt = confirmedAt, skippedAt = skippedAt,
    snoozeCount = snoozeCount, maxSnoozeCount = maxSnoozeCount,
    lastNotificationAt = lastNotificationAt, createdAt = createdAt
)

fun MedicationEvent.toEntity() = MedicationEventEntity(
    id = id, medicationId = medicationId, medicationName = medicationName,
    dosageText = dosageText, scheduledAt = scheduledAt, status = status,
    confirmedAt = confirmedAt, skippedAt = skippedAt,
    snoozeCount = snoozeCount, maxSnoozeCount = maxSnoozeCount,
    lastNotificationAt = lastNotificationAt, createdAt = createdAt
)

// ── SleepPlan ──

fun SleepPlanEntity.toDomain() = SleepPlan(
    id = id, bedtimeHour = bedtimeHour, bedtimeMinute = bedtimeMinute,
    preReminderMinutes = preReminderMinutes,
    snoozeIntervalMinutes = snoozeIntervalMinutes, maxSnoozeCount = maxSnoozeCount,
    isActive = isActive, updatedAt = updatedAt
)

fun SleepPlan.toEntity() = SleepPlanEntity(
    id = id, bedtimeHour = bedtimeHour, bedtimeMinute = bedtimeMinute,
    preReminderMinutes = preReminderMinutes,
    snoozeIntervalMinutes = snoozeIntervalMinutes, maxSnoozeCount = maxSnoozeCount,
    isActive = isActive, updatedAt = updatedAt
)

// ── SleepEvent ──

fun SleepEventEntity.toDomain() = SleepEvent(
    id = id, date = date, targetBedtime = targetBedtime,
    preReminderAt = preReminderAt, finalReminderAt = finalReminderAt,
    status = status, confirmedAt = confirmedAt, snoozeCount = snoozeCount,
    maxSnoozeCount = maxSnoozeCount, lastNotificationAt = lastNotificationAt,
    createdAt = createdAt
)

fun SleepEvent.toEntity() = SleepEventEntity(
    id = id, date = date, targetBedtime = targetBedtime,
    preReminderAt = preReminderAt, finalReminderAt = finalReminderAt,
    status = status, confirmedAt = confirmedAt, snoozeCount = snoozeCount,
    maxSnoozeCount = maxSnoozeCount, lastNotificationAt = lastNotificationAt,
    createdAt = createdAt
)

// ── MealRule ──

fun MealRuleEntity.toDomain() = MealRule(
    id = id, mealType = mealType, reminderHour = reminderHour, reminderMinute = reminderMinute,
    templateTags = fromJsonList<String>(templateTags),
    customNote = customNote, isActive = isActive, updatedAt = updatedAt
)

fun MealRule.toEntity() = MealRuleEntity(
    id = id, mealType = mealType, reminderHour = reminderHour, reminderMinute = reminderMinute,
    templateTags = gson.toJson(templateTags), customNote = customNote,
    isActive = isActive, updatedAt = updatedAt
)

// ── MealEvent ──

fun MealEventEntity.toDomain() = MealEvent(
    id = id, mealType = mealType, scheduledAt = scheduledAt, status = status,
    acknowledgedAt = acknowledgedAt, noteSnapshot = noteSnapshot,
    tagsSnapshot = fromJsonList<String>(tagsSnapshot),
    createdAt = createdAt
)

fun MealEvent.toEntity() = MealEventEntity(
    id = id, mealType = mealType, scheduledAt = scheduledAt, status = status,
    acknowledgedAt = acknowledgedAt, noteSnapshot = noteSnapshot,
    tagsSnapshot = gson.toJson(tagsSnapshot), createdAt = createdAt
)

// ── NightSnackEvent ──

fun NightSnackEventEntity.toDomain() = NightSnackEvent(
    id = id, date = date, reminderAt = reminderAt, status = status, recordedAt = recordedAt
)

fun NightSnackEvent.toEntity() = NightSnackEventEntity(
    id = id, date = date, reminderAt = reminderAt, status = status, recordedAt = recordedAt
)

// ── AppSettings ──

fun AppSettingsEntity.toDomain() = AppSettings(
    id = id, defaultSnoozeMinutes = defaultSnoozeMinutes,
    defaultMaxSnoozeCount = defaultMaxSnoozeCount, toneStyle = toneStyle,
    hasSeenNotificationPrompt = hasSeenNotificationPrompt,
    mealTemplateTags = fromJsonList<String>(mealTemplateTags)
)

fun AppSettings.toEntity() = AppSettingsEntity(
    id = id, defaultSnoozeMinutes = defaultSnoozeMinutes,
    defaultMaxSnoozeCount = defaultMaxSnoozeCount, toneStyle = toneStyle,
    hasSeenNotificationPrompt = hasSeenNotificationPrompt,
    mealTemplateTags = gson.toJson(mealTemplateTags)
)
