import Foundation
import SwiftData

@MainActor
struct DailyEventGenerator {

    /// Generate today's events based on current plans.
    /// Also settles previous days' pending events to unconfirmed.
    /// Skips any events that already exist for today (idempotent).
    static func generateIfNeeded(modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }

        settlePendingEvents(modelContext: modelContext, before: today)
        ensureAppSettings(modelContext: modelContext)
        generateMedicationEvents(modelContext: modelContext, today: today, tomorrow: tomorrow)
        generateSleepEvent(modelContext: modelContext, today: today)
        generateMealEvents(modelContext: modelContext, today: today, tomorrow: tomorrow)
        generateNightSnackEvent(modelContext: modelContext, today: today)
    }

    /// Settle all pending medication and sleep events before `before` date to unconfirmed.
    /// PRD 7.1-5, 7.2-5: "超过当天有效期仍无确认 -> 未确认"
    private static func settlePendingEvents(modelContext: ModelContext, before: Date) {
        let medDescriptor = FetchDescriptor<MedicationEvent>(
            predicate: #Predicate { $0.scheduledAt < before && $0.statusRaw == "pending" }
        )
        if let pastMeds = try? modelContext.fetch(medDescriptor) {
            for event in pastMeds {
                event.status = .unconfirmed
            }
        }

        let sleepDescriptor = FetchDescriptor<SleepEvent>(
            predicate: #Predicate { $0.date < before && $0.statusRaw == "pending" }
        )
        if let pastSleeps = try? modelContext.fetch(sleepDescriptor) {
            for event in pastSleeps {
                event.status = .unconfirmed
            }
        }

        let mealDescriptor = FetchDescriptor<MealEvent>(
            predicate: #Predicate { $0.scheduledAt < before && $0.statusRaw == "pending" }
        )
        if let pastMeals = try? modelContext.fetch(mealDescriptor) {
            for event in pastMeals {
                event.status = .unconfirmed
            }
        }

        // Delete old unset night snack events so they don't block fresh recording
        let nsDescriptor = FetchDescriptor<NightSnackEvent>(
            predicate: #Predicate { $0.date < before }
        )
        if let oldNS = try? modelContext.fetch(nsDescriptor) {
            for event in oldNS {
                modelContext.delete(event)
            }
        }

        try? modelContext.save()
    }

    // MARK: - Medication Events

    private static func generateMedicationEvents(modelContext: ModelContext, today: Date, tomorrow: Date) {
        let medicationDescriptor = FetchDescriptor<Medication>(
            predicate: #Predicate { $0.isActive == true }
        )
        guard let medications = try? modelContext.fetch(medicationDescriptor) else { return }

        let eventDescriptor = FetchDescriptor<MedicationEvent>(
            predicate: #Predicate { $0.scheduledAt >= today && $0.scheduledAt < tomorrow }
        )
        let existingEvents = (try? modelContext.fetch(eventDescriptor)) ?? []

        for medication in medications {
            // Check if today is a scheduled day
            if medication.scheduleType == .weekly {
                let todayWeekday = Calendar.current.component(.weekday, from: today)
                let weekday = todayWeekday == 1 ? 7 : todayWeekday - 1
                guard medication.weekdays.contains(weekday) else { continue }
            }

            for reminderTime in medication.reminderTimes {
                let scheduledAt = combine(date: today, time: reminderTime)

                // Skip if event already exists at this exact time for this medication
                let alreadyExists = existingEvents.contains { event in
                    event.medicationId == medication.id &&
                    abs(event.scheduledAt.timeIntervalSince(scheduledAt)) < 60
                }
                guard !alreadyExists else { continue }

                let event = MedicationEvent(
                    medicationId: medication.id,
                    medicationName: medication.name,
                    dosageText: medication.dosageText,
                    scheduledAt: scheduledAt,
                    status: .pending,
                    maxSnoozeCount: medication.maxSnoozeCount,
                    createdAt: .now
                )
                modelContext.insert(event)
            }
        }
    }

    // MARK: - Sleep Event

    private static func generateSleepEvent(modelContext: ModelContext, today: Date) {
        let planDescriptor = FetchDescriptor<SleepPlan>()
        guard let plans = try? modelContext.fetch(planDescriptor),
              let plan = plans.first, plan.isActive else { return }

        let eventDescriptor = FetchDescriptor<SleepEvent>(
            predicate: #Predicate { $0.date >= today }
        )
        let existing = (try? modelContext.fetch(eventDescriptor)) ?? []
        guard existing.isEmpty else { return }

        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }

        let bedtime = combine(date: today, time: plan.bedtime)
        let preTime = Calendar.current.date(byAdding: .minute, value: -plan.preReminderMinutes, to: bedtime) ?? bedtime
        let finalTime = bedtime

        // If bedtime is before current time, it's for tomorrow night
        let actualBedtime: Date
        let actualPreTime: Date
        let actualFinalTime: Date
        if bedtime < .now {
            actualBedtime = combine(date: tomorrow, time: plan.bedtime)
            actualPreTime = Calendar.current.date(byAdding: .minute, value: -plan.preReminderMinutes, to: actualBedtime) ?? actualBedtime
            actualFinalTime = actualBedtime
        } else {
            actualBedtime = bedtime
            actualPreTime = preTime
            actualFinalTime = finalTime
        }

        let event = SleepEvent(
            date: today,
            targetBedtime: actualBedtime,
            preReminderAt: actualPreTime,
            finalReminderAt: actualFinalTime,
            status: .pending,
            maxSnoozeCount: plan.maxSnoozeCount,
            createdAt: .now
        )
        modelContext.insert(event)
    }

    // MARK: - Meal Events

    private static func generateMealEvents(modelContext: ModelContext, today: Date, tomorrow: Date) {
        let ruleDescriptor = FetchDescriptor<MealRule>()
        guard let rules = try? modelContext.fetch(ruleDescriptor) else { return }

        let eventDescriptor = FetchDescriptor<MealEvent>(
            predicate: #Predicate { $0.scheduledAt >= today && $0.scheduledAt < tomorrow }
        )
        let existingMealTypes = Set(
            (try? modelContext.fetch(eventDescriptor))?.map { $0.mealType } ?? []
        )

        for rule in rules where rule.isActive && rule.mealType != .nightSnack {
            guard !existingMealTypes.contains(rule.mealType) else { continue }

            let scheduledAt = combine(date: today, time: rule.reminderTime)

            let event = MealEvent(
                mealType: rule.mealType,
                scheduledAt: scheduledAt,
                status: .pending,
                noteSnapshot: rule.customNote,
                tagsSnapshot: rule.templateTags,
                createdAt: .now
            )
            modelContext.insert(event)
        }
    }

    // MARK: - Night Snack Event

    private static func generateNightSnackEvent(modelContext: ModelContext, today: Date) {
        let ruleDescriptor = FetchDescriptor<MealRule>()
        guard let rules = try? modelContext.fetch(ruleDescriptor) else { return }
        guard let nightSnackRule = rules.first(where: { $0.mealType == .nightSnack && $0.isActive }) else { return }

        let eventDescriptor = FetchDescriptor<NightSnackEvent>(
            predicate: #Predicate { $0.date >= today }
        )
        let existing = (try? modelContext.fetch(eventDescriptor)) ?? []
        guard existing.isEmpty else { return }

        let reminderAt = combine(date: today, time: nightSnackRule.reminderTime)

        let event = NightSnackEvent(
            date: today,
            reminderAt: reminderAt,
            status: .unset,
            recordedAt: nil
        )
        modelContext.insert(event)
    }

    // MARK: - AppSettings

    /// Ensure at least one AppSettings record exists.
    private static func ensureAppSettings(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<AppSettings>()
        guard let existing = try? modelContext.fetch(descriptor), existing.isEmpty else { return }
        let settings = AppSettings()
        modelContext.insert(settings)
        try? modelContext.save()
    }

    // MARK: - Helpers

    private static func combine(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.second = timeComponents.second
        return calendar.date(from: combined) ?? date
    }
}
