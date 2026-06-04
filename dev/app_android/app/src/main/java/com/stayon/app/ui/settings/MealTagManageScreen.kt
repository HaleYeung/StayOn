package com.stayon.app.ui.settings

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun MealTagManageScreen(
    viewModel: SettingsViewModel? = null,
    onBack: () -> Unit = {}
) {
    val uiState by viewModel?.uiState?.collectAsState() ?: remember {
        mutableStateOf(com.stayon.app.ui.settings.SettingsUiState())
    }
    var showAddDialog by remember { mutableStateOf(false) }
    var newTag by remember { mutableStateOf("") }

    LazyColumn(
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        item {
            Text("饮食模板标签", style = MaterialTheme.typography.titleMedium)
            Text("此处添加的标签可在饮食提醒设置中选择",
                style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }

        item {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    uiState.settings.mealTemplateTags.forEach { tag ->
                        Row(
                            modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(tag, style = MaterialTheme.typography.bodyLarge)
                            TextButton(onClick = { viewModel?.removeMealTag(tag) }) {
                                Text("删除", color = MaterialTheme.colorScheme.error)
                            }
                        }
                    }
                    if (uiState.settings.mealTemplateTags.isEmpty()) {
                        Text("暂无标签", style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
        }

        item {
            OutlinedButton(
                onClick = { showAddDialog = true },
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(Icons.Filled.Add, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(4.dp))
                Text("添加标签")
            }
        }
    }

    if (showAddDialog) {
        AlertDialog(
            onDismissRequest = { showAddDialog = false },
            title = { Text("添加标签") },
            text = {
                OutlinedTextField(value = newTag, onValueChange = { newTag = it },
                    label = { Text("标签名") }, singleLine = true)
            },
            confirmButton = {
                TextButton(onClick = {
                    if (newTag.isNotBlank()) {
                        viewModel?.addMealTag(newTag.trim())
                        newTag = ""; showAddDialog = false
                    }
                }) { Text("添加") }
            },
            dismissButton = { TextButton(onClick = { showAddDialog = false }) { Text("取消") } }
        )
    }
}
