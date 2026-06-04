package com.stayon.app.data.repository

import com.stayon.app.data.local.AppDatabase
import com.stayon.app.data.local.toDomain
import com.stayon.app.data.local.toEntity
import com.stayon.app.domain.model.MealEvent
import com.stayon.app.domain.model.MealRule
import com.stayon.app.domain.model.NightSnackEvent
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class MealRepository(private val db: AppDatabase) {

    fun getAllRules(): Flow<List<MealRule>> =
        db.mealRuleDao().getAllRules().map { list -> list.map { it.toDomain() } }

    suspend fun getRuleByMealType(mealType: String): MealRule? =
        db.mealRuleDao().getByMealType(mealType)?.toDomain()

    suspend fun saveRule(rule: MealRule) {
        db.mealRuleDao().upsert(rule.toEntity())
    }

    suspend fun deleteRule(rule: MealRule) {
        db.mealRuleDao().delete(rule.toEntity())
    }

    fun getTodayMealEvents(): Flow<List<MealEvent>> {
        val now = java.time.LocalDate.now()
        val start = now.atStartOfDay(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli()
        val end = now.plusDays(1).atStartOfDay(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli()
        return db.mealEventDao().getEventsForDay(start, end)
            .map { list -> list.map { it.toDomain() } }
    }

    suspend fun saveMealEvent(event: MealEvent) {
        db.mealEventDao().upsert(event.toEntity())
    }

    fun getNightSnackEvents(): Flow<List<NightSnackEvent>> =
        db.nightSnackEventDao().getAllEvents().map { list -> list.map { it.toDomain() } }

    suspend fun getTodayNightSnack(): NightSnackEvent? {
        val today = java.time.LocalDate.now().toString()
        return db.nightSnackEventDao().getByDate(today)?.toDomain()
    }

    suspend fun saveNightSnackEvent(event: NightSnackEvent) {
        db.nightSnackEventDao().upsert(event.toEntity())
    }
}
