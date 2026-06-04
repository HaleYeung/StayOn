package com.stayon.app.ui.routine

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.stayon.app.data.repository.MealRepository
import com.stayon.app.data.repository.SleepRepository
import com.stayon.app.domain.model.MealRule
import com.stayon.app.domain.model.SleepPlan
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class RoutineUiState(
    val sleepPlan: SleepPlan? = null,
    val mealRules: List<MealRule> = emptyList()
)

class RoutineViewModel(
    private val sleepRepo: SleepRepository,
    private val mealRepo: MealRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(RoutineUiState())
    val uiState: StateFlow<RoutineUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            sleepRepo.getSleepPlan().collect { plan ->
                _uiState.update { it.copy(sleepPlan = plan) }
            }
        }
        viewModelScope.launch {
            mealRepo.getAllRules().collect { rules ->
                _uiState.update { it.copy(mealRules = rules) }
            }
        }
    }

    fun saveSleepPlan(plan: SleepPlan) {
        viewModelScope.launch { sleepRepo.saveSleepPlan(plan) }
    }

    fun saveMealRule(rule: MealRule) {
        viewModelScope.launch { mealRepo.saveRule(rule) }
    }

    class Factory(
        private val sleepRepo: SleepRepository,
        private val mealRepo: MealRepository
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T =
            RoutineViewModel(sleepRepo, mealRepo) as T
    }
}
