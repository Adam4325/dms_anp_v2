import 'dart:convert';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/hrd/ApvRewards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FormApvRewards extends StatefulWidget {
  final Map<String, dynamic> item;

  const FormApvRewards({Key? key, required this.item}) : super(key: key);

  @override
  State<FormApvRewards> createState() => _FormApvRewardsState();
}

class _FormApvRewardsState extends State<FormApvRewards> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _noteController = TextEditingController();

  goBack(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ApvRewards()));
  }



  Future<void> _RejectReward() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("name") ?? "unknown";
    String rwdnbr = widget.item['RWDNBR'];

    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Konfirmasi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Text(
          "Yakin ingin cancel/reject reward ${rwdnbr} ?",
          style: const TextStyle(color: Colors.black54, fontSize: 15),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // actionsAlignment tidak dipakai — kita pakai Row di dalam actions
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min, // biar Row tidak melebar penuh
              mainAxisAlignment: MainAxisAlignment.end, // kanan
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade700, // text color
                  ),
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Tidak"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Ya"),
                ),
              ],
            ),
          ),
        ],
      ),
    );



    // if (confirm == true) {
    //   EasyLoading.show(status: 'Proses...');
    //   final String url = GlobalData.baseUrl +
    //       "api/hrd/apv-rewards.jsp?method=approve&rwdnbr=${rwdnbr}&userid=${user}";
    //   final uri = Uri.parse(url);
    //   final response = await http.get(uri);
    //   EasyLoading.dismiss();
    //   print(response.statusCode);
    //   if (response.statusCode == 200) {
    //     alert(globalScaffoldKey.currentContext, 1, "Reward ${rwdnbr} berhasil di-approve", "success");
    //     //Navigator.pop(context, true);
    //     Future.delayed(const Duration(seconds: 2), () {
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(builder: (context) => ApvRewards()),
    //       );
    //     });
    //
    //   } else {
    //     () { final ctx = globalScaffoldKey.currentContext; if (ctx != null) alert(ctx, 2, "Gagal approve: ${response.statusCode}", "warning");
    //   }
    // }
    if (confirm == true) {
      EasyLoading.show(status: 'Proses...');
      final String url = GlobalData.baseUrl +
          "api/hrd/apv-rewards.jsp?method=rejected-v1&rwdnbr=${rwdnbr}&userid=${user}";
      print(url);
      final uri = Uri.parse(url);

      try {
        final response = await http.get(uri);
        EasyLoading.dismiss();

        if (response.statusCode == 200) {
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) {
            alert(ctx, 1, "Reward ${rwdnbr} berhasil di-cancel/reject", "success");
          }

          // Delay 2 detik sebelum navigasi
          await Future.delayed(const Duration(seconds: 2));

          // ✅ Gunakan mounted dari State (bukan context)
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ApvRewards()),
          );
        } else {
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) alert(ctx, 2,
              "Gagal approve: ${response.statusCode}", "warning");
        }
      } catch (e) {
        EasyLoading.dismiss();
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) alert(ctx, 2,
            "Terjadi kesalahan: $e", "warning");
      }
    }

  }

  Future<void> _approveReward() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("name") ?? "unknown";
    String rwdnbr = widget.item['RWDNBR'];

    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Konfirmasi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Text(
          "Yakin ingin approve reward ${rwdnbr} ?",
          style: const TextStyle(color: Colors.black54, fontSize: 15),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // actionsAlignment tidak dipakai — kita pakai Row di dalam actions
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min, // biar Row tidak melebar penuh
              mainAxisAlignment: MainAxisAlignment.end, // kanan
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade700, // text color
                  ),
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Tidak"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Ya"),
                ),
              ],
            ),
          ),
        ],
      ),
    );



    // if (confirm == true) {
    //   EasyLoading.show(status: 'Proses...');
    //   final String url = GlobalData.baseUrl +
    //       "api/hrd/apv-rewards.jsp?method=approve&rwdnbr=${rwdnbr}&userid=${user}";
    //   final uri = Uri.parse(url);
    //   final response = await http.get(uri);
    //   EasyLoading.dismiss();
    //   print(response.statusCode);
    //   if (response.statusCode == 200) {
    //     alert(globalScaffoldKey.currentContext, 1, "Reward ${rwdnbr} berhasil di-approve", "success");
    //     //Navigator.pop(context, true);
    //     Future.delayed(const Duration(seconds: 2), () {
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(builder: (context) => ApvRewards()),
    //       );
    //     });
    //
    //   } else {
    //     () { final ctx = globalScaffoldKey.currentContext; if (ctx != null) alert(ctx, 2, "Gagal approve: ${response.statusCode}", "warning");
    //   }
    // }
    if (confirm == true) {
      EasyLoading.show(status: 'Proses...');
      final String url = GlobalData.baseUrl +
          "api/hrd/apv-rewards.jsp?method=approve&rwdnbr=${rwdnbr}&userid=${user}";
      print(url);
      final uri = Uri.parse(url);

      try {
        final response = await http.get(uri);
        EasyLoading.dismiss();

        if (response.statusCode == 200) {
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) {
            alert(ctx, 1, "Reward ${rwdnbr} berhasil di-approve", "success");
          }

          // Delay 2 detik sebelum navigasi
          await Future.delayed(const Duration(seconds: 2));

          // ✅ Gunakan mounted dari State (bukan context)
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ApvRewards()),
          );
        } else {
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) alert(ctx, 2,
              "Gagal approve: ${response.statusCode}", "warning");
        }
      } catch (e) {
        EasyLoading.dismiss();
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) alert(ctx, 2,
            "Terjadi kesalahan: $e", "warning");
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          goBack(context);
        },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Form Approval Reward'),
        backgroundColor: const Color(0xFFFF8C69),
      ),
      body: Padding(
        key: globalScaffoldKey,
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            _field("Reward Number", item['RWDNBR']),
            _field("Reward Name", item['REWARDTYP']),
            _field("Reward Date", item['RWDDATE']),
            _field("Type Reward", item['RWDTYPEID']),
            _field("Nilai Point", item['RWDPOINTS']),
            _field("Qty Reward", item['RWDQTY']),
            _field("Status", item['RWDSTATUS']),
            _field("Driver", item['DRVID']),
            _field("Reward To", item['RWDTO']),
            const SizedBox(height: 4),
            const Text("Reward Notes"),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Masukkan catatan approval..."),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Approve"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _approveReward,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Reject"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _RejectReward,
            )
          ],
        ),
      ),
    ));
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          SizedBox(
            width: 130, // lebar tetap biar rata kiri
            child: Text(
              "$label :",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          // Value
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _fieldOld(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: value ?? ''),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
