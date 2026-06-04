package com.stayon.app.navigation

import androidx.compose.animation.*
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.ui.unit.dp
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.stayon.app.StayOnApplication
import com.stayon.app.data.repository.*
import com.stayon.app.ui.today.TodayScreen
import com.stayon.app.ui.today.TodayViewModel
import com.stayon.app.ui.medication.MedicationListScreen
import com.stayon.app.ui.medication.MedicationFormScreen
import com.stayon.app.ui.medication.MedicationViewModel
import com.stayon.app.ui.routine.RoutineScreen
import com.stayon.app.ui.routine.SleepSettingsScreen
import com.stayon.app.ui.routine.SleepSettingsState
import com.stayon.app.ui.history.HistoryScreen
import com.stayon.app.ui.settings.SettingsScreen
import com.stayon.app.ui.settings.MealTagManageScreen
import com.stayon.app.domain.model.Medication
import com.stayon.app.domain.model.SleepPlan

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    val context = LocalContext.current
    val app = context.applicationContext as StayOnApplication
    val db = app.database

    val medicationRepo = remember { MedicationRepository(db) }
    val sleepRepo = remember { SleepRepository(db) }
    val mealRepo = remember { MealRepository(db) }
    val settingsRepo = remember { SettingsRepository(db) }

    val todayViewModel = remember { TodayViewModel(medicationRepo, sleepRepo, mealRepo) }
    val medicationViewModel = remember { MedicationViewModel(medicationRepo) }

    val currentRoute = currentDestination?.route
    val isMainTab = currentRoute in listOf("today", "medication", "routine", "history", "settings")

    Scaffold(
        topBar = {
            if (isMainTab) {
                val title = when (currentRoute) {
                    "today" -> "今天"; "medication" -> "药物"
                    "routine" -> "作息"; "history" -> "历史"
                    "settings" -> "设置"; else -> "别乱来"
                }
                TopAppBar(title = { Text(title) })
            }
        },
        bottomBar = {
            if (isMainTab) {
                NavigationBar {
                    BottomNavItem.entries.forEach { item ->
                        val selected = currentDestination?.hierarchy?.any { it.route == item.route } == true
                        NavigationBarItem(
                            selected = selected,
                            onClick = {
                                navController.navigate(item.route) {
                                    popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                    launchSingleTop = true; restoreState = true
                                }
                            },
                            icon = { Icon(item.icon, contentDescription = item.label) },
                            label = { Text(item.label) }
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = BottomNavItem.Today.route,
            modifier = Modifier.padding(innerPadding),
            enterTransition = { fadeIn(animationSpec = tween(300)) + slideInHorizontally(initialOffsetX = { it / 4 }) },
            exitTransition = { fadeOut(animationSpec = tween(300)) },
            popEnterTransition = { fadeIn(animationSpec = tween(300)) },
            popExitTransition = { fadeOut(animationSpec = tween(300)) + slideOutHorizontally(targetOffsetX = { it / 4 }) }
        ) {
            composable("today") { TodayScreen(viewModel = todayViewModel) }

            composable("medication") {
                MedicationListScreen(
                    viewModel = medicationViewModel,
                    onNavigateToForm = { navController.navigate("medication_form/new") },
                    onNavigateToEdit = { id -> navController.navigate("medication_form/$id") }
                )
            }
            composable("medication_form/{medicationId}") { backStackEntry ->
                val medicationId = backStackEntry.arguments?.getString("medicationId") ?: ""
                val ctx = LocalContext.current
                val existingMed = if (medicationId != "new") {
                    medicationViewModel.uiState.value.medications.find { it.id == medicationId }
                } else null
                MedicationFormScreen(
                    existingMedication = existingMed,
                    onSave = { med ->
                        medicationViewModel.saveMedication(med)
                        val db = (ctx.applicationContext as StayOnApplication).database
                        GlobalScope.launch(Dispatchers.IO) {
                            com.stayon.app.data.local.EventGenerator.generateFromPlans(db)
                        }
                        navController.popBackStack()
                    },
                    onBack = { navController.popBackStack() }
                )
            }

            composable("routine") {
                RoutineScreen(
                    onNavigateToSleep = { navController.navigate("sleep_settings") },
                    onNavigateToMeals = { navController.navigate("meal_rules") },
                    onNavigateToNightSnack = { navController.navigate("night_snack_settings") }
                )
            }
            composable("sleep_settings") {
                SleepSettingsScreen(
                    onSave = { state ->
                        val plan = SleepPlan(
                            bedtimeHour = state.bedtimeHour, bedtimeMinute = state.bedtimeMinute,
                            preReminderMinutes = state.preReminderMinutes, isActive = state.isActive,
                            snoozeIntervalMinutes = state.snoozeIntervalMinutes, maxSnoozeCount = state.maxSnoozeCount
                        )
                        // TODO: save via sleepRepo
                        navController.popBackStack()
                    },
                    onBack = { navController.popBackStack() }
                )
            }
            composable("meal_rules") {
                // TODO: MealRule list/edit screen
                Text("饮食提醒 - 待实现", modifier = Modifier.padding(16.dp))
            }
            composable("night_snack_settings") {
                // TODO: Night snack settings screen
                Text("夜宵提醒 - 待实现", modifier = Modifier.padding(16.dp))
            }

            composable("history") { HistoryScreen() }

            composable("settings") {
                SettingsScreen(
                    onNavigateToMealTags = { navController.navigate("meal_tags") }
                )
            }
            composable("meal_tags") {
                MealTagManageScreen(
                    onBack = { navController.popBackStack() }
                )
            }
        }
    }
}
