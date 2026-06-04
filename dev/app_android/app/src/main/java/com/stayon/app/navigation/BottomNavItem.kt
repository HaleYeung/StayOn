package com.stayon.app.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.vector.ImageVector

enum class BottomNavItem(
    val route: String,
    val label: String,
    val icon: ImageVector
) {
    Today("today", "今天", Icons.Filled.WbSunny),
    Medication("medication", "药物", Icons.Filled.Medication),
    Routine("routine", "作息", Icons.Filled.Bedtime),
    History("history", "历史", Icons.Filled.History),
    Settings("settings", "设置", Icons.Filled.Settings);

    companion object {
        val items = entries.toList()
    }
}
