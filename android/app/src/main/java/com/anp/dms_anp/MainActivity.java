package com.anp.dms_anp;

//import io.flutter.embedding.android.FlutterActivity;

//public class MainActivity extends FlutterActivity {
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        GeneratedPluginRegistrant.registerWith(this)
//    }
//    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//
//        super.onCreate(savedInstanceState);
//        FlutterAndroidLifecyclePlugin.registerWith(
//                registrarFor(
//                        "io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
//        LocalAuthPlugin.registerWith(registrarFor("io.flutter.plugins.localauth.LocalAuthPlugin"));
//    }
//}

import android.provider.Settings;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {
    private static final String DEVELOPER_MODE_CHANNEL = "dms_anp/developer_mode";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                DEVELOPER_MODE_CHANNEL
        ).setMethodCallHandler((call, result) -> {
            if ("isDeveloperModeEnabled".equals(call.method)) {
                int enabled = Settings.Global.getInt(
                        getContentResolver(),
                        Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                        0
                );
                result.success(enabled == 1);
            } else {
                result.notImplemented();
            }
        });
    }
}
