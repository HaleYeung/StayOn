package com.stayon.app.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.NotificationsOff
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun PermissionBanner(
    isVisible: Boolean,
    onOpenSettings: () -> Unit,
    modifier: Modifier = Modifier
) {
    if (isVisible) {
        Card(
            modifier = modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.errorContainer.copy(alpha = 0.3f)
            )
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(12.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    Icons.Filled.NotificationsOff,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.error
                )
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        "通知权限未开启",
                        style = MaterialTheme.typography.labelLarge
                    )
                    Text(
                        "你让谁提醒你？",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                TextButton(onClick = onOpenSettings) {
                    Text("去设置")
                }
            }
        }
    }
}
