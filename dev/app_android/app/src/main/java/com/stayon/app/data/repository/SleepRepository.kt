package com.stayon.app.data.repository

import com.stayon.app.data.local.AppDatabase
import com.stayon.app.data.local.toDomain
import com.stayon.app.data.local.toEntity
import com.stayon.app.domain.model.SleepEvent
import com.stayon.app.domain.model.SleepPlan
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class SleepRepository(private val db: AppDatabase) {

    fun getSleepPlan(): Flow<SleepPlan?> =
        db.sleepPlanDao().getSleepPlan().map { it?.toDomain() }

    suspend fun getSleepPlanOnce(): SleepPlan? =
        db.sleepPlanDao().getSleepPlanOnce()?.toDomain()

    suspend fun saveSleepPlan(plan: SleepPlan) {
        db.sleepPlanDao().upsert(plan.toEntity())
    }

    fun getTodayEvents(): Flow<List<SleepEvent>> {
        val today = java.time.LocalDate.now().toString()
        val tomorrow = java.time.LocalDate.now().plusDays(1).toString()
        return db.sleepEventDao().getEventsForDay(today, tomorrow)
            .map { list -> list.map { it.toDomain() } }
    }

    suspend fun saveSleepEvent(event: SleepEvent) {
        db.sleepEventDao().upsert(event.toEntity())
    }

    suspend fun getEventById(id: String): SleepEvent? =
        db.sleepEventDao().getById(id)?.toDomain()
}
