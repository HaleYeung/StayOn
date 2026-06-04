# StayOn (别乱来) — Android 版

> 本地、轻量、原生、可长期使用的健康监督工具
> 从 iOS SwiftUI 移植至 Android 原生 Kotlin + Jetpack Compose

---

## 一、技术方案

| 层级 | 选型 | 说明 |
|------|------|------|
| 语言 | Kotlin 1.9+ | |
| UI | Jetpack Compose + Material 3 | 跟随系统深色模式 |
| 架构 | MVVM (ViewModel + Repository + Room) | |
| 本地数据库 | Room | 对应 iOS SwiftData |
| 轻配置 | Jetpack DataStore (Preferences) | 对应 iOS AppStorage |
| 导航 | Navigation Compose (NavHost) | 底部导航 + 页面跳转 |
| 定时提醒 | AlarmManager + BroadcastReceiver | 精确闹钟（SCHEDULE_EXACT_ALARM） |
| 后台补偿 | WorkManager | 启动时事件校正、前一天未确认结算 |
| 时间处理 | java.time (LocalDate, LocalTime) | |
| DI | 手动依赖注入（首版） | 后续可升级 Hilt |
| 构建 | Gradle KTS + Version Catalog | |

### 对应关系（iOS → Android）

| iOS | Android |
|-----|---------|
| SwiftData @Model | Room @Entity |
| SwiftData @Query | Room DAO + Flow |
| SwiftUI View | Composable @Composable |
| SwiftUI TabView + NavigationStack | Scaffold + NavigationBar + NavHost |
| ObservableObject / @State | ViewModel + StateFlow / MutableState |
| UserNotifications | AlarmManager + PendingIntent + NotificationManager |
| AppStorage | DataStore Preferences |
| SwiftUI dark mode | Material3 dynamicColor + darkColorScheme |

---

## 二、Gradle 配置建议

### 最小依赖清单

```kotlin
// build.gradle.kts (app)
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp") // Room annotation processor
}

android {
    namespace = "com.stayon.app"
    compileSdk = 34
    defaultConfig {
        minSdk = 26  // java.time 需要
        targetSdk = 34
    }
    buildFeatures { compose = true }
    composeOptions { kotlinCompilerExtensionVersion = "1.5.8" }
}

dependencies {
    // Compose BOM
    val composeBom = platform("androidx.compose:compose-bom:2024.02.00")
    implementation(composeBom)
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("androidx.navigation:navigation-compose:2.7.7")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.7.0")

    // Room
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")

    // DataStore
    implementation("androidx.datastore:datastore-preferences:1.0.0")

    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.9.0")
}
```

---

## 三、包结构 / 目录结构

