package com.stayon.app.ui.today

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.stayon.app.domain.model.MedicationEvent
import com.stayon.app.ui.components.StatusCard
import com.stayon.app.ui.theme.*
import java.time.LocalTime
import java.time.LocalDate
import java.time.ZoneId

@Composable
fun TodayScreen(viewModel: TodayViewModel) {
    val uiState by viewModel.uiState.collectAsState()

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // ── TodayStatusCard ──
        item {
            val events = uiState.medicationEvents
            val doneCount = events.count { it.status == "done" }
            val pendingCount = events.count { it.status == "pending" }
            val sleepConfirmed = uiState.sleepEvents.any { it.status == "confirmed" }
            val mealCount = uiState.mealEvents.count { it.status == "acknowledged" }
            val activeRules = uiState.mealRules.count { it.isActive && it.mealType != "nightSnack" }

            val summaryText = when {
                pendingCount > 0 -> "药还差 $pendingCount 次，别拖。"
                !sleepConfirmed -> "今晚早点收，别又熬。"
                events.isEmpty() && activeRules == 0 -> "今天没有计划，记得去设置。"
                else -> "今天还稳，继续保持。"
            }
            StatusCard(title = "今日概览", icon = Icons.Filled.WbSunny, iconColor = OrangeStatus) {
                Text(summaryText, style = MaterialTheme.typography.bodyMedium)
                if (events.isNotEmpty() || sleepConfirmed || activeRules > 0) {
                    HorizontalDivider(modifier = Modifier.padding(vertical = 4.dp))
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                        SummaryItem("$doneCount/${events.size}", "药物", MedicationColor)
                        SummaryItem(if (sleepConfirmed) "✓" else "○", "晚安",
                            if (sleepConfirmed) GreenStatus else GreyStatus)
                        SummaryItem("$mealCount/$activeRules", "饮食", MealColor)
                    }
                }
            }
        }

        // ── NextMedicationCard (pending only) ──
        val nextPending = uiState.medicationEvents.firstOrNull { it.status == "pending" }
        if (nextPending != null) {
            item { MedicationEventCard(event = nextPending, viewModel = viewModel) }
        }

        // ── MealReminderCard with "知道了" button ──
        item {
            val now = LocalTime.now()
            val nowSec = now.toSecondOfDay()
            val meal = uiState.mealRules.firstOrNull { r ->
                r.isActive && r.mealType != "nightSnack"
            }
            val isMealTime = meal?.let {
                val t = LocalTime.of(it.reminderHour, it.reminderMinute)
                val d = nowSec - t.toSecondOfDay(); d >= -3600 && d <= 10800
            } ?: false
            if (meal != null && isMealTime) {
                val name = when (meal.mealType) { "breakfast"->"早餐";"lunch"->"午餐";"dinner"->"晚餐";else->meal.mealType }
                StatusCard(title = "${name}前提醒", icon = Icons.Filled.Restaurant, iconColor = MealColor) {
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically) {
                        Column {
                            meal.templateTags.forEach { tag ->
                                Text(tag, style = MaterialTheme.typography.bodySmall,
                                    color = MealColor)
                            }
                            if (!meal.customNote.isNullOrEmpty())
                                Text(meal.customNote, style = MaterialTheme.typography.bodySmall)
                        }
                        Button(onClick = { viewModel.acknowledgeMeal(meal.mealType, meal.templateTags, meal.customNote) }) {
                            Text("知道了")
                        }
                    }
                }
            }
        }

        // ── MedicationSummaryCard (counts + tappable event list) ──
        item {
            val events = uiState.medicationEvents
            StatusCard(title = "今日药物", icon = Icons.Filled.Medication, iconColor = MedicationColor) {
                if (events.isEmpty()) {
                    Text("暂无记录", style = MaterialTheme.typography.bodyMedium)
                } else {
                    val done = events.count { it.status == "done" }
                    val pending = events.count { it.status == "pending" }
                    val skipped = events.count { it.status == "skipped" }
                    Row(horizontalArrangement = Arrangement.spacedBy(24.dp)) {
                        SummaryItem("$done", "已吃", GreenStatus)
                        SummaryItem("$pending", "待确认", OrangeStatus)
                        SummaryItem("$skipped", "跳过", GreyStatus)
                    }
                    HorizontalDivider(Modifier.padding(vertical = 4.dp))
                    events.take(4).forEach { event ->
                        Row(Modifier.fillMaxWidth().padding(vertical = 4.dp),
                            verticalAlignment = Alignment.CenterVertically) {
                            Text(formatTime(event.scheduledAt), modifier = Modifier.width(50.dp),
                                style = MaterialTheme.typography.bodySmall)
                            Text(event.medicationName, style = MaterialTheme.typography.bodyMedium,
                                modifier = Modifier.weight(1f))
                            if (event.status == "pending") {
                                TextButton(onClick = { viewModel.confirmMedication(event.id, "done") }) { Text("已吃") }
                                TextButton(onClick = { viewModel.confirmMedication(event.id, "skipped") }) { Text("跳过") }
                            } else {
                                StatusBadge(event.status)
                            }
                        }
                    }
                }
            }
        }

        // ── SleepSummaryCard with "晚安" button ──
        item {
            val sleepConfirmed = uiState.sleepEvents.any { it.status == "confirmed" }
            StatusCard(title = "今晚睡觉", icon = Icons.Filled.Bedtime, iconColor = SleepColor) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically) {
                    Text(if (sleepConfirmed) "已晚安" else "未晚安",
                        style = MaterialTheme.typography.bodyMedium)
                    if (!sleepConfirmed) {
                        Button(onClick = { viewModel.confirmSleep() }) { Text("晚安") }
                    } else {
                        StatusBadge("confirmed")
                    }
                }
            }
        }

        // ── NightSnackCard with "没吃/吃了" ──
        item {
            val ns = uiState.nightSnackEvent
            val needsRecord = ns == null || ns.status == "unset"
            StatusCard(title = "夜宵", icon = Icons.Filled.Nightlight, iconColor = NightSnackColor) {
                if (needsRecord) {
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        Button(onClick = { viewModel.recordNightSnack("noSnack") }) { Text("没吃") }
                        Button(onClick = { viewModel.recordNightSnack("ateSnack") }) { Text("吃了") }
                    }
                } else {
                    Text(ns?.status?.let { s -> when(s){"noSnack"->"没吃";"ateSnack"->"吃了";else->"未记录"} } ?: "未记录",
                        style = MaterialTheme.typography.bodyMedium)
                }
            }
        }
    }
}

