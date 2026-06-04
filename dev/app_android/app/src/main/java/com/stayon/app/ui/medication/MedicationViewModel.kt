package com.stayon.app.ui.medication

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.stayon.app.data.repository.MedicationRepository
import com.stayon.app.domain.model.Medication
import com.stayon.app.domain.model.MedicationEvent
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class MedicationUiState(
    val medications: List<Medication> = emptyList(),
    val todayEvents: List<MedicationEvent> = emptyList()
)

class MedicationViewModel(
    private val medicationRepo: MedicationRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(MedicationUiState())
    val uiState: StateFlow<MedicationUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            medicationRepo.getAllMedications().collect { meds ->
                _uiState.update { it.copy(medications = meds) }
            }
        }
        viewModelScope.launch {
            medicationRepo.getTodayEvents().collect { events ->
                _uiState.update { it.copy(todayEvents = events) }
            }
        }
    }

    fun saveMedication(medication: Medication) {
        viewModelScope.launch {
            medicationRepo.saveMedication(medication)
        }
    }

    fun deleteMedication(medication: Medication) {
        viewModelScope.launch {
            medicationRepo.deleteMedication(medication)
        }
    }

    fun updateEventStatus(eventId: String, status: String) {
        viewModelScope.launch {
            medicationRepo.updateEventStatus(
                eventId, status,
                if (status == "done" || status == "skipped") System.currentTimeMillis() else null
            )
        }
    }

    class Factory(private val medicationRepo: MedicationRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T =
            MedicationViewModel(medicationRepo) as T
    }
}
