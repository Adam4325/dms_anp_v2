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

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

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
            } else if ("getAllSimPhoneNumbers".equals(call.method)) {
                result.success(getAllSimPhoneNumbers());
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

    private void addPhoneIfPresent(Set<String> phones, String raw) {
        if (raw == null) {
            return;
        }
        String trimmed = raw.trim();
        if (!trimmed.isEmpty()) {
            phones.add(trimmed);
        }
    }

    /**
     * Fallback nomor per subscription.
     * getLine1Number() deprecated sejak API 33; dipakai hanya jika getNumber() kosong.
     */
    @SuppressWarnings("deprecation")
    private String readLine1ForSubscription(TelephonyManager telephonyManager, int subscriptionId) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            TelephonyManager slotManager =
                    telephonyManager.createForSubscriptionId(subscriptionId);
            if (slotManager != null) {
                return slotManager.getLine1Number();
            }
        }
        return telephonyManager.getLine1Number();
    }

    @SuppressWarnings("deprecation")
    private String readDefaultLine1Number(TelephonyManager telephonyManager) {
        return telephonyManager.getLine1Number();
    }

    /** Semua nomor MSISDN yang terbaca dari SIM aktif (slot manapun). */
    private List<String> getAllSimPhoneNumbers() {
        List<String> empty = new ArrayList<>();
        if (!hasPhonePermission()) {
            return empty;
        }

        TelephonyManager telephonyManager =
                (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        if (telephonyManager == null) {
            return empty;
        }

        Set<String> phones = new LinkedHashSet<>();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            SubscriptionManager subscriptionManager =
                    (SubscriptionManager) getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE);
            if (subscriptionManager != null) {
                List<SubscriptionInfo> subscriptions =
                        subscriptionManager.getActiveSubscriptionInfoList();
                if (subscriptions != null) {
                    for (SubscriptionInfo info : subscriptions) {
                        if (info == null) {
                            continue;
                        }
                        // API 33+: SubscriptionInfo.getNumber() (pengganti getLine1Number)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            addPhoneIfPresent(phones, info.getNumber());
                        }
                        addPhoneIfPresent(
                                phones,
                                readLine1ForSubscription(
                                        telephonyManager, info.getSubscriptionId()));
                    }
                }
            }
        }

        addPhoneIfPresent(phones, readDefaultLine1Number(telephonyManager));
        return new ArrayList<>(phones);
    }

    private String getSim1PhoneNumber() {
        List<String> all = getAllSimPhoneNumbers();
        if (all.isEmpty()) {
            return null;
        }
        return all.get(0);
    }
}
