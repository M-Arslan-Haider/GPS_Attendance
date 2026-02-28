////package com.metaxperts.order_booking_app
////
////import android.app.Notification
////import android.app.NotificationChannel
////import android.app.NotificationManager
////import android.app.PendingIntent
////import android.app.Service
////import android.content.BroadcastReceiver
////import android.content.Context
////import android.content.Intent
////import android.content.IntentFilter
////import android.content.pm.PackageManager
////import android.location.LocationManager
////import android.os.Build
////import android.os.Handler
////import android.os.IBinder
////import android.os.Looper
////import android.os.PowerManager
////import android.provider.Settings
////import androidx.core.app.NotificationCompat
////import androidx.core.content.ContextCompat
////import java.text.SimpleDateFormat
////import java.util.Date
////import java.util.Locale
////import android.Manifest
////
////class LocationMonitorService : Service() {
////    private val CHANNEL_ID = "location_monitor_channel"
////    private val NOTIFICATION_ID = 1001
////    private val CHECK_INTERVAL = 2000L // 2 seconds
////
////    private lateinit var handler: Handler
////    private lateinit var checkRunnable: Runnable
////    private var wasLocationEnabled = true
////    private var wasPermissionGranted = true
////    private var isClockedIn = false
////
////    // SharedPreferences keys (must match Flutter - note the flutter. prefix)
////    private val PREFS_NAME = "FlutterSharedPreferences"
////    private val KEY_IS_CLOCKED_IN = "flutter.isClockedIn"
////    private val KEY_HAS_CRITICAL_EVENT = "flutter.has_critical_event_pending"
////    private val KEY_EVENT_TIMESTAMP = "flutter.critical_event_timestamp"
////    private val KEY_EVENT_REASON = "flutter.critical_event_reason"
////    private val KEY_EVENT_DISTANCE = "flutter.critical_event_distance"
////    private val KEY_EVENT_LAT = "flutter.critical_event_latitude"
////    private val KEY_EVENT_LNG = "flutter.critical_event_longitude"
////    private val KEY_IS_TIMER_FROZEN = "flutter.is_timer_frozen"
////    private val KEY_FROZEN_TIME = "flutter.frozen_display_time"
////    private val KEY_ELAPSED_TIME = "flutter.elapsed_time"
////
////    override fun onCreate() {
////        super.onCreate()
////        handler = Handler(Looper.getMainLooper())
////        registerReceivers()
////    }
////
////    private fun registerReceivers() {
////        // Listen for location mode changes
////        val locationFilter = IntentFilter(LocationManager.MODE_CHANGED_ACTION)
////        registerReceiver(locationModeReceiver, locationFilter)
////
////        // Listen for package changes (permission changes trigger this)
////        val packageFilter = IntentFilter(Intent.ACTION_PACKAGE_CHANGED)
////        packageFilter.addDataScheme("package")
////        registerReceiver(packageReceiver, packageFilter)
////    }
////
////    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
////        createNotificationChannel()
////        startForeground(NOTIFICATION_ID, buildNotification())
////
////        // Initialize states from current status
////        wasLocationEnabled = isLocationEnabled()
////        wasPermissionGranted = checkLocationPermission()
////
////        startMonitoring()
////
////        return START_STICKY // Service will be restarted if killed
////    }
////
////    private fun startMonitoring() {
////        checkRunnable = object : Runnable {
////            override fun run() {
////                checkLocationAndPermission()
////                handler.postDelayed(this, CHECK_INTERVAL)
////            }
////        }
////        handler.post(checkRunnable)
////    }
////
////    private fun checkLocationAndPermission() {
////        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
////        isClockedIn = prefs.getBoolean(KEY_IS_CLOCKED_IN, false)
////
////        // Don't check if not clocked in
////        if (!isClockedIn) {
////            updateNotification("Not clocked in", false)
////            return
////        }
////
////        // Check if already frozen (event already processed)
////        val isFrozen = prefs.getBoolean(KEY_IS_TIMER_FROZEN, false)
////        if (isFrozen) {
////            updateNotification("Timer frozen - Event logged", true)
////            handler.removeCallbacks(checkRunnable)
////            return
////        }
////
////        val currentLocationEnabled = isLocationEnabled()
////        val currentPermissionGranted = checkLocationPermission()
////
////        // Detect Location Turned OFF
////        if (wasLocationEnabled && !currentLocationEnabled) {
////            handleCriticalEvent("location_off_auto")
////            return
////        }
////
////        // Detect Permission Revoked
////        if (wasPermissionGranted && !currentPermissionGranted) {
////            handleCriticalEvent("permission_revoked_auto")
////            return
////        }
////
////        // Update states for next check
////        wasLocationEnabled = currentLocationEnabled
////        wasPermissionGranted = currentPermissionGranted
////
////        // Update notification
////        val status = if (currentLocationEnabled && currentPermissionGranted) {
////            "Monitoring - All OK"
////        } else {
////            "Issue detected - Processing..."
////        }
////        updateNotification(status, false)
////    }
////
////    private fun handleCriticalEvent(reason: String) {
////        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
////        val editor = prefs.edit()
////
////        val eventTime = Date()
////        val timestamp = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault()).format(eventTime)
////
////        // Get current elapsed time from prefs
////        val frozenTime = prefs.getString(KEY_ELAPSED_TIME, "00:00:00") ?: "00:00:00"
////
////        // Save critical event data
////        editor.putBoolean(KEY_HAS_CRITICAL_EVENT, true)
////        editor.putBoolean(KEY_IS_TIMER_FROZEN, true)
////        editor.putString(KEY_EVENT_TIMESTAMP, timestamp)
////        editor.putString(KEY_EVENT_REASON, reason)
////        editor.putString(KEY_FROZEN_TIME, frozenTime)
////        editor.putFloat(KEY_EVENT_DISTANCE, 0.0f) // Will be updated by Flutter
////        editor.putFloat(KEY_EVENT_LAT, 0.0f)
////        editor.putFloat(KEY_EVENT_LNG, 0.0f)
////        editor.putBoolean(KEY_IS_CLOCKED_IN, false) // Mark as clocked out
////        editor.apply()
////
////        // Show urgent notification
////        showCriticalNotification(reason, timestamp, frozenTime)
////
////        // Update service notification
////        updateNotification("⚠️ AUTO CLOCKOUT: $reason", true)
////
////        // Stop monitoring after event
////        handler.removeCallbacks(checkRunnable)
////
////        // Try to wake up device briefly to ensure data is saved
////        wakeUpBriefly()
////
////        // Stop the service after handling event
////        stopForeground(STOP_FOREGROUND_REMOVE)
////        stopSelf()
////    }
////
////    private fun wakeUpBriefly() {
////        try {
////            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
////            val wakeLock = powerManager.newWakeLock(
////                PowerManager.PARTIAL_WAKE_LOCK,
////                "BookIT::CriticalEventWakeLock"
////            )
////            wakeLock.acquire(3000) // 3 seconds
////        } catch (e: Exception) {
////            e.printStackTrace()
////        }
////    }
////
////    private fun showCriticalNotification(reason: String, time: String, duration: String) {
////        val title = when (reason) {
////            "location_off_auto" -> "⚠️ LOCATION TURNED OFF"
////            "permission_revoked_auto" -> "⚠️ PERMISSION REVOKED"
////            "midnight_auto" -> "⚠️ MIDNIGHT AUTO CLOCKOUT"
////            else -> "⚠️ AUTO CLOCKOUT"
////        }
////
////        val message = "Time: $time\nDuration: $duration\nApp was closed - Event captured"
////
////        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
////
////        val notification = NotificationCompat.Builder(this, "urgent_auto_clockout_channel")
////            .setContentTitle(title)
////            .setContentText(message)
////            .setSmallIcon(R.mipmap.ic_launcher)
////            .setPriority(NotificationCompat.PRIORITY_MAX)
////            .setCategory(NotificationCompat.CATEGORY_ALARM)
////            .setAutoCancel(true)
////            .setVibrate(longArrayOf(0, 1000, 500, 1000))
////            .setLights(android.graphics.Color.RED, 1000, 500)
////            .build()
////
////        notificationManager.notify(9999, notification)
////    }
////
////    private fun isLocationEnabled(): Boolean {
////        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
////            val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
////            locationManager.isLocationEnabled
////        } else {
////            val mode = Settings.Secure.getInt(
////                contentResolver,
////                Settings.Secure.LOCATION_MODE,
////                Settings.Secure.LOCATION_MODE_OFF
////            )
////            mode != Settings.Secure.LOCATION_MODE_OFF
////        }
////    }
////
////    private fun checkLocationPermission(): Boolean {
////        return ContextCompat.checkSelfPermission(
////            this,
////            Manifest.permission.ACCESS_FINE_LOCATION
////        ) == PackageManager.PERMISSION_GRANTED ||
////                ContextCompat.checkSelfPermission(
////                    this,
////                    Manifest.permission.ACCESS_COARSE_LOCATION
////                ) == PackageManager.PERMISSION_GRANTED
////    }
////
////    private val locationModeReceiver = object : BroadcastReceiver() {
////        override fun onReceive(context: Context?, intent: Intent?) {
////            if (intent?.action == LocationManager.MODE_CHANGED_ACTION) {
////                handler.post { checkLocationAndPermission() }
////            }
////        }
////    }
////
////    private val packageReceiver = object : BroadcastReceiver() {
////        override fun onReceive(context: Context?, intent: Intent?) {
////            handler.post { checkLocationAndPermission() }
////        }
////    }
////
////    private fun createNotificationChannel() {
////        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
////            val serviceChannel = NotificationChannel(
////                CHANNEL_ID,
////                "Location Monitor Service",
////                NotificationManager.IMPORTANCE_LOW
////            ).apply {
////                description = "Monitors location status for attendance tracking"
////            }
////
////            val urgentChannel = NotificationChannel(
////                "urgent_auto_clockout_channel",
////                "URGENT Auto Clockout",
////                NotificationManager.IMPORTANCE_HIGH
////            ).apply {
////                description = "Critical auto clockout notifications"
////                enableVibration(true)
////                vibrationPattern = longArrayOf(0, 1000, 500, 1000)
////                enableLights(true)
////                lightColor = android.graphics.Color.RED
////            }
////
////            val manager = getSystemService(NotificationManager::class.java)
////            manager.createNotificationChannel(serviceChannel)
////            manager.createNotificationChannel(urgentChannel)
////        }
////    }
////
////    private fun buildNotification(): Notification {
////        val pendingIntent = PendingIntent.getActivity(
////            this,
////            0,
////            packageManager.getLaunchIntentForPackage(packageName),
////            PendingIntent.FLAG_IMMUTABLE
////        )
////
////        return NotificationCompat.Builder(this, CHANNEL_ID)
////            .setContentTitle("BookIT Attendance Active")
////            .setContentText("Monitoring location status...")
////            .setSmallIcon(R.mipmap.ic_launcher)
////            .setContentIntent(pendingIntent)
////            .setOngoing(true)
////            .setSilent(true)
////            .build()
////    }
////
////    private fun updateNotification(text: String, isAlert: Boolean) {
////        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
////            .setContentTitle(if (isAlert) "⚠️ ATTENTION REQUIRED" else "BookIT Attendance Active")
////            .setContentText(text)
////            .setSmallIcon(R.mipmap.ic_launcher)
////            .setContentIntent(
////                PendingIntent.getActivity(
////                    this,
////                    0,
////                    packageManager.getLaunchIntentForPackage(packageName),
////                    PendingIntent.FLAG_IMMUTABLE
////                )
////            )
////            .setOngoing(true)
////            .setSilent(!isAlert)
////            .apply {
////                if (isAlert) {
////                    setColor(android.graphics.Color.RED)
////                    setLights(android.graphics.Color.RED, 1000, 500)
////                }
////            }
////            .build()
////
////        val notificationManager = getSystemService(NotificationManager::class.java)
////        notificationManager.notify(NOTIFICATION_ID, notification)
////    }
////
////    override fun onBind(intent: Intent?): IBinder? = null
////
////    override fun onDestroy() {
////        super.onDestroy()
////        handler.removeCallbacks(checkRunnable)
////        try {
////            unregisterReceiver(locationModeReceiver)
////            unregisterReceiver(packageReceiver)
////        } catch (e: Exception) {
////            // Receiver might not be registered
////        }
////    }
////}
//
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
//    // ✅ NEW: Key for complete background clockout payload (for auto-sync on app open)
//    private val KEY_BG_CLOCKOUT_PAYLOAD = "flutter.bg_clockout_payload"
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
//
//        // Listen for app being resumed/foregrounded
//        val screenFilter = IntentFilter(Intent.ACTION_SCREEN_ON)
//        registerReceiver(screenReceiver, screenFilter)
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
//        // ✅ CHECK FOR MIDNIGHT (11:58 PM)
//        val now = Date()
//        val calendar = java.util.Calendar.getInstance()
//        calendar.time = now
//        val hour = calendar.get(java.util.Calendar.HOUR_OF_DAY)
//        val minute = calendar.get(java.util.Calendar.MINUTE)
//
//        if (hour == 23 && minute == 58) {
//            handleCriticalEvent("midnight_auto")
//            return
//        }
//
//        val currentLocationEnabled = isLocationEnabled()
//        val currentPermissionGranted = checkLocationPermission()
//
//        // ✅ DETECT PERMISSION REVOKED IMMEDIATELY (BEFORE LOCATION CHECK)
//        if (wasPermissionGranted && !currentPermissionGranted) {
//            debugPrint("🔐 [NATIVE] Permission REVOKED - Freezing timer immediately!")
//            handleCriticalEvent("permission_revoked_auto")
//            return
//        }
//
//        // Detect Location Turned OFF
//        if (wasLocationEnabled && !currentLocationEnabled) {
//            handleCriticalEvent("location_off_auto")
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
//    private fun debugPrint(message: String) {
//        android.util.Log.d("LocationMonitor", message)
//    }
//
//    private fun handleCriticalEvent(reason: String) {
//        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
//        val editor = prefs.edit()
//
//        val eventTime = Date()
//        val timestamp = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault()).format(eventTime)
//
//        // ✅ CHANGE 1: Timer always resets to 00:00:00 (not frozen at elapsed time)
//        // We still read elapsed_time for reference in payload, but frozen display is 00:00:00
//        val elapsedAtEvent = prefs.getString(KEY_ELAPSED_TIME, "00:00:00") ?: "00:00:00"
//
//        // Save critical event data
//        editor.putBoolean(KEY_HAS_CRITICAL_EVENT, true)
//        editor.putBoolean(KEY_IS_TIMER_FROZEN, true)
//        editor.putString(KEY_EVENT_TIMESTAMP, timestamp)
//        editor.putString(KEY_EVENT_REASON, reason)
//
//        // ✅ CHANGE 2: Save "00:00:00" as frozen display time (timer resets, not freezes)
//        editor.putString(KEY_FROZEN_TIME, "00:00:00")
//
//        editor.putFloat(KEY_EVENT_DISTANCE, 0.0f) // Will be updated by Flutter
//        editor.putFloat(KEY_EVENT_LAT, 0.0f)
//        editor.putFloat(KEY_EVENT_LNG, 0.0f)
//        editor.putBoolean(KEY_IS_CLOCKED_IN, false) // Mark as clocked out
//
//        // ✅ FIX: Save real event time — BOTH individual keys AND JSON blob
//        // Flutter ka restoreFastDataOnStartup pehle individual key padhta hai,
//        // agar nahi mila to JSON blob padhta hai — dono set karo guarantee ke liye
//        editor.putString("flutter.fastClockOutTime", timestamp)
//        editor.putFloat("flutter.fastClockOutDistance", 0.0f)
//        editor.putString("flutter.fastClockOutReason", reason)
//        editor.putBoolean("flutter.hasFastClockOutData", true)
//        editor.putBoolean("flutter.clockOutPending", true)
//
//        // ✅ JSON blob bhi save karo (Flutter format match karna zaroori hai)
//        val clockInTime = prefs.getString("flutter.clockInTime", "") ?: ""
//        val fastJson = """{"fast_attendanceId":"","fast_userId":"","fast_clockOutTime":"$timestamp","fast_totalTime":"00:00:00","fast_totalDistance":0.0,"fast_latOut":0.0,"fast_lngOut":0.0,"fast_address":"","fast_reason":"$reason","fast_savedAt":"${System.currentTimeMillis()}","fast_clockInTime":"$clockInTime"}"""
//        editor.putString("flutter.fastClockOutData", fastJson)
//
//        // ✅ CHANGE 3: Save complete background clockout payload as JSON for auto-sync on app open
//        val bgPayload = buildBgPayload(timestamp, reason, elapsedAtEvent)
//        editor.putString(KEY_BG_CLOCKOUT_PAYLOAD, bgPayload)
//
//        editor.apply()
//
//        debugPrint("💾 [NATIVE FIX] fastClockOutTime saved as REAL event time: $timestamp")
//
//        debugPrint("🔴 [NATIVE] Critical event saved: reason=$reason, timestamp=$timestamp, elapsedAtEvent=$elapsedAtEvent")
//
//        // Show urgent notification
//        showCriticalNotification(reason, timestamp)
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
//    // ✅ NEW: Build a JSON string payload with all event data for background sync
//    private fun buildBgPayload(timestamp: String, reason: String, elapsedAtEvent: String): String {
//        return """{"timestamp":"$timestamp","reason":"$reason","elapsed_at_event":"$elapsedAtEvent","distance":0.0,"latitude":0.0,"longitude":0.0,"source":"native_background"}"""
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
//    private fun showCriticalNotification(reason: String, time: String) {
//        val title = when (reason) {
//            "location_off_auto" -> "⚠️ LOCATION TURNED OFF"
//            "permission_revoked_auto" -> "⚠️ PERMISSION REVOKED"
//            "midnight_auto" -> "⚠️ MIDNIGHT AUTO CLOCKOUT"
//            else -> "⚠️ AUTO CLOCKOUT"
//        }
//
//        val message = "Time: $time\nApp was closed - Event captured. Open app to sync."
//
//        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//
//        // ✅ CHANGE 4: Notification tapping opens the app
//        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
//            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
//        }
//        val pendingIntent = PendingIntent.getActivity(
//            this, 0, launchIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
//        )
//
//        val notification = NotificationCompat.Builder(this, "urgent_auto_clockout_channel")
//            .setContentTitle(title)
//            .setContentText(message)
//            .setSmallIcon(R.mipmap.ic_launcher)
//            .setPriority(NotificationCompat.PRIORITY_MAX)
//            .setCategory(NotificationCompat.CATEGORY_ALARM)
//            .setAutoCancel(true)
//            .setContentIntent(pendingIntent) // ✅ tap to open app
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
//        // ✅ CHANGE 5: Wrapped in try-catch so permission check never crashes
//        return try {
//            ContextCompat.checkSelfPermission(
//                this,
//                Manifest.permission.ACCESS_FINE_LOCATION
//            ) == PackageManager.PERMISSION_GRANTED ||
//                    ContextCompat.checkSelfPermission(
//                        this,
//                        Manifest.permission.ACCESS_COARSE_LOCATION
//                    ) == PackageManager.PERMISSION_GRANTED
//        } catch (e: Exception) {
//            debugPrint("⚠️ [NATIVE] Permission check error: ${e.message}")
//            false // Treat as revoked if check fails
//        }
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
//            // Permission changes often trigger package changed events
//            handler.post { checkLocationAndPermission() }
//        }
//    }
//
//    private val screenReceiver = object : BroadcastReceiver() {
//        override fun onReceive(context: Context?, intent: Intent?) {
//            // Check immediately when screen turns on (user might have changed settings)
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
//            unregisterReceiver(screenReceiver)
//        } catch (e: Exception) {
//            // Receiver might not be registered
//        }
//    }
//}