```text
app/src/main/java/com/stayon/app/
├── StayOnApplication.kt                 // Application class
├── MainActivity.kt                      // Single Activity
│
├── navigation/
│   ├── AppNavigation.kt                 // NavHost + 路由定义
│   └── BottomNavItem.kt                 // 底部导航项 sealed class
│
├── ui/
│   ├── theme/
│   │   ├── Theme.kt                     // Material3 主题 + 深色模式
│   │   ├── Color.kt
│   │   └── Type.kt
│   │
│   ├── components/
│   │   ├── StatusCard.kt               // 通用状态卡片
│   │   ├── PermissionBanner.kt         // 通知权限提示条
│   │   ├── EmptyStateView.kt
│   │   ├── ConfirmDialog.kt
│   │   └── StatusBadge.kt             // 状态胶囊组件
│   │
│   ├── today/
│   │   ├── TodayScreen.kt              // 首页
│   │   └── TodayViewModel.kt
│   │
│   ├── medication/
│   │   ├── MedicationListScreen.kt
│   │   ├── MedicationFormScreen.kt
│   │   ├── MedicationEventDetailScreen.kt
│   │   └── MedicationViewModel.kt
│   │
│   ├── routine/
│   │   ├── RoutineScreen.kt            // 作息页（路由入口）
│   │   ├── SleepSettingsScreen.kt
│   │   ├── MealRuleListScreen.kt
│   │   ├── MealRuleEditScreen.kt
│   │   ├── NightSnackSettingsScreen.kt
│   │   └── RoutineViewModel.kt
│   │
│   ├── history/
│   │   ├── HistoryScreen.kt
│   │   ├── HistoryDayDetailScreen.kt
│   │   ├── FullLogScreen.kt
│   │   └── HistoryViewModel.kt
│   │
│   └── settings/
│       ├── SettingsScreen.kt
│       ├── MealTagManageScreen.kt
│       └── SettingsViewModel.kt
│
├── data/
│   ├── local/
│   │   ├── AppDatabase.kt              // Room Database
│   │   ├── dao/
│   │   │   ├── MedicationDao.kt
│   │   │   ├── MedicationEventDao.kt
│   │   │   ├── SleepPlanDao.kt
│   │   │   ├── SleepEventDao.kt
│   │   │   ├── MealRuleDao.kt
│   │   │   ├── MealEventDao.kt
│   │   │   ├── NightSnackEventDao.kt
│   │   │   └── AppSettingsDao.kt
│   │   └── entity/
│   │       ├── MedicationEntity.kt
│   │       ├── MedicationEventEntity.kt
│   │       ├── SleepPlanEntity.kt
│   │       ├── SleepEventEntity.kt
│   │       ├── MealRuleEntity.kt
│   │       ├── MealEventEntity.kt
│   │       ├── NightSnackEventEntity.kt
│   │       └── AppSettingsEntity.kt
│   │
│   ├── repository/
│   │   ├── MedicationRepository.kt
│   │   ├── SleepRepository.kt
│   │   ├── MealRepository.kt
│   │   ├── HistoryRepository.kt
│   │   └── SettingsRepository.kt
│   │
│   └── preferences/
│       └── AppPreferences.kt           // DataStore wrapper
│
├── domain/
│   ├── model/
│   │   ├── Medication.kt               // 纯净领域模型
│   │   ├── MedicationEvent.kt
│   │   ├── SleepPlan.kt
│   │   ├── SleepEvent.kt
│   │   ├── MealRule.kt
│   │   ├── MealEvent.kt
│   │   ├── NightSnackEvent.kt
│   │   └── AppSettings.kt
│   ├── enums/
│   │   ├── ScheduleType.kt
│   │   ├── MedicationEventStatus.kt
│   │   ├── SleepEventStatus.kt
│   │   ├── MealEventStatus.kt
│   │   ├── NightSnackStatus.kt
│   │   ├── MealType.kt
│   │   └── ToneStyle.kt
│   └── util/
│       ├── DateUtils.kt
│       ├── StreakCalculator.kt
│       └── NotificationTextBuilder.kt
│
├── service/
│   ├── notification/
│   │   ├── NotificationHelper.kt       // NotificationChannel + 通知构建
│   │   ├── AlarmScheduler.kt           // AlarmManager 调度
│   │   ├── NotificationActionReceiver.kt // BroadcastReceiver 处理按钮
│   │   └── BootReceiver.kt             // 开机后重建提醒
│   │
│   └── worker/
│       ├── DailyEventWorker.kt         // WorkManager 每日事件生成
│       └── MidnightSettlementWorker.kt // 次日 00:00 未确认结算
│
└── res/
    ├── values/
    │   ├── strings.xml
    │   └── themes.xml
    └── drawable/
        └── ic_launcher.xml
```

**关键设计原则**：
- Entity = Room 持久化模型（含 `@Entity` 注解）
- domain/model = 纯净 Kotlin data class，与 Entity 之间通过 mapper 转换
- Repository 层通过 Flow 对外暴露数据
- ViewModel 持有 repository，对外暴露 StateFlow

---

## 四、Room Entity / DAO / Database 设计

### 4.1 Room Entity 定义

所有 Entity 映射自 iOS SwiftData 模型，字段完全对齐。