// ── Helpers ──

@Composable
private fun SummaryItem(value: String, label: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, style = MaterialTheme.typography.titleLarge, color = color)
        Text(label, style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

@Composable
private fun MedicationEventCard(event: MedicationEvent, viewModel: TodayViewModel) {
    StatusCard(title = "下一条提醒", icon = Icons.Filled.Alarm, iconColor = MedicationColor) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text(event.medicationName, style = MaterialTheme.typography.titleMedium)
                if (!event.dosageText.isNullOrEmpty())
                    Text(event.dosageText, style = MaterialTheme.typography.bodySmall)
            }
            Row {
                TextButton(onClick = { viewModel.confirmMedication(event.id, "done") }) { Text("已吃") }
                TextButton(onClick = { viewModel.confirmMedication(event.id, "skipped") }) { Text("跳过") }
            }
        }
    }
}

@Composable
fun StatusBadge(status: String) {
    val (label, color) = when (status) {
        "done","confirmed" -> "已吃" to GreenStatus
        "pending" -> "待确认" to OrangeStatus
        "skipped" -> "跳过" to GreyStatus
        "unconfirmed" -> "未确认" to RedStatus
        else -> status to GreyStatus
    }
    Surface(shape = RoundedCornerShape(12.dp), color = color.copy(alpha = 0.15f)) {
        Text(label, modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
            style = MaterialTheme.typography.labelSmall, color = color)
    }
}

private fun formatTime(millis: Long): String {
    val time = java.time.LocalTime.from(java.time.Instant.ofEpochMilli(millis)
        .atZone(ZoneId.systemDefault()))
    return String.format("%02d:%02d", time.hour, time.minute)
}
