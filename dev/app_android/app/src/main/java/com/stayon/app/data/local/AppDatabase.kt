package com.stayon.app.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.stayon.app.data.local.dao.*
import com.stayon.app.data.local.entity.*

@Database(
    entities = [
        MedicationEntity::class,
        MedicationEventEntity::class,
        SleepPlanEntity::class,
        SleepEventEntity::class,
        MealRuleEntity::class,
        MealEventEntity::class,
        NightSnackEventEntity::class,
        AppSettingsEntity::class
    ],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun medicationDao(): MedicationDao
    abstract fun medicationEventDao(): MedicationEventDao
    abstract fun sleepPlanDao(): SleepPlanDao
    abstract fun sleepEventDao(): SleepEventDao
    abstract fun mealRuleDao(): MealRuleDao
    abstract fun mealEventDao(): MealEventDao
    abstract fun nightSnackEventDao(): NightSnackEventDao
    abstract fun appSettingsDao(): AppSettingsDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getInstance(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "stayon.db"
                )
                    .fallbackToDestructiveMigration()
                    .build()
                    .also { INSTANCE = it }
            }
        }
    }
}
