package com.openlife.openlife_routine

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "openlife_routine/timezone",
        ).setMethodCallHandler { call, result ->
            if (call.method == "getLocalTimezone") {
                result.success(TimeZone.getDefault().id)
            } else {
                result.notImplemented()
            }
        }

        // Battery optimisation is the single most common reason a reminder
        // never arrives on the phones this app is built for: Xiaomi, Oppo,
        // Vivo and Realme suspend background apps far more aggressively than
        // stock Android, and they do it silently. The app cannot fix that, but
        // it can see it and say so.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "openlife_routine/power",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isIgnoringBatteryOptimizations" -> {
                    val manager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    result.success(manager.isIgnoringBatteryOptimizations(packageName))
                }

                // Opens the OS list rather than the direct-grant dialog: the
                // direct request needs REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                // which Play restricts to apps whose core function genuinely
                // requires it and which this app should not claim.
                "openBatterySettings" -> {
                    startActivity(
                        Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS),
                    )
                    result.success(true)
                }

                // The per-manufacturer autostart screens live at vendor-only
                // activities that change between OS versions, so this falls
                // back to the app's own settings page, which always exists.
                "openAppSettings" -> {
                    startActivity(
                        Intent(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.fromParts("package", packageName, null),
                        ),
                    )
                    result.success(true)
                }

                "manufacturer" -> result.success(Build.MANUFACTURER)

                else -> result.notImplemented()
            }
        }
    }
}
