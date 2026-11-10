package com.anp.dms_anp;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.Uri;
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

import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class MainActivity extends FlutterFragmentActivity {
    private static final String TAG = "SimPhone";
    private static final String DEVELOPER_MODE_CHANNEL = "dms_anp/developer_mode";
    private static final String SIM_PHONE_CHANNEL = "dms_anp/sim_phone";
    private static final String VPN_CHANNEL = "dms_anp/vpn_guard";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                DEVELOPER_MODE_CHANNEL
        ).setMethodCallHandler((call, result) -> {
            if ("isDeveloperModeEnabled".equals(call.method)) {
                try {
                    int enabled = Settings.Global.getInt(
                            getContentResolver(),
                            Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                            0
                    );
                    result.success(enabled == 1);
                } catch (Exception e) {
                    try {
                        int enabled = Settings.Secure.getInt(
                                getContentResolver(),
                                Settings.Secure.DEVELOPMENT_SETTINGS_ENABLED,
                                0
                        );
                        result.success(enabled == 1);
                    } catch (Exception ex) {
                        result.success(false);
                    }
                }
            } else if ("openDeveloperSettings".equals(call.method)) {
                try {
                    Intent intent = new Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(intent);
                    result.success(true);
                } catch (Exception e) {
                    try {
                        Intent intent = new Intent(Settings.ACTION_SETTINGS);
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        startActivity(intent);
                        result.success(true);
                    } catch (Exception ex) {
                        result.success(false);
                    }
                }
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

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                VPN_CHANNEL
        ).setMethodCallHandler((call, result) -> {
            if ("isVpnActive".equals(call.method)) {
                result.success(isVpnActive());
            } else if ("getInstalledVpnApps".equals(call.method)) {
                result.success(getInstalledVpnApps());
            } else if ("isVpnDetected".equals(call.method)) {
                result.success(isVpnDetected());
            } else if ("openVpnSettings".equals(call.method)) {
                result.success(openVpnSettings());
            } else {
                result.notImplemented();
            }
        });
    }

    private boolean isVpnActive() {
        try {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
            if (cm != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    Network activeNetwork = cm.getActiveNetwork();
                    if (activeNetwork != null) {
                        NetworkCapabilities caps = cm.getNetworkCapabilities(activeNetwork);
                        if (caps != null) {
                            if (caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN) ||
                                !caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)) {
                                Log.d(TAG, "VPN detected via activeNetwork (TRANSPORT_VPN or !NET_CAPABILITY_NOT_VPN)");
                                return true;
                            }
                        }
                    }
                    Network[] networks = cm.getAllNetworks();
                    if (networks != null) {
                        for (Network network : networks) {
                            NetworkCapabilities caps = cm.getNetworkCapabilities(network);
                            if (caps != null) {
                                if (caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN) ||
                                    !caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)) {
                                    Log.d(TAG, "VPN detected via allNetworks TRANSPORT_VPN");
                                    return true;
                                }
                            }
                        }
                    }
                } else {
                    @SuppressWarnings("deprecation")
                    NetworkInfo vpnInfo = cm.getNetworkInfo(ConnectivityManager.TYPE_VPN);
                    if (vpnInfo != null && vpnInfo.isConnected()) {
                        Log.d(TAG, "VPN detected via TYPE_VPN");
                        return true;
                    }
                }
            }

            // Layer 2: Cek nama network interface virtual (tun, tap, ppp, vpn, wg)
            try {
                Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
                if (interfaces != null) {
                    while (interfaces.hasMoreElements()) {
                        NetworkInterface intf = interfaces.nextElement();
                        try {
                            String name = intf.getName().toLowerCase();
                            if (name.contains("tun") || name.contains("tap") ||
                                name.contains("vpn") || name.startsWith("ppp") ||
                                name.startsWith("ipsec") || name.startsWith("wg")) {

                                boolean isUp = false;
                                try {
                                    isUp = intf.isUp();
                                } catch (Exception ignored) {}

                                boolean hasAddresses = false;
                                try {
                                    hasAddresses = intf.getInterfaceAddresses() != null && !intf.getInterfaceAddresses().isEmpty();
                                } catch (Exception ignored) {}

                                if (isUp || hasAddresses || name.startsWith("tun") || name.startsWith("tap")) {
                                    Log.d(TAG, "VPN detected via interface: " + name + " (isUp=" + isUp + ", hasAddresses=" + hasAddresses + ")");
                                    return true;
                                }
                            }
                        } catch (Exception e) {
                            Log.w(TAG, "Error checking network interface: " + e.getMessage());
                        }
                    }
                }
            } catch (Exception e) {
                Log.w(TAG, "Error enumerating interfaces: " + e.getMessage());
            }
        } catch (Exception e) {
            Log.e(TAG, "Error checking VPN: " + e.getMessage());
        }
        return false;
    }

    private List<String> getInstalledVpnApps() {
        Set<String> appNames = new LinkedHashSet<>();
        try {
            PackageManager pm = getPackageManager();
            String myPkg = getPackageName();

            // Method 1: Query services implementing android.net.VpnService
            try {
                Intent vpnIntent = new Intent("android.net.VpnService");
                List<ResolveInfo> services = pm.queryIntentServices(vpnIntent, 0);
                if (services != null) {
                    for (ResolveInfo ri : services) {
                        if (ri.serviceInfo != null && ri.serviceInfo.packageName != null) {
                            String pkg = ri.serviceInfo.packageName;
                            if (!pkg.equals(myPkg)) {
                                try {
                                    CharSequence label = ri.serviceInfo.applicationInfo.loadLabel(pm);
                                    appNames.add(label != null ? label.toString() : pkg);
                                } catch (Exception e) {
                                    appNames.add(pkg);
                                }
                            }
                        }
                    }
                }
            } catch (Exception e) {
                Log.w(TAG, "Error querying VpnService: " + e.getMessage());
            }

            // Method 2: Cek daftar package VPN populer (Turbo VPN, WARP, OpenVPN, dsb)
            String[] knownVpnPackages = new String[] {
                "free.vpn.unblock.proxy.turbovpn",          // Turbo VPN
                "free.vpn.unblock.proxy.turbovpn.lite",     // Turbo VPN Lite
                "com.turbo.vpn",
                "free.vpn.unblock.proxy.vpn.master.pro",    // VPN Master
                "com.cloudflare.onedotonedotonedotone",     // 1.1.1.1 Cloudflare WARP
                "com.nordvpn.android",                      // NordVPN
                "com.expressvpn.vpn",                       // ExpressVPN
                "ch.protonvpn.android",                     // ProtonVPN
                "org.torproject.torbrowser",                // Tor Browser
                "org.torproject.android",                   // Orbot
                "com.wireguard.android",                    // WireGuard
                "org.openvpn.openvpn",                      // OpenVPN Connect
                "de.blinkt.openvpn",                        // OpenVPN for Android
                "com.psiphon3.subscription",                // Psiphon
                "com.psiphon3",
                "com.fast.free.unblock.secure.vpn",         // SuperVPN
                "hotspotshield.android.vpn",                // Hotspot Shield
                "com.purevpn.android",                      // PureVPN
                "com.surfshark.vpnclient.android",          // Surfshark
                "com.windscribe.vpn",                       // Windscribe
                "com.vpnhub.vpn",                           // VPNhub
                "com.anchorfree.vpnsentry",                 // Betternet
                "com.mullvad.vpn",                          // Mullvad
                "com.tunnelbear.android",                   // TunnelBear
                "org.proxydroid",                           // ProxyDroid
                "com.github.shadowsocks",                   // Shadowsocks
                "com.vpn.free.master",
                "com.supervpn.vpn",
                "com.freevpn.android"
            };

            for (String pkg : knownVpnPackages) {
                try {
                    pm.getPackageInfo(pkg, 0);
                    try {
                        CharSequence label = pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0));
                        appNames.add(label != null ? label.toString() : pkg);
                    } catch (Exception ex) {
                        appNames.add(pkg);
                    }
                } catch (PackageManager.NameNotFoundException ignored) {
                    // Aplikasi tidak terinstal
                } catch (Exception e) {
                    Log.w(TAG, "Error checking package " + pkg + ": " + e.getMessage());
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Error in getInstalledVpnApps: " + e.getMessage());
        }
        return new ArrayList<>(appNames);
    }

    private boolean isVpnDetected() {
        return isVpnActive() || !getInstalledVpnApps().isEmpty();
    }

    private boolean openVpnSettings() {
        try {
            Intent intent = new Intent(Settings.ACTION_VPN_SETTINGS);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            return true;
        } catch (Exception e) {
            try {
                Intent intent = new Intent(Settings.ACTION_WIRELESS_SETTINGS);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                return true;
            } catch (Exception ex) {
                try {
                    Intent intent = new Intent(Settings.ACTION_SETTINGS);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(intent);
                    return true;
                } catch (Exception exc) {
                    return false;
                }
            }
        }
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
