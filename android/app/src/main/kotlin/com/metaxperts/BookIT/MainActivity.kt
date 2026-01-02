//package com.metaxperts.BookIT
//
//import android.content.Intent
//import android.os.Bundle
//import com.google.android.gms.common.GoogleApiAvailability
//import com.google.android.gms.security.ProviderInstaller
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity : FlutterActivity(), ProviderInstaller.ProviderInstallListener {
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        installProvider()
//    }
//
//    private fun installProvider() {
//        ProviderInstaller.installIfNeededAsync(this, this)
//    }
//
//    override fun onProviderInstalled() {
//        // Provider installed successfully
//    }
//
//    override fun onProviderInstallFailed(errorCode: Int, intent: Intent?) {
//        // Provider installation failed, handle the error here
//        GoogleApiAvailability.getInstance().showErrorNotification(this, errorCode)
//    }
//}
//
package com.metaxperts.BookIT

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.security.ProviderInstaller

class MainActivity : FlutterActivity(), ProviderInstaller.ProviderInstallListener {

    private val CHANNEL = "battery_saver_channel"
    private val REQUEST_CODE_BATTERY_SAVER = 1001

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize MethodChannel for battery saver
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isBatterySaverOn" -> {
                    val isBatterySaverOn = checkBatterySaverMode()
                    result.success(isBatterySaverOn)
                }
                "openBatterySaverSettings" -> {
                    openBatterySaverSettings() // ✅ CORRECT: "Saver" not "Sager"
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Install SSL provider
        installProvider()
    }

    private fun installProvider() {
        ProviderInstaller.installIfNeededAsync(this, this)
    }

    override fun onProviderInstalled() {
        // Provider installed successfully
    }

    override fun onProviderInstallFailed(errorCode: Int, intent: Intent?) {
        // Provider installation failed, handle the error here
        GoogleApiAvailability.getInstance().showErrorNotification(this, errorCode)
    }

    private fun checkBatterySaverMode(): Boolean {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            powerManager.isPowerSaveMode
        } else {
            false
        }
    }

    private fun openBatterySaverSettings() { // ✅ CORRECT FUNCTION NAME
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS)
        } else {
            // For older versions, open general battery settings
            Intent(Settings.ACTION_SETTINGS)
        }

        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    // Optional: If you want to handle the result when user returns from settings
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_BATTERY_SAVER) {
            // Handle when user returns from battery saver settings
        }
    }
}