///28-02-2026
package com.metaxperts.order_booking_app

import android.app.AppOpsManager
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

    // ✅ FIX 1: AppOpsManager listener for real-time permission revocation detection
    private var appOpsManager: AppOpsManager? = null
    private var appOpsCallback: Any? = null // AppOpsManager.OnOpChangedListener (API 19+)

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

    private val KEY_BG_CLOCKOUT_PAYLOAD = "flutter.bg_clockout_payload"

    override fun onCreate() {
        super.onCreate()
        handler = Handler(Looper.getMainLooper())
        registerReceivers()

        // ✅ FIX 2: Register AppOps listener for IMMEDIATE permission revocation detection
        // This fires the INSTANT the user revokes permission in settings — no polling delay
        registerAppOpsListener()
    }

    // ✅ FIX 3: AppOpsManager listener — works in foreground AND background
    // ACTION_PACKAGE_CHANGED does NOT fire for your own app's permission changes.
    // AppOpsManager is the only reliable way to detect real-time permission revocation.
    private fun registerAppOpsListener() {
        try {
            appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager

            // ✅ Use OnOpChangedListener for all API levels — compatible with Kotlin 1.9.x
            // OnOpActiveChangedListener has an unstable SAM lambda signature and is not needed
            // because we check permission state ourselves inside the callback.
            val listener = object : AppOpsManager.OnOpChangedListener {
                override fun onOpChanged(op: String?, pkg: String?) {
                    debugPrint("🔐 [APPOPS] Op changed: op=$op, pkg=$pkg")
                    handler.post { checkPermissionAndHandleRevocation() }
                }
            }
            appOpsManager?.startWatchingMode(
                AppOpsManager.OPSTR_FINE_LOCATION,
                this@LocationMonitorService.packageName,
                listener
            )
            appOpsCallback = listener
            debugPrint("✅ [APPOPS] OnOpChangedListener registered for FINE_LOCATION")
        } catch (e: Exception) {
            debugPrint("⚠️ [APPOPS] Failed to register AppOps listener: ${e.message}")
            // Polling in checkRunnable will still catch it as fallback
        }
    }

    // ✅ FIX 4: Dedicated permission-revoke handler (same logic as location_off)
    private fun checkPermissionAndHandleRevocation() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val clockedIn = prefs.getBoolean(KEY_IS_CLOCKED_IN, false)
        val isFrozen = prefs.getBoolean(KEY_IS_TIMER_FROZEN, false)

        if (!clockedIn || isFrozen) return

        val currentPermissionGranted = checkLocationPermission()
        if (!currentPermissionGranted) {
            debugPrint("🔐 [NATIVE] Permission confirmed REVOKED → handleCriticalEvent")
            handleCriticalEvent("permission_revoked_auto")
        }
    }

    private fun unregisterAppOpsListener() {
        try {
            val cb = appOpsCallback as? AppOpsManager.OnOpChangedListener ?: return
            appOpsManager?.stopWatchingMode(cb)
            appOpsCallback = null
            debugPrint("🛑 [APPOPS] Listener unregistered")
        } catch (e: Exception) {
            debugPrint("⚠️ [APPOPS] Error unregistering: ${e.message}")
        }
    }

    private fun registerReceivers() {
        // Listen for location mode changes
        val locationFilter = IntentFilter(LocationManager.MODE_CHANGED_ACTION)
        registerReceiver(locationModeReceiver, locationFilter)

        // ✅ FIX 5: Listen for MY OWN package permission changes
        // ACTION_PACKAGE_CHANGED fires for OTHER packages. Use both just in case.
        val packageFilter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_CHANGED)
            addAction("android.intent.action.PACKAGE_REMOVED")
            addDataScheme("package")
        }
        registerReceiver(packageReceiver, packageFilter)

        // ✅ FIX 6: Also listen for MY app specifically
        val myPackageFilter = IntentFilter("android.intent.action.MY_PACKAGE_REPLACED")
        registerReceiver(packageReceiver, myPackageFilter)

        val screenFilter = IntentFilter(Intent.ACTION_SCREEN_ON)
        registerReceiver(screenReceiver, screenFilter)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()
        // ✅ FIX: On Android 12+ (API 31+), startForeground() throws ForegroundServiceStartNotAllowedException
        // when called from a background-restricted context (e.g. triggered by broadcast while app is in background).
        // Use startForegroundService() from the Flutter side only when the app is visible, and guard here.
        try {
            startForeground(NOTIFICATION_ID, buildNotification())
        } catch (e: Exception) {
            debugPrint("⚠️ [NATIVE] startForeground failed (background restriction): ${e.message}")
            // Save state and stop gracefully — polling will restart us when app comes to foreground
            stopSelf()
            return START_NOT_STICKY
        }

        // Initialize states from current status
        wasLocationEnabled = isLocationEnabled()
        wasPermissionGranted = checkLocationPermission()

        debugPrint("🚀 [NATIVE] Service started. LocationEnabled=$wasLocationEnabled, PermissionGranted=$wasPermissionGranted")

        startMonitoring()

        return START_STICKY
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

        if (!isClockedIn) {
            updateNotification("Not clocked in", false)
            return
        }

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

        // ✅ FIX 7: Check PERMISSION first (before location) — same priority as location_off
        // When permission is revoked, location check may also fail — catch permission first
        if (wasPermissionGranted && !currentPermissionGranted) {
            debugPrint("🔐 [POLLING] Permission REVOKED detected via polling → handleCriticalEvent")
            handleCriticalEvent("permission_revoked_auto")
            return
        }

        // Detect Location Turned OFF
        if (wasLocationEnabled && !currentLocationEnabled) {
            debugPrint("📍 [POLLING] Location OFF detected → handleCriticalEvent")
            handleCriticalEvent("location_off_auto")
            return
        }

        // Update states for next check
        wasLocationEnabled = currentLocationEnabled
        wasPermissionGranted = currentPermissionGranted

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

        // ✅ FIX 8: Guard against duplicate event handling (same as location_off guard)
        val alreadyFrozen = prefs.getBoolean(KEY_IS_TIMER_FROZEN, false)
        if (alreadyFrozen) {
            debugPrint("⚠️ [NATIVE] Already frozen, skipping duplicate event: $reason")
            return
        }

        val editor = prefs.edit()

        val eventTime = Date()
        val timestamp = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault()).format(eventTime)

        val elapsedAtEvent = prefs.getString(KEY_ELAPSED_TIME, "00:00:00") ?: "00:00:00"

        editor.putBoolean(KEY_HAS_CRITICAL_EVENT, true)
        editor.putBoolean(KEY_IS_TIMER_FROZEN, true)
        editor.putString(KEY_EVENT_TIMESTAMP, timestamp)
        editor.putString(KEY_EVENT_REASON, reason)
        editor.putString(KEY_FROZEN_TIME, "00:00:00")
        editor.putFloat(KEY_EVENT_DISTANCE, 0.0f)
        editor.putFloat(KEY_EVENT_LAT, 0.0f)
        editor.putFloat(KEY_EVENT_LNG, 0.0f)
        editor.putBoolean(KEY_IS_CLOCKED_IN, false)

        editor.putString("flutter.fastClockOutTime", timestamp)
        editor.putFloat("flutter.fastClockOutDistance", 0.0f)
        editor.putString("flutter.fastClockOutReason", reason)
        editor.putBoolean("flutter.hasFastClockOutData", true)
        editor.putBoolean("flutter.clockOutPending", true)

        val clockInTime = prefs.getString("flutter.clockInTime", "") ?: ""
        val fastJson = """{"fast_attendanceId":"","fast_userId":"","fast_clockOutTime":"$timestamp","fast_totalTime":"00:00:00","fast_totalDistance":0.0,"fast_latOut":0.0,"fast_lngOut":0.0,"fast_address":"","fast_reason":"$reason","fast_savedAt":"${System.currentTimeMillis()}","fast_clockInTime":"$clockInTime"}"""
        editor.putString("flutter.fastClockOutData", fastJson)

        val bgPayload = buildBgPayload(timestamp, reason, elapsedAtEvent)
        editor.putString(KEY_BG_CLOCKOUT_PAYLOAD, bgPayload)

        // ✅ FIX 9: Use commit() instead of apply() for critical data
        // apply() is async — if process dies immediately after, data may not be flushed
        editor.commit()

        debugPrint("💾 [NATIVE] Critical event committed to disk: reason=$reason, timestamp=$timestamp")

        showCriticalNotification(reason, timestamp)
        updateNotification("⚠️ AUTO CLOCKOUT: $reason", true)

        // Stop all monitoring
        handler.removeCallbacks(checkRunnable)
        unregisterAppOpsListener()

        wakeUpBriefly()

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun buildBgPayload(timestamp: String, reason: String, elapsedAtEvent: String): String {
        return """{"timestamp":"$timestamp","reason":"$reason","elapsed_at_event":"$elapsedAtEvent","distance":0.0,"latitude":0.0,"longitude":0.0,"source":"native_background"}"""
    }

    private fun wakeUpBriefly() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            val wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "BookIT::CriticalEventWakeLock"
            )
            wakeLock.acquire(3000)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun showCriticalNotification(reason: String, time: String) {
        val title = when (reason) {
            "location_off_auto" -> "⚠️ LOCATION TURNED OFF"
            "permission_revoked_auto" -> "⚠️ PERMISSION REVOKED"
            "midnight_auto" -> "⚠️ MIDNIGHT AUTO CLOCKOUT"
            else -> "⚠️ AUTO CLOCKOUT"
        }

        val message = "Time: $time\nApp was closed - Event captured. Open app to sync."

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 0, launchIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(this, "urgent_auto_clockout_channel")
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
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
        return try {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED ||
                    ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.ACCESS_COARSE_LOCATION
                    ) == PackageManager.PERMISSION_GRANTED
        } catch (e: Exception) {
            debugPrint("⚠️ [NATIVE] Permission check error: ${e.message}")
            false
        }
    }

    private val locationModeReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == LocationManager.MODE_CHANGED_ACTION) {
                debugPrint("📡 [BROADCAST] Location mode changed")
                handler.post { checkLocationAndPermission() }
            }
        }
    }

    private val packageReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            // ✅ FIX 10: Only react if it's THIS package (not all packages)
            val changedPkg = intent?.data?.schemeSpecificPart
            if (changedPkg == null || changedPkg == packageName) {
                debugPrint("📡 [BROADCAST] Package/permission event for our app → checking permission")
                handler.post { checkPermissionAndHandleRevocation() }
            }
        }
    }

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            debugPrint("📡 [BROADCAST] Screen ON → checking state")
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
        unregisterAppOpsListener()
        try {
            unregisterReceiver(locationModeReceiver)
            unregisterReceiver(packageReceiver)
            unregisterReceiver(screenReceiver)
        } catch (e: Exception) {
            // Receiver might not be registered
        }
    }
}