import 'dart:async';

import 'package:dms_anp/src/pages/driver/ListDriverInspeksiV2.dart';
import 'package:dms_anp/src/pages/mekanik/ListMekanikInspeksiV2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApprovedMekanikDailyCheckScreenP2H extends StatefulWidget {
  @override
  _ApprovedMekanikDailyCheckScreenP2HState createState() => _ApprovedMekanikDailyCheckScreenP2HState();
}

class _ApprovedMekanikDailyCheckScreenP2HState extends State<ApprovedMekanikDailyCheckScreenP2H> {
  List<dynamic> inspections = [];
  Map<String, String> selectedValues =
      {}; // key: inspeksi_id, value: 'ya'/'tidak'
  // Orange Soft Theme Colors
  final Color primaryOrange = Color(0xFFFF8C69);      // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6);        // Very light orange
  final Color accentOrange = Color(0xFFFFB347);       // Peach orange
  final Color darkOrange = Color(0xFFE07B39);         // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5);     // Cream white
  final Color cardColor = Color(0xFFFFF8F0);          // Light cream
  final Color shadowColor = Color(0x20FF8C69);        // Soft orange shadow
  final TextEditingController notesController = TextEditingController();
  final TextEditingController notesVerifikasiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInspectionData();
  }


  void fetchInspectionData() async {
    var urlBase =
        'https://apps.tuluatas.com/trucking/mobile/api/mekanik/master_data_inspeksi.jsp?method=list-inspeksi-verifikasi-v2&p2hnumber=${globals.Mcp2hNumber.toString()}&kryid=${globals.Mckryid}';
    final response = await http.get(Uri.parse(urlBase));
    print(urlBase);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        inspections = data;

        if (data.isNotEmpty) {
          // Ambil nilai km dan notes dari elemen pertama
          notesController.text = data[0]['notes'] ?? '';
        } else {
          notesController.clear();
          notesVerifikasiController.clear();
        }
      });
    } else {
      print('Failed to load data');
    }
  }


  void handleSubmit() async {
    if (inspections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak ada yang akan di approved"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    if (notesVerifikasiController.text.isEmpty) {
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

    if ((globals.Mcp2hNumber==null || globals.Mcp2hNumber=='') && (globals.Mckryid==null || globals.Mckryid=='')) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Mekanik ID tidak ditemukan.'),
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

    if ((notesVerifikasiController.text == null || notesVerifikasiController.text.isEmpty) &&
        (globals.Mckryid == null || globals.Mckryid!.isEmpty)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Note wajib diisi.'),
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

    // Siapkan list inspeksi
    List<Map<String, dynamic>> inspeksiData = inspections.map((item) {
      return {
        "id": item['id'],
        "groupid": item['groupid'],
        "nama_tools": item['nama_tools'],
        "qty": item['qty'],
        "inspeksi": int.tryParse(item['inspeksi'].toString()) ?? 0,
      };
    }).toList();

    // Payload JSON
    final data = {
      "method": "approved",
      "p2hnumber": globals.Mcp2hNumber.toString(),
      "kryid": globals.Mckryid.toString(),
      "userid": username,
      "notes_verifikasi": notesVerifikasiController.text,
      "inspeksi_data": inspeksiData,
    };

    final jsonString = jsonEncode(data);
    print("Data to submit: $jsonString");

    var urlBase = 'https://apps.tuluatas.com/trucking/mobile/api/mekanik/approved_form_inspeksiv2_mekanik.jsp';
    final response = await http.post(
      Uri.parse(urlBase),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
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
              MaterialPageRoute(builder: (context) => ListMekanikInspeksiV2()),
            );
          });
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Gagal'),
              content: Text('Pesan dari server: ${responseData['message'] ?? 'Tidak diketahui'}'),
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
            content: const Text('Respon dari server tidak bisa diproses (bukan JSON).'),
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
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Gagal'),
          content: const Text('Gagal mengirim data ke server.'),
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

  void handleCancel() async {
    // Cek apakah data inspeksi kosong
    if (inspections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak ada data inspeksi untuk dibatalkan."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Ambil data dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("name")!;

    // Validasi wajib: kendaraan & mekanik
    if ((globals.Mcp2hNumber == null || globals.Mcp2hNumber!.isEmpty) &&
        (globals.Mckryid == null || globals.Mckryid!.isEmpty)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Mekanik ID tidak ditemukan.'),
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

    if ((notesVerifikasiController.text == null || notesVerifikasiController.text.isEmpty) &&
        (globals.Mckryid == null || globals.Mckryid!.isEmpty)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Note wajib diisi.'),
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

    // Persiapan data JSON
    final data = {
      "method": "cancel",
      "p2hnumber": globals.Mcp2hNumber?.toString() ?? '',
      "kryid": globals.Mckryid?.toString() ?? '',
      "userid": username ?? '',
      "notes_verifikasi": notesVerifikasiController.text,
    };

    final jsonString = jsonEncode(data);
    print("Data to submit: $jsonString");

    // Kirim POST ke server
    final response = await http.post(
      Uri.parse('https://apps.tuluatas.com/trucking/mobile/api/mekanik/approved_form_inspeksiv2_mekanik.jsp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    // Proses respon server
    if (response.statusCode == 200) {
      print("RESPONSE BODY: ${response.body}");

      if (response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData['status'] == 'success') {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sukses'),
                content: const Text('Inspeksi berhasil dibatalkan.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => ListMekanikInspeksiV2()));
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Gagal'),
                content: Text('Pesan dari server: ${responseData['message'] ?? 'Tidak diketahui'}'),
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
              content: const Text('Data dari server tidak valid (bukan JSON).'),
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
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal'),
            content: const Text('Server tidak mengembalikan data.'),
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
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Gagal'),
          content: Text('HTTP Error ${response.statusCode}'),
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


  @override
  Widget build(BuildContext context) {
    final Map<String, List<dynamic>> grouped = {};

    for (var item in inspections) {
      final groupId = item['groupid'];
      if (!grouped.containsKey(groupId)) {
        grouped[groupId] = [];
      }
      grouped[groupId]?.add(item);
    }

    return WillPopScope(
        onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ListMekanikInspeksiV2()),
      );
      return false; // cegah pop default, biar pake pushReplacement
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
                      builder: (context) => ListMekanikInspeksiV2()));
            },
          ),
          //backgroundColor: Colors.transparent,
          title: Text('Approved Inspeksi ${globals.McName.toString()}',
              style: TextStyle(color: Colors.black))),
      body: inspections.isEmpty
          ? const Center(child: Text("Tidak ada data inspeksi"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: const Text(
                "Daily Check Before Riding",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            ...grouped.entries.map((entry) {
              final groupId = entry.key;
              final items = entry.value;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header: Group ID
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Text(
                        'Group ID: $groupId',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Card Body: List tools
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: items.map((item) {
                          final nama = item['nama_tools'] ?? '';
                          final qty = item['qty'] ?? '0';
                          final inspeksi = int.tryParse(item['inspeksi'].toString()) ?? -1;

                          String label = '';
                          Color labelColor = Colors.black;

                          if (inspeksi == 1) {
                            label = 'Ada';
                          } else if (inspeksi == 2) {
                            label = 'Rusak';
                            labelColor = Colors.red;
                          } else if (inspeksi == 0) {
                            label = 'Tidak Ada';
                            labelColor = Colors.red;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Nama dan Qty
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nama,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Qty: $qty',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Status inspeksi
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: labelColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // TextField(
            //   controller: notesController,
            //   readOnly: true,
            //   maxLines: 3,
            //   decoration: InputDecoration(
            //     labelText: 'Catatan',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),
            //
            // const SizedBox(height: 80),
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
                    backgroundColor: primaryOrange,
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
                              handleCancel();

                            },
                          ),
                        ],
                      );
                    },
                  );
                },
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
                icon: const Icon(Icons.refresh),
                label: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
