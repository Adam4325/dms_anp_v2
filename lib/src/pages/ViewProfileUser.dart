import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/loginPage.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ViewProfileUser extends StatefulWidget {
  @override
  _ViewProfileUserState createState() => _ViewProfileUserState();
}

class _ViewProfileUserState extends State<ViewProfileUser> {
  // Controllers
  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtOldPassword = TextEditingController();
  TextEditingController txtNewPassword = TextEditingController();
  TextEditingController txtOldPhone = TextEditingController();
  TextEditingController txtNewPhone = TextEditingController();

  final Color primaryOrange = Color(0xFFFF8C69);      // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6);        // Very light orange
  final Color accentOrange = Color(0xFFFFB347);       // Peach orange
  final Color darkOrange = Color(0xFFE07B39);         // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5);     // Cream white
  final Color cardColor = Color(0xFFFFF8F0);          // Light cream
  final Color shadowColor = Color(0x20FF8C69);        // Soft orange shadow

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
    });

    if (loginname == "DRIVER") {
      await _loadDriverProfile();
    }
  }

  Future<void> _loadDriverProfile() async {
    try {
      final url = "${GlobalData.baseUrl}api/profile_user.jsp?method=driver&driverid=" + drvid;
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
          stnkBerlaku = stnkLast + "-" + stnkNext;
        });
      } else {
        alert(context, 0, "Data tidak ditemukan", "error");
      }
    } catch (e) {
      alert(context, 0, "Error loading profile: " + e.toString(), "error");
    }
  }

  Future<void> _changePassword() async {
    if (!_validatePassword()) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String driverid = prefs.getString("drvid") ?? "";
      String userid = prefs.getString("name") ?? "";

      final url = "${GlobalData.baseUrl}api/change_password_user.jsp?method=driver&driverid=" +
          driverid + "&userid=" + userid + "&username=" + txtUsername.text +
          "&oldpassword=" + txtOldPassword.text + "&password=" + txtNewPassword.text;

      final response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      final result = json.decode(response.body);

      if (result["status_code"] == "200") {
        _showSuccessDialog(result["message"] + ", silahkan login kembali", () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
          );
        });
      } else {
        alert(context, 0, result["message"], "error");
      }
    } catch (e) {
      alert(context, 0, "Error changing password: " + e.toString(), "error");
    }
  }

  Future<void> _updatePhone() async {
    if (txtNewPhone.text.isEmpty) {
      alert(context, 0, "New Phone tidak boleh kosong", "error");
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String driverid = prefs.getString("drvid") ?? "";
      String userid = prefs.getString("name") ?? "";

      final url = "${GlobalData.baseUrl}api/change_phone_user.jsp?method=update-phone-driver&driverid=" +
          driverid + "&new_phone=" + txtNewPhone.text + "&userid=" + userid;

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
        alert(context, 0, result["message"], "error");
      }
    } catch (e) {
      alert(context, 0, "Error updating phone: " + e.toString(), "error");
    }
  }

  Future<void> _updateImeiId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String imeiId = prefs.getString("androidID") ?? "";

    if (imeiId.isEmpty) {
      alert(context, 0, "IMEIID tidak boleh kosong", "error");
      return;
    }

    try {
      String userid = prefs.getString("name") ?? "";

      final url = "${GlobalData.baseUrl}api/change_imeiid_user.jsp?method=change-imeiid-v1&imeiid=" +
          imeiId + "&id=" + drvid + "&loginname=" + loginname + "&username=" + drvid + "&userid=" + userid;

      final response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      final result = json.decode(response.body);

      if (result["status_code"] == "200") {
        _showSuccessDialog(result["message"] + ", silahkan login kembali", () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
          );
        });
      } else {
        alert(context, 0, result["message"], "error");
      }
    } catch (e) {
      alert(context, 0, "Error updating IMEI: " + e.toString(), "error");
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
      alert(context, 0, "Old Password tidak boleh kosong", "error");
      return false;
    }
    if (txtNewPassword.text.isEmpty) {
      alert(context, 0, "New Password tidak boleh kosong", "error");
      return false;
    }
    if (txtNewPassword.text.length <= 5) {
      alert(context, 0, "New Password minimal 6 karakter", "error");
      return false;
    }
    return true;
  }

  void _showSuccessDialog(String message, VoidCallback onOk) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Information'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onOk();
            },
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }

  Future<void> _performActionWithLoading(Future<void> Function() action) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(Duration(seconds: 1));
    Navigator.pop(context);
    await action();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Ya'),
          ),
        ],
      ),
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: HexColor("#f0eff4"),
        appBar: AppBar(
          backgroundColor: darkOrange,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ViewDashboard()),
            ),
          ),
          centerTitle: true,
          title: Text('User Profile'),
        ),
        body: ListView(
          children: [
            // Profile Information Section
            _buildSectionHeader("Profile Information"),
            _buildProfileSection(),

            // Account Settings Section
            _buildSectionHeader("Account Settings"),
            _buildAccountSettingsSection(),

            // Phone Update Section (only for drivers)
            if (loginname == "DRIVER") ...[
              _buildSectionHeader("Phone Update"),
              _buildPhoneUpdateSection(),
            ],

            // Password Change Section
            _buildSectionHeader("Password Change"),
            _buildPasswordChangeSection(),

            // Device Settings Section (fingerprint)
            if (loginname != "MECHANIC") ...[
              _buildSectionHeader("Device Settings"),
              _buildDeviceSettingsSection(),
            ],

            // Logout Section
            _buildSectionHeader("Account Actions"),
            _buildLogoutSection(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (loginname == "DRIVER") ..._buildDriverProfileItems(),
          if (loginname != "DRIVER") ..._buildUserProfileItems(),
        ],
      ),
    );
  }

  List<Widget> _buildDriverProfileItems() {
    List<Map<String, String>> items = [
      {"title": "KryID", "subtitle": kryid},
      {"title": "Name", "subtitle": driverName},
      {"title": "Nickname", "subtitle": nickname},
      {"title": "Place of Birth", "subtitle": placeOfBirth},
      {"title": "Address", "subtitle": address},
      {"title": "City", "subtitle": city},
      {"title": "Province", "subtitle": provinsi},
      {"title": "KTP Type", "subtitle": ktp},
      {"title": "KTP Number", "subtitle": ktpNumber},
      {"title": "SIM Type", "subtitle": sim},
      {"title": "SIM Number", "subtitle": simNumber},
      {"title": "Vehicle Status", "subtitle": statusVehicle},
      {"title": "STNK Valid", "subtitle": stnkBerlaku},
    ];

    return items.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> item = entry.value;
      return Column(
        children: [
          _buildListItem(item["title"]!, item["subtitle"]!),
          if (index < items.length - 1) Divider(height: 1, color: Colors.grey.shade300),
        ],
      );
    }).toList();
  }

  List<Widget> _buildUserProfileItems() {
    if(!kryid.isEmpty && status_karyawan=="KARYAWAN"){
      List<Map<String, String>> items = [
        {"title": "Name", "subtitle": name},
        {"title": "User ID", "subtitle": username},
        //{"title": "Units", "subtitle": vhcid},
        {"title": "Driver ID", "subtitle": drvid},
        {"title": "Company", "subtitle": cpyname},
      ];

      return items.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, String> item = entry.value;
        return Column(
          children: [
            _buildListItem(item["title"]!, item["subtitle"]!),
            if (index < items.length - 1) Divider(height: 1, color: Colors.grey.shade300),
          ],
        );
      }).toList();
    }else{
      List<Map<String, String>> items = [
        {"title": "Name", "subtitle": name},
        {"title": "User ID", "subtitle": username},
        {"title": "Units", "subtitle": vhcid},
        {"title": "KryID ID", "subtitle": kryid},
        {"title": "Company", "subtitle": cpyname},
      ];

      return items.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, String> item = entry.value;
        return Column(
          children: [
            _buildListItem(item["title"]!, item["subtitle"]!),
            if (index < items.length - 1) Divider(height: 1, color: Colors.grey.shade300),
          ],
        );
      }).toList();
    }

  }

  Widget _buildAccountSettingsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildListItem("Login Name", loginname),
          Divider(height: 1, color: Colors.grey.shade300),
          _buildListItem("Location ID", locid),
        ],
      ),
    );
  }

  Widget _buildPhoneUpdateSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: txtOldPhone,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Current Phone",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: txtNewPhone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "New Phone Number",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _performActionWithLoading(_updatePhone),
                icon: Icon(Icons.phone),
                label: Text("Update Phone"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordChangeSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: txtUsername,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: txtOldPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Old Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: txtNewPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _performActionWithLoading(_changePassword),
                icon: Icon(Icons.lock),
                label: Text("Change Password"),
                style: ElevatedButton.styleFrom(
                    elevation: 2.0,
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSettingsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.fingerprint, color: Colors.blue),
            title: const Text("Update Device ID"),
            subtitle: const Text("Update IMEI for device security"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.orange.shade50, // soft orange background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        "Confirm Update",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Are you sure you want to update your Device IMEI?",
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("No"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _updateImeiId(); // panggil function update
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            subtitle: Text("Sign out from your account"),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, String subtitle) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle.isEmpty ? "-" : subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}