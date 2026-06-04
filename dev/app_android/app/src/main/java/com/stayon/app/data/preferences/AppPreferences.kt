package com.stayon.app.data.preferences

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "stayon_prefs")

class AppPreferences(private val context: Context) {

    val hasSeenNotificationPrompt: Flow<Boolean> = context.dataStore.data.map { prefs ->
        prefs[KEY_NOTIFICATION_PROMPT] ?: false
    }

    suspend fun setHasSeenNotificationPrompt(value: Boolean) {
        context.dataStore.edit { it[KEY_NOTIFICATION_PROMPT] = value }
    }

    companion object {
        private val KEY_NOTIFICATION_PROMPT = booleanPreferencesKey("has_seen_notification_prompt")
    }
}
