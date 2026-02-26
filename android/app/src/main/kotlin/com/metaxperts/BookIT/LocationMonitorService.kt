//package com.metaxperts.order_booking_app
//
//import android.app.Notification
//import android.app.NotificationChannel
//import android.app.NotificationManager
//import android.app.PendingIntent
//import android.app.Service
//import android.content.BroadcastReceiver
//import android.content.Context
//import android.content.Intent
//import android.content.IntentFilter
//import android.content.pm.PackageManager
//import android.location.LocationManager
//import android.os.Build
//import android.os.Handler
//import android.os.IBinder
//import android.os.Looper
//import android.os.PowerManager
//import android.provider.Settings
//import androidx.core.app.NotificationCompat
//import androidx.core.content.ContextCompat
//import java.text.SimpleDateFormat
//import java.util.Date
//import java.util.Locale
//import android.Manifest
//
//class LocationMonitorService : Service() {
//    private val CHANNEL_ID = "location_monitor_channel"
//    private val NOTIFICATION_ID = 1001
//    private val CHECK_INTERVAL = 2000L // 2 seconds
//
//    private lateinit var handler: Handler
//    private lateinit var checkRunnable: Runnable
//    private var wasLocationEnabled = true
//    private var wasPermissionGranted = true
//    private var isClockedIn = false
//
//    // SharedPreferences keys (must match Flutter - note the flutter. prefix)
//    private val PREFS_NAME = "FlutterSharedPreferences"
//    private val KEY_IS_CLOCKED_IN = "flutter.isClockedIn"
//    private val KEY_HAS_CRITICAL_EVENT = "flutter.has_critical_event_pending"
//    private val KEY_EVENT_TIMESTAMP = "flutter.critical_event_timestamp"
//    private val KEY_EVENT_REASON = "flutter.critical_event_reason"
//    private val KEY_EVENT_DISTANCE = "flutter.critical_event_distance"
//    private val KEY_EVENT_LAT = "flutter.critical_event_latitude"
//    private val KEY_EVENT_LNG = "flutter.critical_event_longitude"
//    private val KEY_IS_TIMER_FROZEN = "flutter.is_timer_frozen"
//    private val KEY_FROZEN_TIME = "flutter.frozen_display_time"
//    private val KEY_ELAPSED_TIME = "flutter.elapsed_time"
//
//    override fun onCreate() {
//        super.onCreate()
//        handler = Handler(Looper.getMainLooper())
//        registerReceivers()
//    }
//
//    private fun registerReceivers() {
//        // Listen for location mode changes
//        val locationFilter = IntentFilter(LocationManager.MODE_CHANGED_ACTION)
//        registerReceiver(locationModeReceiver, locationFilter)
//
//        // Listen for package changes (permission changes trigger this)
//        val packageFilter = IntentFilter(Intent.ACTION_PACKAGE_CHANGED)
//        packageFilter.addDataScheme("package")
//        registerReceiver(packageReceiver, packageFilter)
//    }
//
//    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//        createNotificationChannel()
//        startForeground(NOTIFICATION_ID, buildNotification())
//
//        // Initialize states from current status
//        wasLocationEnabled = isLocationEnabled()
//        wasPermissionGranted = checkLocationPermission()
//
//        startMonitoring()
//
//        return START_STICKY // Service will be restarted if killed
//    }
//
//    private fun startMonitoring() {
//        checkRunnable = object : Runnable {
//            override fun run() {
//                checkLocationAndPermission()
//                handler.postDelayed(this, CHECK_INTERVAL)
//            }
//        }
//        handler.post(checkRunnable)
//    }
//
//    private fun checkLocationAndPermission() {
//        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
//        isClockedIn = prefs.getBoolean(KEY_IS_CLOCKED_IN, false)
//
//        // Don't check if not clocked in
//        if (!isClockedIn) {
//            updateNotification("Not clocked in", false)
//            return
//        }
//
//        // Check if already frozen (event already processed)
//        val isFrozen = prefs.getBoolean(KEY_IS_TIMER_FROZEN, false)
//        if (isFrozen) {
//            updateNotification("Timer frozen - Event logged", true)
//            handler.removeCallbacks(checkRunnable)
//            return
//        }
//
//        val currentLocationEnabled = isLocationEnabled()
//        val currentPermissionGranted = checkLocationPermission()
//
//        // Detect Location Turned OFF
//        if (wasLocationEnabled && !currentLocationEnabled) {
//            handleCriticalEvent("location_off_auto")
//            return
//        }
//
//        // Detect Permission Revoked
//        if (wasPermissionGranted && !currentPermissionGranted) {
//            handleCriticalEvent("permission_revoked_auto")
//            return
//        }
//
//        // Update states for next check
//        wasLocationEnabled = currentLocationEnabled
//        wasPermissionGranted = currentPermissionGranted
//
//        // Update notification
//        val status = if (currentLocationEnabled && currentPermissionGranted) {
//            "Monitoring - All OK"
//        } else {
//            "Issue detected - Processing..."
//        }
//        updateNotification(status, false)
//    }
//
//    private fun handleCriticalEvent(reason: String) {
//        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
//        val editor = prefs.edit()
//
//        val eventTime = Date()
//        val timestamp = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault()).format(eventTime)
//
//        // Get current elapsed time from prefs
//        val frozenTime = prefs.getString(KEY_ELAPSED_TIME, "00:00:00") ?: "00:00:00"
//
//        // Save critical event data
//        editor.putBoolean(KEY_HAS_CRITICAL_EVENT, true)
//        editor.putBoolean(KEY_IS_TIMER_FROZEN, true)
//        editor.putString(KEY_EVENT_TIMESTAMP, timestamp)
//        editor.putString(KEY_EVENT_REASON, reason)
//        editor.putString(KEY_FROZEN_TIME, frozenTime)
//        editor.putFloat(KEY_EVENT_DISTANCE, 0.0f) // Will be updated by Flutter
//        editor.putFloat(KEY_EVENT_LAT, 0.0f)
//        editor.putFloat(KEY_EVENT_LNG, 0.0f)
//        editor.putBoolean(KEY_IS_CLOCKED_IN, false) // Mark as clocked out
//        editor.apply()
//
//        // Show urgent notification
//        showCriticalNotification(reason, timestamp, frozenTime)
//
//        // Update service notification
//        updateNotification("⚠️ AUTO CLOCKOUT: $reason", true)
//
//        // Stop monitoring after event
//        handler.removeCallbacks(checkRunnable)
//
//        // Try to wake up device briefly to ensure data is saved
//        wakeUpBriefly()
//
//        // Stop the service after handling event
//        stopForeground(STOP_FOREGROUND_REMOVE)
//        stopSelf()
//    }
//
//    private fun wakeUpBriefly() {
//        try {
//            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
//            val wakeLock = powerManager.newWakeLock(
//                PowerManager.PARTIAL_WAKE_LOCK,
//                "BookIT::CriticalEventWakeLock"
//            )
//            wakeLock.acquire(3000) // 3 seconds
//        } catch (e: Exception) {
//            e.printStackTrace()
//        }
//    }
//
//    private fun showCriticalNotification(reason: String, time: String, duration: String) {
//        val title = when (reason) {
//            "location_off_auto" -> "⚠️ LOCATION TURNED OFF"
//            "permission_revoked_auto" -> "⚠️ PERMISSION REVOKED"
//            "midnight_auto" -> "⚠️ MIDNIGHT AUTO CLOCKOUT"
//            else -> "⚠️ AUTO CLOCKOUT"
//        }
//
//        val message = "Time: $time\nDuration: $duration\nApp was closed - Event captured"
//
//        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//
//        val notification = NotificationCompat.Builder(this, "urgent_auto_clockout_channel")
//            .setContentTitle(title)
//            .setContentText(message)
//            .setSmallIcon(R.mipmap.ic_launcher)
//            .setPriority(NotificationCompat.PRIORITY_MAX)
//            .setCategory(NotificationCompat.CATEGORY_ALARM)
//            .setAutoCancel(true)
//            .setVibrate(longArrayOf(0, 1000, 500, 1000))
//            .setLights(android.graphics.Color.RED, 1000, 500)
//            .build()
//
//        notificationManager.notify(9999, notification)
//    }
//
//    private fun isLocationEnabled(): Boolean {
//        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
//            val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
//            locationManager.isLocationEnabled
//        } else {
//            val mode = Settings.Secure.getInt(
//                contentResolver,
//                Settings.Secure.LOCATION_MODE,
//                Settings.Secure.LOCATION_MODE_OFF
//            )
//            mode != Settings.Secure.LOCATION_MODE_OFF
//        }
//    }
//
//    private fun checkLocationPermission(): Boolean {
//        return ContextCompat.checkSelfPermission(
//            this,
//            Manifest.permission.ACCESS_FINE_LOCATION
//        ) == PackageManager.PERMISSION_GRANTED ||
//                ContextCompat.checkSelfPermission(
//                    this,
//                    Manifest.permission.ACCESS_COARSE_LOCATION
//                ) == PackageManager.PERMISSION_GRANTED
//    }
//
//    private val locationModeReceiver = object : BroadcastReceiver() {
//        override fun onReceive(context: Context?, intent: Intent?) {
//            if (intent?.action == LocationManager.MODE_CHANGED_ACTION) {
//                handler.post { checkLocationAndPermission() }
//            }
//        }
//    }
//
//    private val packageReceiver = object : BroadcastReceiver() {
//        override fun onReceive(context: Context?, intent: Intent?) {
//            handler.post { checkLocationAndPermission() }
//        }
//    }
//
//    private fun createNotificationChannel() {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val serviceChannel = NotificationChannel(
//                CHANNEL_ID,
//                "Location Monitor Service",
//                NotificationManager.IMPORTANCE_LOW
//            ).apply {
//                description = "Monitors location status for attendance tracking"
//            }
//
//            val urgentChannel = NotificationChannel(
//                "urgent_auto_clockout_channel",
//                "URGENT Auto Clockout",
//                NotificationManager.IMPORTANCE_HIGH
//            ).apply {
//                description = "Critical auto clockout notifications"
//                enableVibration(true)
//                vibrationPattern = longArrayOf(0, 1000, 500, 1000)
//                enableLights(true)
//                lightColor = android.graphics.Color.RED
//            }
//
//            val manager = getSystemService(NotificationManager::class.java)
//            manager.createNotificationChannel(serviceChannel)
//            manager.createNotificationChannel(urgentChannel)
//        }
//    }
//
//    private fun buildNotification(): Notification {
//        val pendingIntent = PendingIntent.getActivity(
//            this,
//            0,
//            packageManager.getLaunchIntentForPackage(packageName),
//            PendingIntent.FLAG_IMMUTABLE
//        )
//
//        return NotificationCompat.Builder(this, CHANNEL_ID)
//            .setContentTitle("BookIT Attendance Active")
//            .setContentText("Monitoring location status...")
//            .setSmallIcon(R.mipmap.ic_launcher)
//            .setContentIntent(pendingIntent)
//            .setOngoing(true)
//            .setSilent(true)
//            .build()
//    }
//
//    private fun updateNotification(text: String, isAlert: Boolean) {
//        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
//            .setContentTitle(if (isAlert) "⚠️ ATTENTION REQUIRED" else "BookIT Attendance Active")
//            .setContentText(text)
//            .setSmallIcon(R.mipmap.ic_launcher)
//            .setContentIntent(
//                PendingIntent.getActivity(
//                    this,
//                    0,
//                    packageManager.getLaunchIntentForPackage(packageName),
//                    PendingIntent.FLAG_IMMUTABLE
//                )
//            )
//            .setOngoing(true)
//            .setSilent(!isAlert)
//            .apply {
//                if (isAlert) {
//                    setColor(android.graphics.Color.RED)
//                    setLights(android.graphics.Color.RED, 1000, 500)
//                }
//            }
//            .build()
//
//        val notificationManager = getSystemService(NotificationManager::class.java)
//        notificationManager.notify(NOTIFICATION_ID, notification)
//    }
//
//    override fun onBind(intent: Intent?): IBinder? = null
//
//    override fun onDestroy() {
//        super.onDestroy()
//        handler.removeCallbacks(checkRunnable)
//        try {
//            unregisterReceiver(locationModeReceiver)
//            unregisterReceiver(packageReceiver)
//        } catch (e: Exception) {
//            // Receiver might not be registered
//        }
//    }
//}

