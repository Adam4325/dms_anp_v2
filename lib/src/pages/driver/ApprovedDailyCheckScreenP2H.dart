import 'dart:async';

import 'package:dms_anp/src/pages/driver/ListDriverInspeksiV2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApprovedDailyCheckScreenP2H extends StatefulWidget {
  @override
  _ApprovedDailyCheckScreenP2HState createState() => _ApprovedDailyCheckScreenP2HState();
}

class _ApprovedDailyCheckScreenP2HState extends State<ApprovedDailyCheckScreenP2H> {
  List<dynamic> inspections = [];
  Map<String, String> selectedValues =
      {}; // key: inspeksi_id, value: 'ya'/'tidak'
  final Color primaryOrange = Color(0xFFFF8C69);      // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6);        // Very light orange
  final Color accentOrange = Color(0xFFFFB347);       // Peach orange
  final Color darkOrange = Color(0xFFE07B39);         // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5);     // Cream white
  final Color cardColor = Color(0xFFFFF8F0);          // Light cream
  final Color shadowColor = Color(0x20FF8C69);

  final TextEditingController kilometerController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController notesVerifikasiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInspectionData();
  }

  void fetchInspectionDataOld() async {
    var urlBase =
        'https://apps.tuluatas.com/trucking/mobile/api/master_data_inspeksi.jsp?method=list-inspeksi-verifikasi-v2&vhcid=${globals.p2hVhcid.toString()}';
    final response = await http.get(Uri.parse(urlBase));
    print(urlBase);
    if (response.statusCode == 200) {
      setState(() {
        inspections = json.decode(response.body);
      });
    } else {
      print('Failed to load data');
    }
  }

  void fetchInspectionData() async {
    var urlBase =
        'https://apps.tuluatas.com/trucking/mobile/api/master_data_inspeksi.jsp?method=list-inspeksi-verifikasi-v2&vhcid=${globals.p2hVhcid.toString()}';
    final response = await http.get(Uri.parse(urlBase));
    print(urlBase);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        inspections = data;

        if (data.isNotEmpty) {
          // Ambil nilai km dan notes dari elemen pertama
          kilometerController.text = data[0]['km'] ?? '';
          notesController.text = data[0]['notes'] ?? '';
        } else {
          kilometerController.clear();
          notesController.clear();
          notesVerifikasiController.clear();
        }
      });
    } else {
      print('Failed to load data');
    }
  }


  void handleSubmit() async {
    // Cek apakah semua inspeksi sudah dipilih
    if(inspections.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak ada yang akan di approved"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }
    if(notesVerifikasiController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Notes Verifikasi tidak boleh kosong!"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("name");
    final uniqueIds = inspections.map((e) => e['id']).toSet();

    //final incomplete = uniqueIds.any((id) => selectedValues[id] == null);

    print('VHCID ${globals.p2hVhcid}');
    print('LOCID ${globals.p2hVhclocid}');
    if (globals.p2hVhcid==null || globals.p2hVhcid=='') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Vehicle ID tidak di temukan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Jika valid, lanjutkan proses
    List<Map<String, dynamic>> result = [];

    final grouped = <String, String>{};
    for (var item in inspections) {
      grouped[item['id']] = item['inspeksi_name'];
    }

    grouped.forEach((id, name) {
      final value = selectedValues[id];
      result.add({
        "id": id,
        "inspeksi_name": name,
        "inspeksi": value == "ya" ? 1 : 0,
      });
    });

    final data = {
      "method": "approved",
      "p2hnumber": globals.p2hNumber.toString(),
      "vhcid": globals.p2hVhcid.toString(),
      "locid": globals.p2hVhclocid.toString(),
      "userid": username,
      "notes_verifikasi":notesVerifikasiController.text
    };

    final jsonString = jsonEncode(data);
    print("Data to submit: $jsonString");

    // Kirim data ke server via POST
    var urlBase = 'https://apps.tuluatas.com/trucking/mobile/api/approved_form_inspeksiv2_new.jsp';
    //var urlBase = 'https://apps.tuluatas.com/trucking/mobile/api/approved_form_inspeksiv2new.jsp';
    print("URLBASE ${urlBase}");
    final response = await http.post(
      Uri.parse(urlBase),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      print("RESPONSE BODY: ${response.body}");

      if (response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData['status'] == 'success') {
            // sukses
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sukses'),
                content: const Text('Approved inspeksi berhasil disubmit.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            Timer(Duration(seconds: 1), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ListDriverInspeksiV2()));
            });

          } else {
            // gagal dari sisi server
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Gagal'),
                content: Text(
                    'Pesan dari server: ${responseData['message'] ?? 'Tidak diketahui'}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } catch (e) {
          print("JSON decode error: $e");
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Gagal'),
              content: const Text(
                  'Respon dari server tidak bisa diproses (bukan JSON).'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        print("Server returned empty response");
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal'),
            content: const Text('Server tidak mengembalikan data apapun.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }


  void handleCancel() async {
    // Cek apakah semua inspeksi sudah dipilih
    if(inspections.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak ada yang akan di approved"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("name");
    if (globals.p2hVhcid==null || globals.p2hVhcid=='') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Vehicle ID tidak di temukan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Jika valid, lanjutkan proses
    List<Map<String, dynamic>> result = [];

    final grouped = <String, String>{};
    for (var item in inspections) {
      grouped[item['id']] = item['inspeksi_name'];
    }

    grouped.forEach((id, name) {
      final value = selectedValues[id];
      result.add({
        "id": id,
        "inspeksi_name": name,
        "inspeksi": value == "ya" ? 1 : 0,
      });
    });

    final data = {
      "method": "cancel",
      "vhcid": globals.p2hVhcid.toString(),
      "p2hnumber": globals.p2hNumber.toString(),
      "locid": globals.p2hVhclocid.toString(),
      "userid": username,
      "notes_verifikasi":notesVerifikasiController.text
    };

    final jsonString = jsonEncode(data);
    print("Data to submit: $jsonString");

    // Kirim data ke server via POST
    final response = await http.post(
      Uri.parse(
          'https://apps.tuluatas.com/trucking/mobile/api/approved_form_inspeksiv2_new.jsp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      print("RESPONSE BODY: ${response.body}");

      if (response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData['status'] == 'success') {
            // sukses
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sukses'),
                content: const Text('Cancel/Rejected inspeksi berhasil!.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            Timer(Duration(seconds: 1), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ListDriverInspeksiV2()));
            });
          } else {
            // gagal dari sisi server
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Gagal'),
                content: Text(
                    'Pesan dari server: ${responseData['message'] ?? 'Tidak diketahui'}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } catch (e) {
          print("JSON decode error: $e");
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Gagal'),
              content: const Text(
                  'Respon dari server tidak bisa diproses (bukan JSON).'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        print("Server returned empty response");
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal'),
            content: const Text('Server tidak mengembalikan data apapun.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void handleCancelOld() {
    setState(() {
      selectedValues.clear();
      kilometerController.clear();
      notesController.clear();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ListDriverInspeksiV2()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<dynamic>> grouped = {};

    for (var item in inspections) {
      final groupId = item['id'];
      (grouped[groupId] ??= []).add(item);
    }

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ListDriverInspeksiV2()),
          );
        },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: darkOrange,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            iconSize: 20.0,
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListDriverInspeksiV2()));
            },
          ),
          //backgroundColor: Colors.transparent,
          title: Text('Approved Inspeksi ${globals.p2hVhcid.toString()}',
              style: TextStyle(color: Colors.black))),
      body: inspections.isEmpty
          ? const Center(child: Text("Tidak ada data inspeksi"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text("Daily Check Before Riding",
                        style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(height: 16),
                  ...grouped.entries.map((entry) {
                    final groupId = entry.key;
                    final items = entry.value;
                    final groupTitle = items.first['inspeksi_name'];
                    final isYes = items.first['point'];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                isYes == "1" ? Icons.check_box : Icons.close,
                                size: 20,
                                color: isYes == "1" ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                groupTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const Divider(),
                          ...items
                              .where((item) =>
                                  item['subs_inspeksi_name'] != null &&
                                  item['subs_inspeksi_name'].toString() != "-")
                              .map((item) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.circle, size: 6),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child:
                                              Text(item['subs_inspeksi_name']),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    );
                  }).toList(),

                  // --- Kilometer input
                  const SizedBox(height: 16),
                  TextField(
                    controller: kilometerController,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Kilometer',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Notes input
                  TextField(
                    controller: notesController,
                    readOnly: true,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 80), // spacing for bottom button
                ],
              ),
            ),
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (){
                  //handleSubmit
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      TextEditingController _notesController = TextEditingController();

                      return AlertDialog(
                        title: Text("Notes Verifikasi"),
                        content: TextField(
                          controller: notesVerifikasiController,
                          decoration: InputDecoration(
                            hintText: "Masukkan catatan...",
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text("Batal"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              handleSubmit();

                            },
                          ),
                        ],
                      );
                    },
                  );

                },
                style: ElevatedButton.styleFrom(
                    elevation: 2.0,
                    backgroundColor: darkOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                icon: const Icon(Icons.check),
                label: const Text("Approved"),//BUTTON APPROVE
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      TextEditingController _notesController = TextEditingController();

                      return AlertDialog(
                        title: Text("Notes Cancel Verifikasi"),
                        content: TextField(
                          controller: notesVerifikasiController,
                          decoration: InputDecoration(
                            hintText: "Masukkan catatan...",
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text("Batal"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              handleCancel();

                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.refresh),
                style: ElevatedButton.styleFrom(
                    elevation: 2.0,
                    backgroundColor: shadowColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                label: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
