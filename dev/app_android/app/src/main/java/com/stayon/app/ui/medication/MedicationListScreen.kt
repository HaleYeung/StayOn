package com.stayon.app.ui.medication

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Medication
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.stayon.app.domain.model.Medication
import com.stayon.app.ui.components.EmptyStateView
import com.stayon.app.ui.today.StatusBadge
import com.stayon.app.ui.theme.*

@Composable
fun MedicationListScreen(
    viewModel: MedicationViewModel,
    onNavigateToForm: () -> Unit = {},
    onNavigateToEdit: (String) -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    Box(modifier = Modifier.fillMaxSize()) {
        if (uiState.medications.isEmpty()) {
            EmptyStateView(
                icon = Icons.Filled.Medication,
                title = "还没有药物",
                message = "添加第一种药物，开始管理你的服药计划",
                actionTitle = "添加药物",
                onAction = onNavigateToForm
            )
        } else {
            LazyColumn(
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                if (uiState.todayEvents.isNotEmpty()) {
                    item {
                        Text("今日记录", style = MaterialTheme.typography.titleSmall,
                            modifier = Modifier.padding(bottom = 4.dp))
                    }
                    items(uiState.todayEvents) { event ->
                        Card(modifier = Modifier.fillMaxWidth()) {
                            Row(
                                modifier = Modifier.fillMaxWidth().padding(12.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Column {
                                    Text(event.medicationName, style = MaterialTheme.typography.titleSmall)
                                    if (!event.dosageText.isNullOrEmpty()) {
                                        Text(event.dosageText, style = MaterialTheme.typography.bodySmall)
                                    }
                                }
                                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                    if (event.status == "pending") {
                                        TextButton(onClick = { viewModel.updateEventStatus(event.id, "done") }) {
                                            Text("已吃", style = MaterialTheme.typography.labelSmall)
                                        }
                                        TextButton(onClick = { viewModel.updateEventStatus(event.id, "skipped") }) {
                                            Text("跳过", style = MaterialTheme.typography.labelSmall)
                                        }
                                    }
                                    StatusBadge(event.status)
                                }
                            }
                        }
                    }
                }

                item {
                    Text("药物列表", style = MaterialTheme.typography.titleSmall,
                        modifier = Modifier.padding(top = 8.dp, bottom = 4.dp))
                }
                items(uiState.medications) { med ->
                    MedicationCard(
                        medication = med,
                        onClick = { onNavigateToEdit(med.id) },
                        onDelete = { viewModel.deleteMedication(med) }
                    )
                }
            }
        }

        if (uiState.medications.isNotEmpty()) {
            FloatingActionButton(
                onClick = onNavigateToForm,
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(16.dp)
            ) {
                Icon(Icons.Filled.Add, contentDescription = "添加药物")
            }
        }
    }
}

@Composable
private fun MedicationCard(
    medication: Medication,
    onClick: () -> Unit,
    onDelete: () -> Unit
) {
    Card(modifier = Modifier.fillMaxWidth().clickable { onClick() }) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(medication.name, style = MaterialTheme.typography.titleSmall)
                    if (!medication.isActive) {
                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = GreyStatus.copy(alpha = 0.15f),
                            modifier = Modifier.padding(start = 4.dp)
                        ) {
                            Text("已停用", modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp),
                                style = MaterialTheme.typography.labelSmall, color = GreyStatus)
                        }
                    }
                }
                if (!medication.dosageText.isNullOrEmpty()) {
                    Text(medication.dosageText, style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                Text("${medication.timesPerDay}次/天", style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }
}
