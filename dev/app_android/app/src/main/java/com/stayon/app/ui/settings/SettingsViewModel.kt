package com.stayon.app.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.stayon.app.data.repository.SettingsRepository
import com.stayon.app.domain.model.AppSettings
import com.stayon.app.domain.util.NotificationTextBuilder
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class SettingsUiState(
    val settings: AppSettings = AppSettings()
)

class SettingsViewModel(
    private val settingsRepo: SettingsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            settingsRepo.getSettings().collect { s ->
                if (s != null) {
                    _uiState.value = SettingsUiState(settings = s)
                    val tone = com.stayon.app.domain.enums.ToneStyle.from(s.toneStyle)
                    NotificationTextBuilder.currentStyle = tone
                }
            }
        }
    }

    fun updateToneStyle(toneStyle: String) {
        viewModelScope.launch {
            val updated = _uiState.value.settings.copy(toneStyle = toneStyle)
            settingsRepo.saveSettings(updated)
            _uiState.value = SettingsUiState(settings = updated)
        }
    }

    fun updateSnoozeMinutes(minutes: Int) {
        viewModelScope.launch {
            val updated = _uiState.value.settings.copy(defaultSnoozeMinutes = minutes)
            settingsRepo.saveSettings(updated)
            _uiState.value = SettingsUiState(settings = updated)
        }
    }

    fun updateMaxSnoozeCount(count: Int) {
        viewModelScope.launch {
            val updated = _uiState.value.settings.copy(defaultMaxSnoozeCount = count)
            settingsRepo.saveSettings(updated)
            _uiState.value = SettingsUiState(settings = updated)
        }
    }

    fun addMealTag(tag: String) {
        viewModelScope.launch {
            val tags = _uiState.value.settings.mealTemplateTags + tag
            val updated = _uiState.value.settings.copy(mealTemplateTags = tags)
            settingsRepo.saveSettings(updated)
            _uiState.value = SettingsUiState(settings = updated)
        }
    }

    fun removeMealTag(tag: String) {
        viewModelScope.launch {
            val tags = _uiState.value.settings.mealTemplateTags - tag
            val updated = _uiState.value.settings.copy(mealTemplateTags = tags)
            settingsRepo.saveSettings(updated)
            _uiState.value = SettingsUiState(settings = updated)
        }
    }

    class Factory(private val settingsRepo: SettingsRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T =
            SettingsViewModel(settingsRepo) as T
    }
}
