package com.personal.knowledge_hub

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Places a call (or runs a USSD code) straight away when the user allows
 * phone calls; otherwise opens the dialer with the number filled in.
 */
class MainActivity : FlutterActivity() {
    private var pendingNumber: String? = null
    private var pendingResult: MethodChannel.Result? = null

    /** Ask for the screen's fastest refresh rate (90/120 Hz), same size. */
    override fun onPostResume() {
        super.onPostResume()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val screen = (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) this.display
            else @Suppress("DEPRECATION") windowManager.defaultDisplay) ?: return
        val current = screen.mode
        val best = screen.supportedModes
            .filter {
                it.physicalWidth == current.physicalWidth &&
                    it.physicalHeight == current.physicalHeight
            }
            .maxByOrNull { it.refreshRate } ?: return
        if (best.modeId == window.attributes.preferredDisplayModeId) return
        window.attributes = window.attributes.apply {
            preferredDisplayModeId = best.modeId
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "call") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val number = call.argument<String>("number")
                if (number.isNullOrBlank()) {
                    result.success(false)
                    return@setMethodCallHandler
                }
                if (hasCallPermission()) {
                    result.success(start(number, direct = true))
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    pendingResult?.success(start(pendingNumber ?: number, direct = false))
                    pendingNumber = number
                    pendingResult = result
                    requestPermissions(arrayOf(Manifest.permission.CALL_PHONE), REQUEST)
                } else {
                    result.success(start(number, direct = false))
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST) return
        val number = pendingNumber
        val result = pendingResult
        pendingNumber = null
        pendingResult = null
        if (number == null || result == null) return
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        result.success(start(number, direct = granted))
    }

    private fun hasCallPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            checkSelfPermission(Manifest.permission.CALL_PHONE) ==
            PackageManager.PERMISSION_GRANTED

    /** `#` is encoded by [Uri.fromParts], so USSD codes run as typed. */
    private fun start(number: String, direct: Boolean): Boolean {
        val uri = Uri.fromParts("tel", number, null)
        val action = if (direct) Intent.ACTION_CALL else Intent.ACTION_DIAL
        return try {
            startActivity(Intent(action, uri))
            true
        } catch (e: Exception) {
            if (!direct) return false
            try {
                startActivity(Intent(Intent.ACTION_DIAL, uri))
                true
            } catch (e: Exception) {
                false
            }
        }
    }

    companion object {
        private const val CHANNEL = "counter_guide/call"
        private const val REQUEST = 4401
    }
}
