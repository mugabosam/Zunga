package rw.zunga

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    /** Route requested by an app shortcut (zunga://send etc.). */
    private var launchRoute: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // FLAG_SECURE everywhere: balances, tokens and PIN entry must not
        // appear in screenshots, screen recordings or the recents
        // thumbnail (§6.6).
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        launchRoute = routeFromIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        launchRoute = routeFromIntent(intent)
    }

    private fun routeFromIntent(intent: Intent?): String? {
        val data = intent?.data ?: return null
        return if (data.scheme == "zunga") "/${data.host ?: return null}" else null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        UssdChannel.register(this, flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rw.zunga/shortcuts")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getLaunchRoute" -> {
                        result.success(launchRoute)
                        launchRoute = null
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
