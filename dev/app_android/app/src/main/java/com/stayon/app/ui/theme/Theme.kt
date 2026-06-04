package com.stayon.app.ui.theme

import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val LightColorScheme = lightColorScheme(
    primary = PrimaryBlue40,
    onPrimary = Color.White,
    primaryContainer = PrimaryBlue80,
    secondary = SecondaryBlue60,
    secondaryContainer = SecondaryBlue80,
    background = LightBackground,
    surface = LightBackground,
    surfaceVariant = LightBackground,
    error = RedStatus,
    onBackground = Color(0xFF1A1C20),
    onSurface = Color(0xFF1A1C20),
    onSurfaceVariant = Color(0xFF6B7280)
)

private val DarkColorScheme = darkColorScheme(
    primary = PrimaryBlue80,
    onPrimary = Color(0xFF00315E),
    primaryContainer = PrimaryBlue40,
    secondary = SecondaryBlue80,
    onSecondary = Color(0xFF2A3647),
    secondaryContainer = SecondaryBlue60,
    background = DarkBackground,
    surface = DarkBackground,
    surfaceVariant = DarkBackground,
    error = Color(0xFFFF6B6B),
    onBackground = Color(0xFFE5E7EB),
    onSurface = Color(0xFFE5E7EB),
    onSurfaceVariant = Color(0xFF9CA3AF)
)

@Composable
fun StayOnTheme(
    darkTheme: Boolean = androidx.compose.foundation.isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    MaterialTheme(
        colorScheme = colorScheme,
        typography = StayOnTypography,
        content = content
    )
}
