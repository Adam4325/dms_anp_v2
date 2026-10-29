import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/loginPage.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewProfileUser extends StatefulWidget {
  const ViewProfileUser({Key? key}) : super(key: key);

  @override
  State<ViewProfileUser> createState() => _ViewProfileUserState();
}

class _ViewProfileUserState extends State<ViewProfileUser> {
  // Controllers
  final TextEditingController txtUsername = TextEditingController();
  final TextEditingController txtOldPassword = TextEditingController();
  final TextEditingController txtNewPassword = TextEditingController();
  final TextEditingController txtOldPhone = TextEditingController();
  final TextEditingController txtNewPhone = TextEditingController();

  // Password visibility
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;

  // Design Tokens (Brand Orange & Glassmorphic Palette)
  static const Color primaryOrange = Color(0xFFFF6600);
  static const Color accentOrange = Color(0xFFFF8533);
  static const Color lightOrange = Color(0xFFFFF3EB);
  static const Color surfaceBg = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // User Data
  String loginname = "";
  String drvid = "";
  String vhcid = "";
  String mechanicid = "";
  String username = "";
  String name = "";
  String locid = "";
  String cpyname = "";

  // Driver Profile Data
  String driverName = "";
  String nickname = "";
  String placeOfBirth = "";
  String address = "";
  String city = "";
  String provinsi = "";
  String ktp = "";
  String ktpNumber = "";
  String sim = "";
  String simNumber = "";
  String simExpired = "";
  String statusVehicle = "";
  String stnkBerlaku = "";
  String kryid = "";
  String status_karyawan = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    txtUsername.dispose();
    txtOldPassword.dispose();
    txtNewPassword.dispose();
    txtOldPhone.dispose();
    txtNewPhone.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (EasyLoading.isShow) EasyLoading.dismiss();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginname = prefs.getString("loginname") ?? "";
      drvid = prefs.getString("drvid") ?? "";
      vhcid = prefs.getString("vhcid") ?? "";
      mechanicid = prefs.getString("mechanicid") ?? "";
      username = prefs.getString("username") ?? "";
      name = prefs.getString("name") ?? "";
      locid = prefs.getString("locid") ?? "";
      cpyname = prefs.getString("cpyname") ?? "";
      status_karyawan = prefs.getString("status_karyawan") ?? "";
      kryid = prefs.getString("kryid") ?? "";
      txtUsername.text = username;
      _isLoading = false;
    });

    if (loginname == "DRIVER") {
      await _loadDriverProfile();
    }
  }

  Future<void> _loadDriverProfile() async {
    try {
      final url = "${GlobalData.baseUrl}api/profile_user.jsp?method=driver&driverid=$drvid";
      final response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

      final data = json.decode(response.body)["data"];
      if (data != null && data.isNotEmpty) {
        setState(() {
          driverName = data[0]['drviername'] ?? "";
          nickname = data[0]['drvbickname'] ?? "";
          placeOfBirth = data[0]['placeofbirth'] ?? "";
          address = data[0]['address'] ?? "";
          city = data[0]['city'] ?? "";
          provinsi = data[0]['provinsi'] ?? "";
          ktp = data[0]['identitas_type'] ?? "";
          ktpNumber = data[0]['identitas_nbr'] ?? "";
          sim = data[0]['license_type'] ?? "";
          simNumber = data[0]['license_nbr'] ?? "";
          simExpired = data[0]['simdate'] ?? "";
          statusVehicle = data[0]['status'] ?? "";
          txtOldPhone.text = data[0]['phone'] ?? "";

          var stnkLast = data[0]['nmtlastvalue'] ?? "";
          var stnkNext = data[0]['nmtnextvalue'] ?? "";
          stnkBerlaku = "$stnkLast-$stnkNext";
        });
      } else {
        if (mounted) alert(context, 0, "Data driver tidak ditemukan", "error");
      }
    } catch (e) {
      if (mounted) alert(context, 0, "Error loading profile: $e", "error");
    }
  }

  Future<void> _changePassword() async {
    if (!_validatePassword()) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String driverid = prefs.getString("drvid") ?? "";
      String userid = prefs.getString("name") ?? "";

      final url = "${GlobalData.baseUrl}api/change_password_user.jsp?method=driver&driverid="
          "$driverid&userid=$userid&username=${txtUsername.text}&oldpassword=${txtOldPassword.text}&password=${txtNewPassword.text}";

      final response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      final result = json.decode(response.body);

      if (result["status_code"] == "200") {
        _showSuccessDialog("${result["message"]}, silakan login kembali", () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        });
      } else {
        if (mounted) alert(context, 0, result["message"], "error");
      }
    } catch (e) {
      if (mounted) alert(context, 0, "Error changing password: $e", "error");
    }
  }

  Future<void> _updatePhone() async {
    if (txtNewPhone.text.isEmpty) {
      alert(context, 0, "Nomor telepon baru tidak boleh kosong", "error");
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String driverid = prefs.getString("drvid") ?? "";
      String userid = prefs.getString("name") ?? "";

      final url = "${GlobalData.baseUrl}api/change_phone_user.jsp?method=update-phone-driver&driverid="
          "$driverid&new_phone=${txtNewPhone.text}&userid=$userid";

      final response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      final result = json.decode(response.body);

      if (result["status_code"] == "200") {
        _showSuccessDialog(result["message"], () {
          setState(() {
            txtOldPhone.text = txtNewPhone.text;
            txtNewPhone.clear();
          });
        });
      } else {
        if (mounted) alert(context, 0, result["message"], "error");
      }
    } catch (e) {
      if (mounted) alert(context, 0, "Error updating phone: $e", "error");
    }
  }

  Future<void> _updateImeiId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String imeiId = prefs.getString("androidID") ?? "";

    if (imeiId.isEmpty) {
      alert(context, 0, "IMEI ID tidak ditemukan pada perangkat", "error");
      return;
    }

    try {
      String userid = prefs.getString("name") ?? "";

      final url = "${GlobalData.baseUrl}api/change_imeiid_user.jsp?method=change-imeiid-v1&imeiid="
          "$imeiId&id=$drvid&loginname=$loginname&username=$drvid&userid=$userid";

      final response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      final result = json.decode(response.body);

      if (result["status_code"] == "200") {
        _showSuccessDialog("${result["message"]}, silakan login kembali", () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        });
      } else {
        if (mounted) alert(context, 0, result["message"], "error");
      }
    } catch (e) {
      if (mounted) alert(context, 0, "Error updating IMEI: $e", "error");
    }
  }

  bool _validatePassword() {
    if (txtUsername.text.isEmpty) {
      alert(context, 0, "Username tidak boleh kosong", "error");
      return false;
    }
    if (txtUsername.text.length <= 5) {
      alert(context, 0, "Username minimal 6 karakter", "error");
      return false;
    }
    if (txtOldPassword.text.isEmpty) {
      alert(context, 0, "Password lama tidak boleh kosong", "error");
      return false;
    }
    if (txtNewPassword.text.isEmpty) {
      alert(context, 0, "Password baru tidak boleh kosong", "error");
      return false;
    }
    if (txtNewPassword.text.length <= 5) {
      alert(context, 0, "Password baru minimal 6 karakter", "error");
      return false;
    }
    return true;
  }

  void _showSuccessDialog(String message, VoidCallback onOk) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF16A34A)),
            SizedBox(width: 8),
            Text('Informasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onOk();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _performActionWithLoading(Future<void> Function() action) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.pop(context);
    await action();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Konfirmasi Keluar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    'Apakah Anda yakin ingin keluar dari akun ini?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogCtx, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Ya, Keluar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String oldLoginname = prefs.getString('loginname') ?? "";
      String bujnumber = prefs.getString('bujnumber') ?? "";
      String oldVhcid = prefs.getString('vhcid') ?? "";
      String oldDrvid = prefs.getString('drvid') ?? "";

      await prefs.clear();

      if (bujnumber.isNotEmpty && oldLoginname == 'DRIVER') {
        prefs.setString('bujnumber', bujnumber);
        prefs.setString('vhcid', oldVhcid);
        prefs.setString('drvid', oldDrvid);
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    }
  }

  void _copyToClipboard(String label, String value) {
    if (value.isEmpty || value == "-") return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
  }

  String _getInitials(String str) {
    if (str.trim().isEmpty) return "US";
    final parts = str.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = name.isNotEmpty
        ? name
        : (driverName.isNotEmpty ? driverName : (username.isNotEmpty ? username : "Pengguna"));
    final String initials = _getInitials(displayName);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewDashboard()),
        );
      },
      child: Scaffold(
        backgroundColor: surfaceBg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, accentOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26FF6600),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Back button
                    InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => ViewDashboard()),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title
                    const Expanded(
                      child: Text(
                        'User Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Refresh Action
                    InkWell(
                      onTap: () {
                        setState(() => _isLoading = true);
                        _loadUserData();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryOrange))
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                children: [
                  // 1. Hero Profile Card
                  _buildHeroProfileCard(displayName, initials),
                  const SizedBox(height: 18),

                  // 2. Profile Information
                  _buildSectionHeader(
                    icon: Icons.person_rounded,
                    iconBg: const Color(0xFFFFF3EB),
                    iconColor: primaryOrange,
                    title: "Informasi Profil",
                    subtitle: "Detail data pribadi dan kepegawaian",
                  ),
                  const SizedBox(height: 8),
                  _buildProfileCard(),
                  const SizedBox(height: 18),

                  // 3. Account Settings
                  _buildSectionHeader(
                    icon: Icons.manage_accounts_rounded,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    title: "Pengaturan Akun",
                    subtitle: "Hak akses login dan lokasi penugasan",
                  ),
                  const SizedBox(height: 8),
                  _buildAccountSettingsCard(),
                  const SizedBox(height: 18),

                  // 4. Phone Update (for DRIVER)
                  if (loginname == "DRIVER") ...[
                    _buildSectionHeader(
                      icon: Icons.phone_android_rounded,
                      iconBg: const Color(0xFFF0FDF4),
                      iconColor: const Color(0xFF16A34A),
                      title: "Pembaruan No. Telepon",
                      subtitle: "Sinkronisasi nomor telepon pengemudi",
                    ),
                    const SizedBox(height: 8),
                    _buildPhoneUpdateCard(),
                    const SizedBox(height: 18),
                  ],

                  // 5. Password Change
                  _buildSectionHeader(
                    icon: Icons.lock_outline_rounded,
                    iconBg: const Color(0xFFFAF5FF),
                    iconColor: const Color(0xFF9333EA),
                    title: "Keamanan & Kata Sandi",
                    subtitle: "Kelola kata sandi akun Anda secara berkala",
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordChangeCard(),
                  const SizedBox(height: 18),

                  // 6. Device Settings (Fingerprint / IMEI)
                  if (loginname != "MECHANIC") ...[
                    _buildSectionHeader(
                      icon: Icons.fingerprint_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: "Keamanan Perangkat",
                      subtitle: "Validasi Device ID untuk keamanan sistem",
                    ),
                    const SizedBox(height: 8),
                    _buildDeviceSettingsCard(),
                    const SizedBox(height: 18),
                  ],

                  // 7. Account Actions (Logout)
                  _buildSectionHeader(
                    icon: Icons.shield_outlined,
                    iconBg: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFDC2626),
                    title: "Aksi Akun",
                    subtitle: "Selesai sesi operasional",
                  ),
                  const SizedBox(height: 8),
                  _buildLogoutCard(),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  // Hero Card at Top
  Widget _buildHeroProfileCard(String displayName, String initials) {
    final String roleBadge = loginname.isNotEmpty ? loginname : "KARYAWAN";
    final String rawStatus = status_karyawan.isNotEmpty && status_karyawan.toLowerCase() != "null"
        ? status_karyawan
        : "Active";
    final String statusDisplay =
        (rawStatus.toUpperCase() == roleBadge.toUpperCase()) ? "Active" : rawStatus;

    String clean(String? val) {
      if (val == null) return "-";
      final s = val.trim();
      if (s.isEmpty || s.toLowerCase() == "null") return "-";
      return s;
    }

    final String cleanLoc = clean(locid.isNotEmpty ? locid.split(',').first : "");
    final String cleanUnit = clean(vhcid);
    final String cleanDrvid = clean(drvid);
    final String cleanKry = clean(kryid);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle top gradient bar
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, accentOrange],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar Initials with Ring
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8533), primaryOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name & Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cpyname.isNotEmpty ? cpyname : "ANDALAN NUSA PRATAMA PT",
                            style: const TextStyle(
                              fontSize: 12,
                              color: textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Role Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: lightOrange,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primaryOrange.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.stars_rounded, color: primaryOrange, size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      roleBadge,
                                      style: const TextStyle(
                                        color: primaryOrange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Status Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusDisplay,
                                      style: const TextStyle(
                                        color: Color(0xFF166534),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // User Details Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniInfo("User ID", clean(username)),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                      _buildMiniInfo("Lokasi", cleanLoc),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                      if (cleanUnit != "-")
                        _buildMiniInfo("Unit", cleanUnit)
                      else if (cleanDrvid != "-")
                        _buildMiniInfo("Driver ID", cleanDrvid.length > 8 ? cleanDrvid.substring(0, 8) : cleanDrvid)
                      else if (cleanKry != "-")
                        _buildMiniInfo("Kry ID", cleanKry)
                      else
                        _buildMiniInfo("Status", "Aktif"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            color: textMuted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Section Header
  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Profile Card List
  Widget _buildProfileCard() {
    final List<Widget> items = loginname == "DRIVER"
        ? _buildDriverProfileItems()
        : _buildUserProfileItems();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }

  List<Widget> _buildDriverProfileItems() {
    final List<Map<String, dynamic>> raw = [
      {"label": "Driver ID", "value": drvid, "icon": Icons.badge_outlined},
      {"label": "Nama Lengkap", "value": driverName, "icon": Icons.person_outline_rounded},
      {"label": "Nama Panggilan", "value": nickname, "icon": Icons.face_rounded},
      {"label": "Tempat Lahir", "value": placeOfBirth, "icon": Icons.location_city_rounded},
      {"label": "Alamat", "value": address, "icon": Icons.home_outlined},
      {"label": "Kota", "value": city, "icon": Icons.apartment_rounded},
      {"label": "Provinsi", "value": provinsi, "icon": Icons.map_outlined},
      {"label": "Jenis KTP", "value": ktp, "icon": Icons.credit_card_outlined},
      {"label": "Nomor KTP", "value": ktpNumber, "icon": Icons.pin_outlined},
      {"label": "Jenis SIM", "value": sim, "icon": Icons.drive_eta_outlined},
      {"label": "Nomor SIM", "value": simNumber, "icon": Icons.confirmation_number_outlined},
      {"label": "Masa Berlaku SIM", "value": simExpired, "icon": Icons.event_available_outlined},
      {"label": "Status Kendaraan", "value": statusVehicle, "icon": Icons.local_shipping_outlined},
      {"label": "Masa Berlaku STNK", "value": stnkBerlaku, "icon": Icons.description_outlined},
    ];

    return _generateListTiles(raw);
  }

  List<Widget> _buildUserProfileItems() {
    final List<Map<String, dynamic>> raw = [
      {"label": "Nama Lengkap", "value": name, "icon": Icons.person_outline_rounded},
      {"label": "User ID", "value": username, "icon": Icons.account_circle_outlined},
      if (loginname == "DRIVER" || drvid.isNotEmpty)
        {"label": "Driver ID", "value": drvid, "icon": Icons.badge_outlined},
      if (vhcid.isNotEmpty && vhcid != "-")
        {"label": "Unit Kendaraan", "value": vhcid, "icon": Icons.local_shipping_outlined},
      if (kryid.isNotEmpty && kryid != "-")
        {"label": "Karyawan ID", "value": kryid, "icon": Icons.badge_outlined},
      {"label": "Perusahaan", "value": cpyname.isNotEmpty ? cpyname : "ANDALAN NUSA PRATAMA PT", "icon": Icons.business_rounded},
    ];

    return _generateListTiles(raw);
  }

  List<Widget> _generateListTiles(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((entry) {
      final int index = entry.key;
      final item = entry.value;
      final bool isLast = index == data.length - 1;
      final String val = (item["value"] ?? "").toString().trim();
      final String displayVal = val.isEmpty ? "-" : val;

      return Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _copyToClipboard(item["label"], displayVal),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(index == 0 ? 16 : 0),
                bottom: Radius.circular(isLast ? 16 : 0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: lightOrange.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item["icon"] as IconData, color: primaryOrange, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (item["label"] as String).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: textMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayVal,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.copy_rounded, color: Color(0xFFCBD5E1), size: 16),
                  ],
                ),
              ),
            ),
          ),
          if (!isLast)
            const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
        ],
      );
    }).toList();
  }

  // Account Settings Card
  Widget _buildAccountSettingsCard() {
    final List<Map<String, dynamic>> raw = [
      {"label": "Login Name / Role", "value": loginname, "icon": Icons.assignment_ind_outlined},
      {"label": "Location ID", "value": locid, "icon": Icons.location_on_outlined},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _generateListTiles(raw),
      ),
    );
  }

  // Phone Update Card (DRIVER)
  Widget _buildPhoneUpdateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: txtOldPhone,
            readOnly: true,
            style: const TextStyle(fontSize: 13, color: textDark),
            decoration: InputDecoration(
              labelText: "Nomor Telepon Saat Ini",
              labelStyle: const TextStyle(fontSize: 12, color: textMuted),
              prefixIcon: const Icon(Icons.phone_locked_rounded, color: textMuted, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: borderLight),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: txtNewPhone,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 13, color: textDark),
            decoration: InputDecoration(
              labelText: "Nomor Telepon Baru",
              labelStyle: const TextStyle(fontSize: 12, color: textMuted),
              prefixIcon: const Icon(Icons.phone_rounded, color: primaryOrange, size: 20),
              hintText: "Contoh: 081234567890",
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryOrange, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _performActionWithLoading(_updatePhone),
              icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
              label: const Text(
                "Simpan Nomor Baru",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Password Change Card
  Widget _buildPasswordChangeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username Input
          TextField(
            controller: txtUsername,
            style: const TextStyle(fontSize: 13, color: textDark),
            decoration: InputDecoration(
              labelText: "Username",
              labelStyle: const TextStyle(fontSize: 12, color: textMuted),
              prefixIcon: const Icon(Icons.person_outline_rounded, color: primaryOrange, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryOrange, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Old Password Input
          TextField(
            controller: txtOldPassword,
            obscureText: _obscureOldPassword,
            style: const TextStyle(fontSize: 13, color: textDark),
            decoration: InputDecoration(
              labelText: "Kata Sandi Lama",
              labelStyle: const TextStyle(fontSize: 12, color: textMuted),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: textMuted, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOldPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscureOldPassword = !_obscureOldPassword);
                },
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryOrange, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // New Password Input
          TextField(
            controller: txtNewPassword,
            obscureText: _obscureNewPassword,
            style: const TextStyle(fontSize: 13, color: textDark),
            decoration: InputDecoration(
              labelText: "Kata Sandi Baru",
              labelStyle: const TextStyle(fontSize: 12, color: textMuted),
              prefixIcon: const Icon(Icons.lock_reset_rounded, color: primaryOrange, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryOrange, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              "* Minimal 6 karakter untuk username & password baru",
              style: TextStyle(fontSize: 11, color: textMuted),
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => _performActionWithLoading(_changePassword),
              icon: const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
              label: const Text(
                "Perbarui Kata Sandi",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 1,
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Device Settings Card (IMEI Update)
  Widget _buildDeviceSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                title: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Konfirmasi Update IMEI",
                      style: TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  "Apakah Anda yakin ingin memperbarui Device IMEI pada perangkat ini?",
                  style: TextStyle(fontSize: 13.5, color: textMuted),
                ),
                actions: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textMuted,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Batal"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _updateImeiId();
                    },
                    child: const Text("Ya, Perbarui"),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fingerprint_rounded, color: Color(0xFFD97706), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Update Device ID (IMEI)",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Sinkronkan IMEI perangkat untuk proteksi akun",
                        style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Logout Card
  Widget _buildLogoutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06DC2626),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _logout,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Keluar dari Akun",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Akhiri sesi login aplikasi saat ini",
                        style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFCA5A5), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
