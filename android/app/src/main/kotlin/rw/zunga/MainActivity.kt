package rw.zunga

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rw.zunga/app")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareApk" -> {
                        result.success(shareApk())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Shares the exact APK currently running — always the freshest build
     * during development. At Play launch this switches to sharing the
     * store listing instead.
     */
    private fun shareApk(): Boolean {
        return try {
            val source = File(applicationInfo.sourceDir)
            val outDir = File(cacheDir, "share").apply { mkdirs() }
            val out = File(outDir, "Zunga.apk")
            source.copyTo(out, overwrite = true)
            val uri = FileProvider.getUriForFile(this, "rw.zunga.fileprovider", out)
            val send = Intent(Intent.ACTION_SEND).apply {
                type = "application/vnd.android.package-archive"
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(send, "Share Zunga"))
            true
        } catch (_: Exception) {
            false
        }
    }
}
