package com.stayon.app.ui.today

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

@Composable
fun TodayScreen(
    viewModel: TodayViewModel
) {
    val uiState by viewModel.uiState.collectAsState()

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // TodayStatusCard
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
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceEvenly
                    ) {
                        SummaryItem("$doneCount/${events.size}", "药物", MedicationColor)
                        SummaryItem(
                            if (sleepConfirmed) "✓" else "○", "晚安",
                            if (sleepConfirmed) GreenStatus else GreyStatus
                        )
                        SummaryItem("$mealCount/$activeRules", "饮食", MealColor)
                    }
                }
            }
        }

        // NextMedicationCard
        val nextPending = uiState.medicationEvents.firstOrNull { it.status == "pending" }
        if (nextPending != null) {
            item {
                MedicationEventCard(event = nextPending)
            }
        }

        // MedicationSummaryCard
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
                }
            }
        }

        // NightSnackCard
        item {
            val ns = uiState.nightSnackEvent
            val needsRecord = ns == null || ns.status == "unset"

            StatusCard(title = "夜宵", icon = Icons.Filled.Nightlight, iconColor = NightSnackColor) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        if (needsRecord) "今晚记录" else ns!!.status.displayName(),
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
                if (needsRecord) {
                    Spacer(Modifier.height(4.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        Button(onClick = { viewModel.recordNightSnack("noSnack") }) {
                            Text("没吃")
                        }
                        Button(onClick = { viewModel.recordNightSnack("ateSnack") }) {
                            Text("吃了")
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun SummaryItem(value: String, label: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, style = MaterialTheme.typography.titleLarge, color = color)
        Text(label, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

@Composable
private fun MedicationEventCard(event: MedicationEvent) {
    StatusCard(title = "下一条提醒", icon = Icons.Filled.Alarm, iconColor = MedicationColor) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column {
                Text(event.medicationName, style = MaterialTheme.typography.titleMedium)
                if (!event.dosageText.isNullOrEmpty()) {
                    Text(event.dosageText, style = MaterialTheme.typography.bodySmall)
                }
            }
            StatusBadge(event.status)
        }
    }
}

@Composable
fun StatusBadge(status: String) {
    val (label, color) = when (status) {
        "done" -> "已吃" to GreenStatus
        "pending" -> "待确认" to OrangeStatus
        "skipped" -> "跳过" to GreyStatus
        "unconfirmed" -> "未确认" to RedStatus
        else -> status to GreyStatus
    }
    Surface(
        shape = RoundedCornerShape(12.dp),
        color = color.copy(alpha = 0.15f)
    ) {
        Text(
            text = label,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
            style = MaterialTheme.typography.labelSmall,
            color = color
        )
    }
}

private fun String.displayName(): String = when (this) {
    "noSnack" -> "没吃"
    "ateSnack" -> "吃了"
    "unset" -> "未记录"
    else -> this
}