```kotlin
// MedicationEntity.kt
@Entity(tableName = "medications")
data class MedicationEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val name: String,
    val dosageText: String? = null,
    val scheduleType: String = "daily",        // "daily" | "weekly"
    val weekdays: String = "[]",               // JSON array stored as String
    val timesPerDay: Int = 1,
    val reminderTimes: String = "[]",          // JSON array of ISO time strings
    val mealNote: String? = null,              // "none" | "beforeMeal" | "afterMeal"
    val note: String? = null,
    val isActive: Boolean = true,
    val snoozeIntervalMinutes: Int = 10,
    val maxSnoozeCount: Int = 1,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)
```

```kotlin
// MedicationEventEntity.kt
@Entity(
    tableName = "medication_events",
    indices = [Index(value = ["medicationId"])]
)
data class MedicationEventEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val medicationId: String,
    val medicationName: String = "",
    val dosageText: String? = null,
    val scheduledAt: Long,                          // epoch millis
    val status: String = "pending",                 // "pending" | "done" | "skipped" | "unconfirmed"
    val confirmedAt: Long? = null,
    val skippedAt: Long? = null,
    val snoozeCount: Int = 0,
    val maxSnoozeCount: Int = 1,
    val lastNotificationAt: Long? = null,
    val createdAt: Long = System.currentTimeMillis()
)
```

```kotlin
// SleepPlanEntity.kt
@Entity(tableName = "sleep_plans")
data class SleepPlanEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val bedtimeHour: Int,                            // 0-23
    val bedtimeMinute: Int,                          // 0-59
    val preReminderMinutes: Int = 30,
    val snoozeIntervalMinutes: Int = 10,
    val maxSnoozeCount: Int = 1,
    val isActive: Boolean = true,
    val updatedAt: Long = System.currentTimeMillis()
)
```

```kotlin
// SleepEventEntity.kt
@Entity(tableName = "sleep_events")
data class SleepEventEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val date: String,                                // ISO date "2026-06-03"
    val targetBedtime: Long,
    val preReminderAt: Long,
    val finalReminderAt: Long,
    val status: String = "pending",                  // "pending" | "confirmed" | "unconfirmed"
    val confirmedAt: Long? = null,
    val snoozeCount: Int = 0,
    val maxSnoozeCount: Int = 1,
    val lastNotificationAt: Long? = null,
    val createdAt: Long = System.currentTimeMillis()
)
```

```kotlin
// MealRuleEntity.kt
@Entity(tableName = "meal_rules")
data class MealRuleEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val mealType: String,                            // "breakfast" | "lunch" | "dinner" | "nightSnack"
    val reminderHour: Int,
    val reminderMinute: Int,
    val templateTags: String = "[]",                 // JSON array
    val customNote: String? = null,
    val isActive: Boolean = true,
    val updatedAt: Long = System.currentTimeMillis()
)
```

```kotlin
// MealEventEntity.kt
@Entity(tableName = "meal_events")
data class MealEventEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val mealType: String,
    val scheduledAt: Long,
    val status: String = "pending",                  // "pending" | "acknowledged" | "unconfirmed"
    val acknowledgedAt: Long? = null,
    val noteSnapshot: String? = null,
    val tagsSnapshot: String = "[]",
    val createdAt: Long = System.currentTimeMillis()
)
```

```kotlin
// NightSnackEventEntity.kt
@Entity(tableName = "night_snack_events")
data class NightSnackEventEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val date: String,                                // ISO date
    val reminderAt: Long,
    val status: String = "unset",                    // "unset" | "noSnack" | "ateSnack"
    val recordedAt: Long? = null
)
```

```kotlin
// AppSettingsEntity.kt
@Entity(tableName = "app_settings")
data class AppSettingsEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val defaultSnoozeMinutes: Int = 10,
    val defaultMaxSnoozeCount: Int = 1,
    val toneStyle: String = "light_supervision",
    val hasSeenNotificationPrompt: Boolean = false,
    val mealTemplateTags: String = "[]"              // JSON array
)
```

