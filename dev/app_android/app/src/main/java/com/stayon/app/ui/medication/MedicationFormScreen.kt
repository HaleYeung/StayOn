package com.stayon.app.ui.medication

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.stayon.app.domain.model.Medication
import com.stayon.app.ui.theme.RedStatus
import java.time.LocalTime
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MedicationFormScreen(
    existingMedication: Medication? = null,
    onSave: (Medication) -> Unit = {},
    onDelete: (Medication) -> Unit = {},
    onBack: () -> Unit = {}
) {
    var name by remember { mutableStateOf(existingMedication?.name ?: "") }
    var dosageText by remember { mutableStateOf(existingMedication?.dosageText ?: "") }
    var scheduleType by remember { mutableStateOf(existingMedication?.scheduleType ?: "daily") }
    var selectedWeekdays by remember { mutableStateOf(existingMedication?.weekdays?.toSet() ?: emptySet()) }
    var timesPerDay by remember { mutableStateOf(existingMedication?.timesPerDay ?: 1) }
    var reminderTimes by remember {
        mutableStateOf(
            if (existingMedication?.reminderTimes?.isNotEmpty() == true) existingMedication.reminderTimes
            else listOf(LocalTime.of(8, 0))
        )
    }
    var mealNote by remember { mutableStateOf(existingMedication?.mealNote ?: "none") }
    var note by remember { mutableStateOf(existingMedication?.note ?: "") }
    var isActive by remember { mutableStateOf(existingMedication?.isActive ?: true) }
    var snoozeInterval by remember { mutableStateOf(existingMedication?.snoozeIntervalMinutes ?: 10) }
    var maxSnooze by remember { mutableStateOf(existingMedication?.maxSnoozeCount ?: 1) }
    var showDeleteDialog by remember { mutableStateOf(false) }

    val isEditing = existingMedication != null
    val weekNames = listOf("一", "二", "三", "四", "五", "六", "日")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        OutlinedTextField(value = name, onValueChange = { name = it },
            label = { Text("药名（必填）") }, singleLine = true,
            modifier = Modifier.fillMaxWidth())

        OutlinedTextField(value = dosageText, onValueChange = { dosageText = it },
            label = { Text("剂量文本（选填）") }, singleLine = true,
            modifier = Modifier.fillMaxWidth())

        Card(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("服用计划", style = MaterialTheme.typography.titleSmall)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("频率", style = MaterialTheme.typography.bodyMedium)
                    Spacer(Modifier.width(16.dp))
                    FilterChip(selected = scheduleType == "daily", onClick = { scheduleType = "daily" }, label = { Text("每天") })
                    Spacer(Modifier.width(8.dp))
                    FilterChip(selected = scheduleType == "weekly", onClick = { scheduleType = "weekly" }, label = { Text("按星期") })
                }
                if (scheduleType == "weekly") {
                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        weekNames.forEachIndexed { i, n ->
                            val day = i + 1
                            FilterChip(selected = day in selectedWeekdays,
                                onClick = { selectedWeekdays = if (day in selectedWeekdays) selectedWeekdays - day else selectedWeekdays + day },
                                label = { Text(n) })
                        }
                    }
                }
                Text("每天 $timesPerDay 次", style = MaterialTheme.typography.bodyMedium)
                Slider(value = timesPerDay.toFloat(), onValueChange = { timesPerDay = it.toInt() }, valueRange = 1f..10f, steps = 9)

                if (timesPerDay > 0) {
                    Spacer(Modifier.height(4.dp))
                    (0 until timesPerDay).forEach { index ->
                        val time = if (index < reminderTimes.size) reminderTimes[index] else LocalTime.of(8, 0)
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("第 ${index + 1} 次", style = MaterialTheme.typography.bodySmall,
                                modifier = Modifier.width(48.dp))
                            var showTimePicker by remember { mutableStateOf(false) }
                            TextButton(onClick = { showTimePicker = true }) {
                                Text(time.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm")),
                                    style = MaterialTheme.typography.bodyLarge)
                            }
                            if (showTimePicker) {
                                Material3DateTimePickerDialog(
                                    initialHour = time.hour,
                                    initialMinute = time.minute,
                                    onConfirm = { h, m ->
                                        while (reminderTimes.size <= index) reminderTimes = reminderTimes + LocalTime.of(8, 0)
                                        reminderTimes = reminderTimes.toMutableList().also { it[index] = LocalTime.of(h, m) }
                                        showTimePicker = false
                                    },
                                    onDismiss = { showTimePicker = false }
                                )
                            }
                        }
                    }
                }
            }
        }

        Card(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("饭前/饭后", style = MaterialTheme.typography.titleSmall)
                Spacer(Modifier.height(8.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    listOf("none" to "无", "beforeMeal" to "饭前", "afterMeal" to "饭后").forEach { (v, l) ->
                        FilterChip(selected = mealNote == v, onClick = { mealNote = v }, label = { Text(l) })
                    }
                }
            }
        }

        OutlinedTextField(value = note, onValueChange = { note = it },
            label = { Text("备注（选填）") }, modifier = Modifier.fillMaxWidth(), minLines = 2)

        Card(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("启用提醒", style = MaterialTheme.typography.bodyMedium)
                    Switch(checked = isActive, onCheckedChange = { isActive = it })
                }
                Text("稍后提醒间隔：${snoozeInterval} 分钟", style = MaterialTheme.typography.bodyMedium)
                Slider(value = snoozeInterval.toFloat(), onValueChange = { snoozeInterval = it.toInt() }, valueRange = 5f..60f, steps = 11)
                Text("最大追提醒次数：${maxSnooze}", style = MaterialTheme.typography.bodyMedium)
                Slider(value = maxSnooze.toFloat(), onValueChange = { maxSnooze = it.toInt() }, valueRange = 1f..5f, steps = 4)
            }
        }

        Button(
            onClick = {
                val med = Medication(
                    id = existingMedication?.id ?: java.util.UUID.randomUUID().toString(),
                    name = name, dosageText = dosageText.ifEmpty { null },
                    scheduleType = scheduleType, weekdays = selectedWeekdays.toList().sorted(),
                    timesPerDay = timesPerDay,
                    reminderTimes = (0 until timesPerDay).map { if (it < reminderTimes.size) reminderTimes[it] else LocalTime.of(8, 0) },
                    mealNote = if (mealNote == "none") null else mealNote,
                    note = note.ifEmpty { null }, isActive = isActive,
                    snoozeIntervalMinutes = snoozeInterval, maxSnoozeCount = maxSnooze,
                    createdAt = existingMedication?.createdAt ?: System.currentTimeMillis(),
                    updatedAt = System.currentTimeMillis()
                )
                onSave(med); onBack()
            },
            modifier = Modifier.fillMaxWidth(),
            enabled = name.isNotBlank()
        ) { Text("保存") }

        if (isEditing) {
            TextButton(onClick = { showDeleteDialog = true }, modifier = Modifier.fillMaxWidth()) {
                Icon(Icons.Filled.Delete, contentDescription = null, tint = RedStatus)
                Spacer(Modifier.width(4.dp)); Text("删除药物", color = RedStatus)
            }
        }
    }

    if (showDeleteDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteDialog = false },
            title = { Text("删除药物") },
            text = { Text("删除后历史记录会保留，但无法再创建新的服药事件。") },
            confirmButton = { TextButton(onClick = { existingMedication?.let { onDelete(it) }; showDeleteDialog = false; onBack() }) { Text("删除", color = RedStatus) } },
            dismissButton = { TextButton(onClick = { showDeleteDialog = false }) { Text("取消") } }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun Material3DateTimePickerDialog(
    initialHour: Int,
    initialMinute: Int,
    onConfirm: (Int, Int) -> Unit,
    onDismiss: () -> Unit
) {
    val state = rememberTimePickerState(
        initialHour = initialHour,
        initialMinute = initialMinute,
        is24Hour = true
    )
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("选择时间") },
        text = { TimePicker(state = state) },
        confirmButton = {
            TextButton(onClick = { onConfirm(state.hour, state.minute) }) { Text("确定") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("取消") }
        }
    )
}
