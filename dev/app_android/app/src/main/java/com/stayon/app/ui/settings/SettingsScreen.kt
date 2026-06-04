package com.stayon.app.ui.settings

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Tag
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.stayon.app.domain.enums.ToneStyle

@Composable
fun SettingsScreen(
    viewModel: SettingsViewModel? = null,
    onNavigateToMealTags: () -> Unit = {}
) {
    val uiState by viewModel?.uiState?.collectAsState() ?: remember { mutableStateOf(com.stayon.app.ui.settings.SettingsUiState()) }
    val settings = uiState.settings

    LazyColumn(
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Notification status
        item {
            Card(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text("通知权限", style = MaterialTheme.typography.titleSmall)
                        Text("在系统设置中管理", style = MaterialTheme.typography.bodySmall)
                    }
                }
            }
        }

        // Snooze settings
        item {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("默认提醒行为", style = MaterialTheme.typography.titleSmall)
                    Spacer(Modifier.height(8.dp))
                    Text("稍后提醒间隔：${settings.defaultSnoozeMinutes} 分钟")
                    Slider(
                        value = settings.defaultSnoozeMinutes.toFloat(),
                        onValueChange = { viewModel?.updateSnoozeMinutes(it.toInt()) },
                        valueRange = 5f..60f, steps = 11
                    )
                    Spacer(Modifier.height(8.dp))
                    Text("最大追提醒次数：${settings.defaultMaxSnoozeCount}")
                    Slider(
                        value = settings.defaultMaxSnoozeCount.toFloat(),
                        onValueChange = { viewModel?.updateMaxSnoozeCount(it.toInt()) },
                        valueRange = 1f..5f, steps = 4
                    )
                }
            }
        }

        // Tone style
        item {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("文案风格", style = MaterialTheme.typography.titleSmall)
                    Spacer(Modifier.height(8.dp))
                    ToneStyle.entries.forEach { style ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            RadioButton(
                                selected = settings.toneStyle == style.value,
                                onClick = { viewModel?.updateToneStyle(style.value) }
                            )
                            Spacer(Modifier.width(8.dp))
                            Column {
                                Text(style.displayName, style = MaterialTheme.typography.bodyMedium)
                                Text(style.description, style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                            }
                        }
                    }
                }
            }
        }

        // Meal tags
        item {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onNavigateToMealTags() }
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Filled.Tag, contentDescription = null,
                            tint = MaterialTheme.colorScheme.onSurfaceVariant)
                        Spacer(Modifier.width(12.dp))
                        Text("饮食模板标签", style = MaterialTheme.typography.bodyLarge)
                    }
                    Icon(Icons.Filled.ChevronRight, contentDescription = null,
                        tint = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }

        // Extensions
        item {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("扩展", style = MaterialTheme.typography.titleSmall)
                    listOf("数据导出", "iCloud 同步", "Apple Health").forEach { item ->
                        Row(
                            modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(item, style = MaterialTheme.typography.bodyMedium)
                            Text("未启用", style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                }
            }
        }

        item {
            Text("版本 1.0.0", style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(vertical = 8.dp))
        }
    }

}
