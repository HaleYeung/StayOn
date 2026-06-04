package com.stayon.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.stayon.app.navigation.AppNavigation
import com.stayon.app.ui.theme.StayOnTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            StayOnTheme {
                AppNavigation()
            }
        }
    }
}
