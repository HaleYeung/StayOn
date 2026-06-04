package com.stayon.app.data.repository

import com.stayon.app.data.local.AppDatabase
import com.stayon.app.data.local.toDomain
import com.stayon.app.domain.model.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class HistoryRepository(private val db: AppDatabase) {

    fun getAllMedicationEvents(): Flow<List<MedicationEvent>> =
        db.medicationEventDao().getAllEvents().map { list -> list.map { it.toDomain() } }

    fun getAllSleepEvents(): Flow<List<SleepEvent>> =
        db.sleepEventDao().getAllEvents().map { list -> list.map { it.toDomain() } }

    fun getAllMealEvents(): Flow<List<MealEvent>> =
        db.mealEventDao().getAllEvents().map { list -> list.map { it.toDomain() } }

    fun getAllNightSnackEvents(): Flow<List<NightSnackEvent>> =
        db.nightSnackEventDao().getAllEvents().map { list -> list.map { it.toDomain() } }
}
