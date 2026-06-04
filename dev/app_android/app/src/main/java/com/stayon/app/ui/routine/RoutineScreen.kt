package com.stayon.app.ui.routine

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

data class SleepSettingsState(
    val isActive: Boolean = false,
    val bedtimeHour: Int = 23,
    val bedtimeMinute: Int = 30,
    val preReminderMinutes: Int = 30,
    val snoozeIntervalMinutes: Int = 10,
    val maxSnoozeCount: Int = 1
) {
    val bedtimeDisplay: String get() = String.format("%02d:%02d", bedtimeHour, bedtimeMinute)
}

@Composable
fun RoutineScreen(
    onNavigateToSleep: () -> Unit = {},
    onNavigateToMeals: () -> Unit = {},
    onNavigateToNightSnack: () -> Unit = {}
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Card(modifier = Modifier.fillMaxWidth().clickable { onNavigateToSleep() }) {
            Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.Bedtime, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
                Spacer(Modifier.width(12.dp))
                Column { Text("睡觉提醒", style = MaterialTheme.typography.titleSmall); Text("目标时间、预提醒、追提醒", style = MaterialTheme.typography.bodySmall) }
            }
        }
        Card(modifier = Modifier.fillMaxWidth().clickable { onNavigateToMeals() }) {
            Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.Restaurant, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
                Spacer(Modifier.width(12.dp))
                Column { Text("饮食提醒", style = MaterialTheme.typography.titleSmall); Text("三餐模板标签、备注", style = MaterialTheme.typography.bodySmall) }
            }
        }
        Card(modifier = Modifier.fillMaxWidth().clickable { onNavigateToNightSnack() }) {
            Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.Nightlight, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
                Spacer(Modifier.width(12.dp))
                Column { Text("夜宵提醒", style = MaterialTheme.typography.titleSmall); Text("提醒时间设置", style = MaterialTheme.typography.bodySmall) }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SleepSettingsScreen(
    state: SleepSettingsState = SleepSettingsState(),
    onSave: (SleepSettingsState) -> Unit = {},
    onBack: () -> Unit = {}
) {
    var isActive by remember { mutableStateOf(state.isActive) }
    var bedtimeHour by remember { mutableStateOf(state.bedtimeHour) }
    var bedtimeMinute by remember { mutableStateOf(state.bedtimeMinute) }
    var preReminderMinutes by remember { mutableStateOf(state.preReminderMinutes) }
    var snoozeIntervalMinutes by remember { mutableStateOf(state.snoozeIntervalMinutes) }
    var maxSnoozeCount by remember { mutableStateOf(state.maxSnoozeCount) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Card(modifier = Modifier.fillMaxWidth()) {
            Row(Modifier.fillMaxWidth().padding(16.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("启用提醒", style = MaterialTheme.typography.bodyLarge)
                Switch(checked = isActive, onCheckedChange = { isActive = it })
            }
        }

        Card(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("目标睡觉时间", style = MaterialTheme.typography.titleSmall)
                Text(String.format("%02d:%02d", bedtimeHour, bedtimeMinute), style = MaterialTheme.typography.headlineMedium)
                Spacer(Modifier.height(8.dp))
                Text("预提醒提前 ${preReminderMinutes} 分钟")
                Slider(value = preReminderMinutes.toFloat(), onValueChange = { preReminderMinutes = it.toInt() }, valueRange = 10f..60f, steps = 10)
            }
        }

        Card(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("追提醒设置", style = MaterialTheme.typography.titleSmall)
                Text("间隔：${snoozeIntervalMinutes} 分钟")
                Slider(value = snoozeIntervalMinutes.toFloat(), onValueChange = { snoozeIntervalMinutes = it.toInt() }, valueRange = 5f..30f, steps = 5)
                Text("最大追提醒次数：${maxSnoozeCount}")
                Slider(value = maxSnoozeCount.toFloat(), onValueChange = { maxSnoozeCount = it.toInt() }, valueRange = 1f..5f, steps = 4)
            }
        }

        Card(modifier = Modifier.fillMaxWidth()) {
            Text("到点后你可以点「晚安」确认入睡。\n若未确认，会按设置进行轻提醒。\n第一版不记录睡眠时长。",
                style = MaterialTheme.typography.bodySmall, modifier = Modifier.padding(16.dp))
        }

        Button(onClick = { onSave(SleepSettingsState(isActive, bedtimeHour, bedtimeMinute, preReminderMinutes, snoozeIntervalMinutes, maxSnoozeCount)); onBack() },
            modifier = Modifier.fillMaxWidth()) { Text("保存") }
    }
}
