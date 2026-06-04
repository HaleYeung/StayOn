import Foundation

struct StreakCalculator {
    static func currentStreak(
        medicationEvents: [MedicationEvent],
        sleepEvents: [SleepEvent],
        mealEvents: [MealEvent],
        mealRules: [MealRule]
    ) -> Int {
        let calendar = Calendar.current
        var streak = 0
        let today = calendar.startOfDay(for: .now)

        for dayOffset in 0...365 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            if isDayCompleted(
                date: date,
                medicationEvents: medicationEvents,
                sleepEvents: sleepEvents,
                mealEvents: mealEvents,
                mealRules: mealRules
            ) {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    static func longestStreak(
        medicationEvents: [MedicationEvent],
        sleepEvents: [SleepEvent],
        mealEvents: [MealEvent],
        mealRules: [MealRule]
    ) -> Int {
        let calendar = Calendar.current
        var longest = 0
        var current = 0
        let today = calendar.startOfDay(for: .now)

        for dayOffset in 0...365 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            if isDayCompleted(
                date: date,
                medicationEvents: medicationEvents,
                sleepEvents: sleepEvents,
                mealEvents: mealEvents,
                mealRules: mealRules
            ) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
        }
        return longest
    }

    static func isDayCompleted(
        date: Date,
        medicationEvents: [MedicationEvent],
        sleepEvents: [SleepEvent],
        mealEvents: [MealEvent],
        mealRules: [MealRule]
    ) -> Bool {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

        let medsForDay = medicationEvents.filter { $0.scheduledAt >= dayStart && $0.scheduledAt < dayEnd }
        let anyMedUnconfirmed = medsForDay.contains { $0.status == .unconfirmed || $0.status == .pending }
        if !medsForDay.isEmpty && anyMedUnconfirmed {
            return false
        }

        let sleepForDay = sleepEvents.filter { $0.date >= dayStart && $0.date < dayEnd }
        let sleepConfirmed = sleepForDay.contains { $0.status == .confirmed }
        if !sleepForDay.isEmpty && !sleepConfirmed {
            return false
        }

        let mealsForDay = mealEvents.filter { $0.scheduledAt >= dayStart && $0.scheduledAt < dayEnd }
        let activeMealTypes = Set(mealRules.filter { $0.isActive }.map { $0.mealType })
        for mealType in activeMealTypes {
            let mealForType = mealsForDay.first { $0.mealType == mealType }
            if mealForType == nil || mealForType?.status != .acknowledged {
                return false
            }
        }

        return true
    }

    static func isTodayComplete(
        medicationEvents: [MedicationEvent],
        sleepEvents: [SleepEvent],
        mealEvents: [MealEvent],
        mealRules: [MealRule]
    ) -> Bool {
        isDayCompleted(
            date: .now,
            medicationEvents: medicationEvents,
            sleepEvents: sleepEvents,
            mealEvents: mealEvents,
            mealRules: mealRules
        )
    }
}
