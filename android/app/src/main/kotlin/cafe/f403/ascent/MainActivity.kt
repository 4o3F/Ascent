package cafe.f403.ascent

import androidx.annotation.NonNull
import android.provider.Settings
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "cafe.f403.ascent/main"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getDeveloperOptionEnabled") {
                result.success(isDevMode(this))
            } else {
                result.notImplemented()
            }
        }
    }

    // DEVELOPMENT_SETTINGS_ENABLED lives in Settings.Global since API 17; newer Android
    // no longer redirects Settings.Secure lookups of moved keys, so read Global directly.
    fun isDevMode(context: Context): Boolean {
        return Settings.Global.getInt(
            context.contentResolver,
            Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0
        ) != 0
    }
}