package com.metaxperts.order_booking_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import android.Manifest

class LocationMonitorService : Service() {
    private val CHANNEL_ID = "location_monitor_channel"
    private val NOTIFICATION_ID = 1001
    private val CHECK_INTERVAL = 2000L // 2 seconds

    private lateinit var handler: Handler
    private lateinit var checkRunnable: Runnable
    private var wasLocationEnabled = true
    private var wasPermissionGranted = true
    private var isClockedIn = false

    // SharedPreferences keys (must match Flutter - note the flutter. prefix)
    private val PREFS_NAME = "FlutterSharedPreferences"
    private val KEY_IS_CLOCKED_IN = "flutter.isClockedIn"
    private val KEY_HAS_CRITICAL_EVENT = "flutter.has_critical_event_pending"
    private val KEY_EVENT_TIMESTAMP = "flutter.critical_event_timestamp"
    private val KEY_EVENT_REASON = "flutter.critical_event_reason"
    private val KEY_EVENT_DISTANCE = "flutter.critical_event_distance"
    private val KEY_EVENT_LAT = "flutter.critical_event_latitude"
    private val KEY_EVENT_LNG = "flutter.critical_event_longitude"
    private val KEY_IS_TIMER_FROZEN = "flutter.is_timer_frozen"
    private val KEY_FROZEN_TIME = "flutter.frozen_display_time"
    private val KEY_ELAPSED_TIME = "flutter.elapsed_time"

