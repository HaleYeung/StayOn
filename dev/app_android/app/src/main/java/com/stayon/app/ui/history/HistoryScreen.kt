package com.stayon.app.ui.history

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.stayon.app.ui.theme.*

@Composable
fun HistoryScreen(
    viewModel: com.stayon.app.ui.history.HistoryViewModel? = null
) {
    val uiState by viewModel?.uiState?.collectAsState()
        ?: remember { mutableStateOf(com.stayon.app.ui.history.HistoryUiState()) }

    LazyColumn(
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Streak card
        item {
            Card(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(24.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("${uiState.currentStreak}",
                            style = MaterialTheme.typography.headlineLarge, color = GreenStatus)
                        Text("当前连续", style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("${uiState.longestStreak}",
                            style = MaterialTheme.typography.headlineLarge)
                        Text("最长连续", style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
        }

        // Today overview
        item {
            val today = java.time.LocalDate.now().toString()
            val todayMeds = uiState.medicationEvents.filter {
                java.time.Instant.ofEpochMilli(it.scheduledAt).atZone(java.time.ZoneId.systemDefault()).toLocalDate().toString() == today
            }
            val todaySleeps = uiState.sleepEvents.filter { it.date == today }
            val todayMeals = uiState.mealEvents.filter {
                java.time.Instant.ofEpochMilli(it.scheduledAt).atZone(java.time.ZoneId.systemDefault()).toLocalDate().toString() == today
            }
            val todayNS = uiState.nightSnackEvents.firstOrNull { it.date == today }

            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("今天概览", style = MaterialTheme.typography.titleSmall)
                    Spacer(Modifier.height(8.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(24.dp)) {
                        Text("药物 ${todayMeds.count { it.status == "done" }}/${todayMeds.size}")
                        Text("饮食 ${todayMeals.count { it.status == "acknowledged" }}/${todayMeals.size}")
                        Text("晚安 ${if (todaySleeps.any { it.status == "confirmed" }) "✓" else "○"}")
                    }
                    if (todayNS != null) {
                        Text("夜宵：${todayNS.status}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
        }

        // Recent 7 days
        item {
            Text("最近 7 天", style = MaterialTheme.typography.titleSmall)
        }

        items(6.downTo(0).toList()) { dayOffset ->
            val date = java.time.LocalDate.now().minusDays(dayOffset.toLong())
            val dateStr = date.toString()
            val meds = uiState.medicationEvents.filter {
                java.time.Instant.ofEpochMilli(it.scheduledAt).atZone(java.time.ZoneId.systemDefault()).toLocalDate().toString() == dateStr
            }
            val sleeps = uiState.sleepEvents.filter { it.date == dateStr }
            val ns = uiState.nightSnackEvents.firstOrNull { it.date == dateStr }
            val doneCount = meds.count { it.status == "done" }
            val sleepConfirmed = sleeps.any { it.status == "confirmed" }

            Card(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(date.format(java.time.format.DateTimeFormatter.ofPattern("M/d")),
                        style = MaterialTheme.typography.bodyMedium)
                    Text("$doneCount/${meds.size}", style = MaterialTheme.typography.bodySmall,
                        color = MedicationColor)
                    Text(if (sleepConfirmed) "✓" else "○",
                        style = MaterialTheme.typography.bodySmall,
                        color = if (sleepConfirmed) GreenStatus else GreyStatus)
                    if (ns != null) {
                        Text(if (ns.status == "noSnack") "✓" else "✗",
                            style = MaterialTheme.typography.bodySmall,
                            color = if (ns.status == "noSnack") GreenStatus else RedStatus)
                    }
                }
            }
        }

        // Full log placeholder
        item {
            TextButton(onClick = { /* TODO: navigate to full log */ }) {
                Icon(Icons.Filled.CalendarMonth, contentDescription = null)
                Spacer(Modifier.width(4.dp))
                Text("查看完整日志")
            }
        }
    }
}
