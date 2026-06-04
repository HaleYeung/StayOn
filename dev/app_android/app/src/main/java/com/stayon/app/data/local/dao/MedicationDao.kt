package com.stayon.app.data.local.dao

import androidx.room.*
import com.stayon.app.data.local.entity.MedicationEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface MedicationDao {
    @Query("SELECT * FROM medications ORDER BY createdAt DESC")
    fun getAllMedications(): Flow<List<MedicationEntity>>

    @Query("SELECT * FROM medications ORDER BY createdAt DESC")
    suspend fun getAllMedicationsOnce(): List<MedicationEntity>

    @Query("SELECT * FROM medications WHERE id = :id")
    suspend fun getById(id: String): MedicationEntity?

    @Upsert
    suspend fun upsert(medication: MedicationEntity)

    @Delete
    suspend fun delete(medication: MedicationEntity)
}