    override fun onCreate() {
        super.onCreate()
        handler = Handler(Looper.getMainLooper())
        registerReceivers()
    }

    private fun registerReceivers() {
        // Listen for location mode changes
        val locationFilter = IntentFilter(LocationManager.MODE_CHANGED_ACTION)
        registerReceiver(locationModeReceiver, locationFilter)

        // Listen for package changes (permission changes trigger this)
        val packageFilter = IntentFilter(Intent.ACTION_PACKAGE_CHANGED)
        packageFilter.addDataScheme("package")
        registerReceiver(packageReceiver, packageFilter)

        // Listen for app being resumed/foregrounded
        val screenFilter = IntentFilter(Intent.ACTION_SCREEN_ON)
        registerReceiver(screenReceiver, screenFilter)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification())

        // Initialize states from current status
        wasLocationEnabled = isLocationEnabled()
        wasPermissionGranted = checkLocationPermission()

        startMonitoring()

        return START_STICKY // Service will be restarted if killed
    }

    private fun startMonitoring() {
        checkRunnable = object : Runnable {
            override fun run() {
                checkLocationAndPermission()
                handler.postDelayed(this, CHECK_INTERVAL)
            }
        }
        handler.post(checkRunnable)
    }

    private fun checkLocationAndPermission() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        isClockedIn = prefs.getBoolean(KEY_IS_CLOCKED_IN, false)

        // Don't check if not clocked in
        if (!isClockedIn) {
            updateNotification("Not clocked in", false)
            return
        }

        // Check if already frozen (event already processed)
        val isFrozen = prefs.getBoolean(KEY_IS_TIMER_FROZEN, false)
        if (isFrozen) {
            updateNotification("Timer frozen - Event logged", true)
            handler.removeCallbacks(checkRunnable)
            return
        }

        // ✅ CHECK FOR MIDNIGHT (11:58 PM)
        val now = Date()
        val calendar = java.util.Calendar.getInstance()
        calendar.time = now
        val hour = calendar.get(java.util.Calendar.HOUR_OF_DAY)
        val minute = calendar.get(java.util.Calendar.MINUTE)

        if (hour == 23 && minute == 58) {
            handleCriticalEvent("midnight_auto")
            return
        }

        val currentLocationEnabled = isLocationEnabled()
        val currentPermissionGranted = checkLocationPermission()

        // ✅ DETECT PERMISSION REVOKED IMMEDIATELY (BEFORE LOCATION CHECK)
        // This ensures we catch it even if Android kills the app
        if (wasPermissionGranted && !currentPermissionGranted) {
            debugPrint("🔐 [NATIVE] Permission REVOKED - Freezing timer immediately!")
            handleCriticalEvent("permission_revoked_auto")
            return
        }

        // Detect Location Turned OFF
        if (wasLocationEnabled && !currentLocationEnabled) {
            handleCriticalEvent("location_off_auto")
            return
        }

        // Update states for next check
        wasLocationEnabled = currentLocationEnabled
        wasPermissionGranted = currentPermissionGranted

        // Update notification
        val status = if (currentLocationEnabled && currentPermissionGranted) {
            "Monitoring - All OK"
        } else {
            "Issue detected - Processing..."
        }
        updateNotification(status, false)
    }

    private fun debugPrint(message: String) {
        android.util.Log.d("LocationMonitor", message)
    }

    private fun handleCriticalEvent(reason: String) {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()

        val eventTime = Date()
        val timestamp = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault()).format(eventTime)

        // Get current elapsed time from prefs
        val frozenTime = prefs.getString(KEY_ELAPSED_TIME, "00:00:00") ?: "00:00:00"

        // Save critical event data
        editor.putBoolean(KEY_HAS_CRITICAL_EVENT, true)
        editor.putBoolean(KEY_IS_TIMER_FROZEN, true)
        editor.putString(KEY_EVENT_TIMESTAMP, timestamp)
        editor.putString(KEY_EVENT_REASON, reason)
        editor.putString(KEY_FROZEN_TIME, frozenTime)
        editor.putFloat(KEY_EVENT_DISTANCE, 0.0f) // Will be updated by Flutter
        editor.putFloat(KEY_EVENT_LAT, 0.0f)
        editor.putFloat(KEY_EVENT_LNG, 0.0f)
        editor.putBoolean(KEY_IS_CLOCKED_IN, false) // Mark as clocked out
        editor.apply()

        // Show urgent notification
        showCriticalNotification(reason, timestamp, frozenTime)

        // Update service notification
        updateNotification("⚠️ AUTO CLOCKOUT: $reason", true)

        // Stop monitoring after event
        handler.removeCallbacks(checkRunnable)

        // Try to wake up device briefly to ensure data is saved
        wakeUpBriefly()

        // Stop the service after handling event
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun wakeUpBriefly() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            val wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "BookIT::CriticalEventWakeLock"
            )
            wakeLock.acquire(3000) // 3 seconds
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun showCriticalNotification(reason: String, time: String, duration: String) {
        val title = when (reason) {
            "location_off_auto" -> "⚠️ LOCATION TURNED OFF"
            "permission_revoked_auto" -> "⚠️ PERMISSION REVOKED"
            "midnight_auto" -> "⚠️ MIDNIGHT AUTO CLOCKOUT"
            else -> "⚠️ AUTO CLOCKOUT"
        }

        val message = "Time: $time\nDuration: $duration\nApp was closed - Event captured"

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val notification = NotificationCompat.Builder(this, "urgent_auto_clockout_channel")
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setVibrate(longArrayOf(0, 1000, 500, 1000))
            .setLights(android.graphics.Color.RED, 1000, 500)
            .build()

        notificationManager.notify(9999, notification)
    }

    private fun isLocationEnabled(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            locationManager.isLocationEnabled
        } else {
            val mode = Settings.Secure.getInt(
                contentResolver,
                Settings.Secure.LOCATION_MODE,
                Settings.Secure.LOCATION_MODE_OFF
            )
            mode != Settings.Secure.LOCATION_MODE_OFF
        }
    }

    private fun checkLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
    }

    private val locationModeReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == LocationManager.MODE_CHANGED_ACTION) {
                handler.post { checkLocationAndPermission() }
            }
        }
    }

    private val packageReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            // Permission changes often trigger package changed events
            handler.post { checkLocationAndPermission() }
        }
    }

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            // Check immediately when screen turns on (user might have changed settings)
            handler.post { checkLocationAndPermission() }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Location Monitor Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors location status for attendance tracking"
            }

            val urgentChannel = NotificationChannel(
                "urgent_auto_clockout_channel",
                "URGENT Auto Clockout",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Critical auto clockout notifications"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 1000, 500, 1000)
                enableLights(true)
                lightColor = android.graphics.Color.RED
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
            manager.createNotificationChannel(urgentChannel)
        }
    }

    private fun buildNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("BookIT Attendance Active")
            .setContentText("Monitoring location status...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }

    private fun updateNotification(text: String, isAlert: Boolean) {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(if (isAlert) "⚠️ ATTENTION REQUIRED" else "BookIT Attendance Active")
            .setContentText(text)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(
                PendingIntent.getActivity(
                    this,
                    0,
                    packageManager.getLaunchIntentForPackage(packageName),
                    PendingIntent.FLAG_IMMUTABLE
                )
            )
            .setOngoing(true)
            .setSilent(!isAlert)
            .apply {
                if (isAlert) {
                    setColor(android.graphics.Color.RED)
                    setLights(android.graphics.Color.RED, 1000, 500)
                }
            }
            .build()

        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(checkRunnable)
        try {
            unregisterReceiver(locationModeReceiver)
            unregisterReceiver(packageReceiver)
            unregisterReceiver(screenReceiver)
        } catch (e: Exception) {
            // Receiver might not be registered
        }
    }
}