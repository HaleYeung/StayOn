package com.stayon.app.data.repository

import com.stayon.app.data.local.AppDatabase
import com.stayon.app.data.local.toDomain
import com.stayon.app.data.local.toEntity
import com.stayon.app.domain.model.Medication
import com.stayon.app.domain.model.MedicationEvent
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class MedicationRepository(private val db: AppDatabase) {

    fun getAllMedications(): Flow<List<Medication>> =
        db.medicationDao().getAllMedications().map { list -> list.map { it.toDomain() } }

    suspend fun getMedicationById(id: String): Medication? =
        db.medicationDao().getById(id)?.toDomain()

    suspend fun saveMedication(medication: Medication) {
        db.medicationDao().upsert(medication.toEntity())
    }

    suspend fun deleteMedication(medication: Medication) {
        db.medicationDao().delete(medication.toEntity())
    }

    fun getTodayEvents(): Flow<List<MedicationEvent>> {
        val now = java.time.LocalDate.now()
        val start = now.atStartOfDay(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli()
        val end = now.plusDays(1).atStartOfDay(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli()
        return db.medicationEventDao().getEventsForDay(start, end)
            .map { list -> list.map { it.toDomain() } }
    }

    suspend fun getEventById(id: String): MedicationEvent? =
        db.medicationEventDao().getById(id)?.toDomain()

    suspend fun updateEventStatus(id: String, status: String, confirmedAt: Long?) {
        db.medicationEventDao().updateStatus(id, status, confirmedAt)
    }
}
