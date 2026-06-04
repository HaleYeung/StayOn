package com.stayon.app.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

private val LightColorScheme = lightColorScheme(
    primary = Orange40,
    onPrimary = Orange80,
    primaryContainer = Orange80,
    secondary = OrangeGrey60,
    background = LightBackground,
    surface = LightBackground,
    surfaceVariant = LightBackground
)

private val DarkColorScheme = darkColorScheme(
    primary = Orange80,
    onPrimary = Orange40,
    primaryContainer = Orange80,
    secondary = OrangeGrey80,
    background = DarkBackground,
    surface = DarkBackground,
    surfaceVariant = DarkBackground
)

@Composable
fun StayOnTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography = StayOnTypography,
        content = content
    )
}
