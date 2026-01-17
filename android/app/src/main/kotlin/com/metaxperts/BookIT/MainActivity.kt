package com.metaxperts.order_booking_app

import android.content.Intent
import android.os.Bundle
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.security.ProviderInstaller
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity(), ProviderInstaller.ProviderInstallListener {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
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
}

