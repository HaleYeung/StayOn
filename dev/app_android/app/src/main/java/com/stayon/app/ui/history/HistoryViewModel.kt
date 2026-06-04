package com.stayon.app.ui.history

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.stayon.app.data.repository.HistoryRepository
import com.stayon.app.data.repository.MealRepository
import com.stayon.app.domain.model.*
import com.stayon.app.domain.util.StreakCalculator
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class HistoryUiState(
    val medicationEvents: List<MedicationEvent> = emptyList(),
    val sleepEvents: List<SleepEvent> = emptyList(),
    val mealEvents: List<MealEvent> = emptyList(),
    val nightSnackEvents: List<NightSnackEvent> = emptyList(),
    val activeMealTypes: Set<String> = emptySet()
) {
    val currentStreak: Int get() = StreakCalculator.currentStreak(
        medicationEvents, sleepEvents, mealEvents, activeMealTypes
    )
    val longestStreak: Int get() = StreakCalculator.longestStreak(
        medicationEvents, sleepEvents, mealEvents, activeMealTypes
    )
}

class HistoryViewModel(
    private val historyRepo: HistoryRepository,
    private val mealRepo: MealRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HistoryUiState())
    val uiState: StateFlow<HistoryUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            combine(
                historyRepo.getAllMedicationEvents(),
                historyRepo.getAllSleepEvents(),
                historyRepo.getAllMealEvents(),
                historyRepo.getAllNightSnackEvents(),
                mealRepo.getAllRules()
            ) { meds, sleeps, meals, ns, rules ->
                HistoryUiState(
                    medicationEvents = meds,
                    sleepEvents = sleeps,
                    mealEvents = meals,
                    nightSnackEvents = ns,
                    activeMealTypes = rules.filter { it.isActive }.map { it.mealType }.toSet()
                )
            }.collect { state ->
                _uiState.value = state
            }
        }
    }

    class Factory(
        private val historyRepo: HistoryRepository,
        private val mealRepo: MealRepository
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T =
            HistoryViewModel(historyRepo, mealRepo) as T
    }
}
