package fun.F403.ascent;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    final String channelName = "adb";
    MethodChannel channel;
    private void initPlugin(FlutterEngine flutterEngine) {
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), channelName);
        channel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "get_lib_path":
                    runOnUiThread(() -> {
                        result.success(getApplicationInfo().nativeLibraryDir);
                    });
                    break;
                default:
                    break;
            }
        });
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        initPlugin(flutterEngine);
    }
}
