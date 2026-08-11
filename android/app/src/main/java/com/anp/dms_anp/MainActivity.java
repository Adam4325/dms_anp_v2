package com.anp.dms_anp;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import android.telephony.TelephonyManager;
import android.util.Log;

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
    private static final String TAG = "SimPhone";
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

    private boolean hasPhoneStatePermission() {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE)
                == PackageManager.PERMISSION_GRANTED;
    }

    private boolean hasPhoneNumbersPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return hasPhoneStatePermission();
        }
        return ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_NUMBERS)
                == PackageManager.PERMISSION_GRANTED;
    }

    private void addPhoneIfPresent(Set<String> phones, String raw) {
        if (raw == null) {
            return;
        }
        String trimmed = raw.trim();
        if (!trimmed.isEmpty() && !trimmed.equalsIgnoreCase("null")) {
            phones.add(trimmed);
        }
    }

    /**
     * Fallback nomor per subscription.
     * getLine1Number() deprecated sejak API 33; dipakai hanya jika getNumber()/getPhoneNumber kosong.
     */
    @SuppressWarnings("deprecation")
    private String readLine1ForSubscription(TelephonyManager telephonyManager, int subscriptionId) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                TelephonyManager slotManager =
                        telephonyManager.createForSubscriptionId(subscriptionId);
                if (slotManager != null) {
                    return slotManager.getLine1Number();
                }
            }
            return telephonyManager.getLine1Number();
        } catch (SecurityException e) {
            Log.w(TAG, "readLine1ForSubscription denied: " + e.getMessage());
            return null;
        }
    }

    @SuppressWarnings("deprecation")
    private String readDefaultLine1Number(TelephonyManager telephonyManager) {
        try {
            return telephonyManager.getLine1Number();
        } catch (SecurityException e) {
            Log.w(TAG, "readDefaultLine1Number denied: " + e.getMessage());
            return null;
        }
    }

    /** Semua nomor MSISDN yang terbaca dari SIM aktif (slot manapun). */
    private List<String> getAllSimPhoneNumbers() {
        List<String> empty = new ArrayList<>();
        boolean hasState = hasPhoneStatePermission();
        boolean hasNumbers = hasPhoneNumbersPermission();
        Log.d(TAG, "perm state=" + hasState + " numbers=" + hasNumbers
                + " sdk=" + Build.VERSION.SDK_INT);

        // Tanpa salah satu izin, tidak bisa baca nomor
        if (!hasState && !hasNumbers) {
            Log.w(TAG, "No phone permissions granted");
            return empty;
        }

        TelephonyManager telephonyManager =
                (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        if (telephonyManager == null) {
            return empty;
        }

        Set<String> phones = new LinkedHashSet<>();

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                SubscriptionManager subscriptionManager =
                        (SubscriptionManager) getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE);
                if (subscriptionManager != null) {
                    List<SubscriptionInfo> subscriptions = null;
                    try {
                        if (hasState || hasNumbers) {
                            subscriptions = subscriptionManager.getActiveSubscriptionInfoList();
                        }
                    } catch (SecurityException e) {
                        Log.w(TAG, "getActiveSubscriptionInfoList denied: " + e.getMessage());
                    }

                    if (subscriptions != null) {
                        Log.d(TAG, "active SIMs=" + subscriptions.size());
                        for (SubscriptionInfo info : subscriptions) {
                            if (info == null) {
                                continue;
                            }
                            int subId = info.getSubscriptionId();

                            // API 33+: sumber nomor yang direkomendasikan Google
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && hasNumbers) {
                                try {
                                    addPhoneIfPresent(
                                            phones, subscriptionManager.getPhoneNumber(subId));
                                } catch (SecurityException e) {
                                    Log.w(TAG, "getPhoneNumber denied sub=" + subId + ": "
                                            + e.getMessage());
                                } catch (Exception e) {
                                    Log.w(TAG, "getPhoneNumber failed sub=" + subId + ": "
                                            + e.getMessage());
                                }
                            }

                            // API 33+: SubscriptionInfo.getNumber()
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                try {
                                    addPhoneIfPresent(phones, info.getNumber());
                                } catch (SecurityException e) {
                                    Log.w(TAG, "SubscriptionInfo.getNumber denied: "
                                            + e.getMessage());
                                }
                            }

                            addPhoneIfPresent(
                                    phones, readLine1ForSubscription(telephonyManager, subId));
                        }
                    } else {
                        Log.w(TAG, "No active subscription info");
                    }
                }
            }

            addPhoneIfPresent(phones, readDefaultLine1Number(telephonyManager));
        } catch (Exception e) {
            Log.e(TAG, "getAllSimPhoneNumbers failed", e);
        }

        Log.d(TAG, "phones found=" + phones.size() + " values=" + phones);
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
