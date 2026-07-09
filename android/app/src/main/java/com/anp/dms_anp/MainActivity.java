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

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import android.telephony.TelephonyManager;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.util.List;

public class MainActivity extends FlutterFragmentActivity {
    private static final String DEVELOPER_MODE_CHANNEL = "dms_anp/developer_mode";
    private static final String SIM_PHONE_CHANNEL = "dms_anp/sim_phone";

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

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                SIM_PHONE_CHANNEL
        ).setMethodCallHandler((call, result) -> {
            if ("getSim1PhoneNumber".equals(call.method)) {
                result.success(getSim1PhoneNumber());
            } else {
                result.notImplemented();
            }
        });
    }

    private boolean hasPhonePermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE)
                != PackageManager.PERMISSION_GRANTED) {
            return false;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_NUMBERS)
                    == PackageManager.PERMISSION_GRANTED;
        }
        return true;
    }

    private String getSim1PhoneNumber() {
        if (!hasPhonePermission()) {
            return null;
        }

        TelephonyManager telephonyManager =
                (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        if (telephonyManager == null) {
            return null;
        }

        String phoneNumber = null;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            SubscriptionManager subscriptionManager =
                    (SubscriptionManager) getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE);
            if (subscriptionManager != null) {
                List<SubscriptionInfo> subscriptions =
                        subscriptionManager.getActiveSubscriptionInfoList();
                if (subscriptions != null && !subscriptions.isEmpty()) {
                    SubscriptionInfo sim1 = null;
                    for (SubscriptionInfo info : subscriptions) {
                        if (info.getSimSlotIndex() == 0) {
                            sim1 = info;
                            break;
                        }
                    }
                    if (sim1 == null) {
                        sim1 = subscriptions.get(0);
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        TelephonyManager slotManager =
                                telephonyManager.createForSubscriptionId(sim1.getSubscriptionId());
                        phoneNumber = slotManager.getLine1Number();
                    } else {
                        phoneNumber = telephonyManager.getLine1Number();
                    }
                }
            }
        }

        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            phoneNumber = telephonyManager.getLine1Number();
        }

        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            return null;
        }
        return phoneNumber.trim();
    }
}