### 4.2 DAO 示例

```kotlin
@Dao
interface MedicationDao {
    @Query("SELECT * FROM medications ORDER BY createdAt DESC")
    fun getAllMedications(): Flow<List<MedicationEntity>>

    @Query("SELECT * FROM medications WHERE id = :id")
    suspend fun getById(id: String): MedicationEntity?

    @Upsert
    suspend fun upsert(medication: MedicationEntity)

    @Delete
    suspend fun delete(medication: MedicationEntity)
}

@Dao
interface MedicationEventDao {
    @Query("SELECT * FROM medication_events WHERE scheduledAt >= :dayStart AND scheduledAt < :dayEnd ORDER BY scheduledAt ASC")
    fun getEventsForDay(dayStart: Long, dayEnd: Long): Flow<List<MedicationEventEntity>>

    @Query("SELECT * FROM medication_events WHERE id = :id")
    suspend fun getById(id: String): MedicationEventEntity?

    @Upsert
    suspend fun upsert(event: MedicationEventEntity)

    @Query("UPDATE medication_events SET status = :status, confirmedAt = :confirmedAt WHERE id = :id")
    suspend fun updateStatus(id: String, status: String, confirmedAt: Long?)

    @Query("UPDATE medication_events SET status = 'unconfirmed' WHERE scheduledAt < :before AND status = 'pending'")
    suspend fun settlePendingBefore(before: Long)
}
```

### 4.3 Database

```kotlin
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
abstract class AppDatabase : RoomDatabase() {
    abstract fun medicationDao(): MedicationDao
    abstract fun medicationEventDao(): MedicationEventDao
    abstract fun sleepPlanDao(): SleepPlanDao
    abstract fun sleepEventDao(): SleepEventDao
    abstract fun mealRuleDao(): MealRuleDao
    abstract fun mealEventDao(): MealEventDao
    abstract fun nightSnackEventDao(): NightSnackEventDao
    abstract fun appSettingsDao(): AppSettingsDao
}
```

---

## 五、第一个 Sprint 任务清单

### Sprint 1 目标：项目初始化 + 数据层 + 首页

| # | 任务 | 预估工时 |
|---|------|---------|
| 1 | 创建 Android 项目 + Gradle 配置 + Room + Compose 依赖 | 1h |
| 2 | 实现所有 8 个 Entity + TypeConverter | 1.5h |
| 3 | 实现所有 8 个 DAO | 1.5h |
| 4 | 实现 AppDatabase + Application 单例 | 0.5h |
| 5 | 实现 DataStore Preferences（AppPreferences） | 0.5h |
| 6 | 实现 domain model 纯净类 + Entity ↔ model mapper | 1h |
| 7 | 实现 Material3 主题（浅色/深色）+ Color + Typography | 0.5h |
| 8 | 实现 BottomNavItem + NavHost + 5 个占位 Screen | 1h |
| 9 | 实现 StatusCard / PermissionBanner / EmptyStateView 通用组件 | 1h |
| 10 | 实现 TodayViewModel + TodayScreen（卡片聚合，不含真实数据） | 1.5h |
| 11 | 实现 DailyEventWorker（WorkManager 生成当天事件） | 1h |
| 12 | 实现 MidnightSettlementWorker（未确认结算） | 0.5h |
| 13 | 实现 NotificationHelper + AlarmScheduler（基础骨架） | 1h |
| 14 | 端到端验证：启动 → 生成事件 → 首页展示卡片 | 1h |

**总计预估：13h**

### Sprint 1 交付物

- [ ] 项目可编译运行，显示 5 个 Tab 空页面
- [ ] Room 数据库初始化正常
- [ ] DataStore 可读写
- [ ] Material3 主题正常，跟随系统深色模式
- [ ] 首页显示卡片布局骨架（不含真实数据绑定）
- [ ] WorkManager 定时任务可注册
- [ ] AlarmManager 通知骨架可注册
