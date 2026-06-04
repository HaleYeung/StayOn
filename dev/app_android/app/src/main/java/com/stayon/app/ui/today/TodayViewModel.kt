package com.stayon.app.ui.today

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.stayon.app.data.repository.MealRepository
import com.stayon.app.data.repository.MedicationRepository
import com.stayon.app.data.repository.SleepRepository
import com.stayon.app.domain.model.*
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class TodayUiState(
    val medicationEvents: List<MedicationEvent> = emptyList(),
    val sleepEvents: List<SleepEvent> = emptyList(),
    val mealEvents: List<MealEvent> = emptyList(),
    val mealRules: List<MealRule> = emptyList(),
    val nightSnackEvent: NightSnackEvent? = null
)

class TodayViewModel(
    private val medicationRepo: MedicationRepository,
    private val sleepRepo: SleepRepository,
    private val mealRepo: MealRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(TodayUiState())
    val uiState: StateFlow<TodayUiState> = _uiState.asStateFlow()

    val pendingMedicationEvents: StateFlow<List<MedicationEvent>> = _uiState
        .map { it.medicationEvents.filter { e -> e.status == "pending" } }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    init {
        viewModelScope.launch {
            medicationRepo.getTodayEvents().collect { events ->
                _uiState.update { it.copy(medicationEvents = events) }
            }
        }
        viewModelScope.launch {
            sleepRepo.getTodayEvents().collect { events ->
                _uiState.update { it.copy(sleepEvents = events) }
            }
        }
        viewModelScope.launch {
            mealRepo.getTodayMealEvents().collect { events ->
                _uiState.update { it.copy(mealEvents = events) }
            }
        }
        viewModelScope.launch {
            mealRepo.getAllRules().collect { rules ->
                _uiState.update { it.copy(mealRules = rules) }
            }
        }
        viewModelScope.launch {
            mealRepo.getNightSnackEvents().collect { events ->
                val today = java.time.LocalDate.now().toString()
                val ns = events.firstOrNull { it.date == today }
                _uiState.update { it.copy(nightSnackEvent = ns) }
            }
        }
    }

    fun confirmMedication(eventId: String, newStatus: String) {
        viewModelScope.launch {
            val confirmedAt = if (newStatus != "pending") System.currentTimeMillis() else null
            medicationRepo.updateEventStatus(eventId, newStatus, confirmedAt)
        }
    }

    fun confirmSleep() {
        viewModelScope.launch {
            val existing = uiState.value.sleepEvents.firstOrNull()
            if (existing != null) {
                sleepRepo.saveSleepEvent(existing.copy(status = "confirmed", confirmedAt = System.currentTimeMillis()))
            } else {
                val today = java.time.LocalDate.now().toString()
                val now = System.currentTimeMillis()
                sleepRepo.saveSleepEvent(SleepEvent(
                    date = today, targetBedtime = now, preReminderAt = now,
                    finalReminderAt = now, status = "confirmed", confirmedAt = now
                ))
            }
        }
    }

    fun acknowledgeMeal(mealType: String, tags: List<String>, note: String?) {
        viewModelScope.launch {
            mealRepo.saveMealEvent(MealEvent(
                mealType = mealType, scheduledAt = System.currentTimeMillis(),
                status = "acknowledged", acknowledgedAt = System.currentTimeMillis(),
                tagsSnapshot = tags, noteSnapshot = note
            ))
        }
    }

    fun recordNightSnack(status: String) {
        viewModelScope.launch {
            val existing = mealRepo.getTodayNightSnack()
            if (existing != null) {
                mealRepo.saveNightSnackEvent(
                    existing.copy(status = status, recordedAt = System.currentTimeMillis())
                )
            } else {
                val today = java.time.LocalDate.now().toString()
                mealRepo.saveNightSnackEvent(
                    NightSnackEvent(
                        date = today,
                        reminderAt = System.currentTimeMillis(),
                        status = status,
                        recordedAt = System.currentTimeMillis()
                    )
                )
            }
        }
    }

    class Factory(
        private val medicationRepo: MedicationRepository,
        private val sleepRepo: SleepRepository,
        private val mealRepo: MealRepository
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T =
            TodayViewModel(medicationRepo, sleepRepo, mealRepo) as T
    }
}
