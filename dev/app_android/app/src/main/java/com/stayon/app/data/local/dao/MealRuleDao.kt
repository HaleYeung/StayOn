package com.stayon.app.data.local.dao

import androidx.room.*
import com.stayon.app.data.local.entity.MealRuleEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface MealRuleDao {
    @Query("SELECT * FROM meal_rules ORDER BY reminderHour ASC")
    fun getAllRules(): Flow<List<MealRuleEntity>>

    @Query("SELECT * FROM meal_rules ORDER BY reminderHour ASC")
    suspend fun getAllRulesOnce(): List<MealRuleEntity>

    @Query("SELECT * FROM meal_rules WHERE id = :id")
    suspend fun getById(id: String): MealRuleEntity?

    @Query("SELECT * FROM meal_rules WHERE mealType = :mealType LIMIT 1")
    suspend fun getByMealType(mealType: String): MealRuleEntity?

    @Upsert
    suspend fun upsert(rule: MealRuleEntity)

    @Delete
    suspend fun delete(rule: MealRuleEntity)
}
