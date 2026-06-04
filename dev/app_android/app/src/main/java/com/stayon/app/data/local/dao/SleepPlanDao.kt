package com.stayon.app.data.local.dao

import androidx.room.*
import com.stayon.app.data.local.entity.SleepPlanEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface SleepPlanDao {
    @Query("SELECT * FROM sleep_plans LIMIT 1")
    fun getSleepPlan(): Flow<SleepPlanEntity?>

    @Query("SELECT * FROM sleep_plans LIMIT 1")
    suspend fun getSleepPlanOnce(): SleepPlanEntity?

    @Upsert
    suspend fun upsert(plan: SleepPlanEntity)
}
