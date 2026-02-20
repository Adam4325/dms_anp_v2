import 'dart:async';
import 'dart:convert';

import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewListObp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;

class FrmVerifikasiObp extends StatefulWidget {
  const FrmVerifikasiObp({Key? key}) : super(key: key);

  @override
  _FrmVerifikasiObpState createState() => _FrmVerifikasiObpState();
}

_goBack(BuildContext context) {
  EasyLoading.show();
  Timer(const Duration(seconds: 1), () {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewListObp()));
  });
}

class _FrmVerifikasiObpState extends State<FrmVerifikasiObp> {
  GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  String selSangsi = '';
  List<Map<String, dynamic>> listSangsi = [
    {'value': 'PERINGANTAN 1', 'title': 'PERINGANTAN 1'},
    {'value': 'STOP OPERASI', 'title': 'STOP OPERASI'},
    {'value': 'GANTI TUNAI', 'title': 'GANTI TUNAI'},
    {'value': 'MENGANGSUR', 'title': 'MENGANGSUR'},
    {'value': 'PHK', 'title': 'PHK'},
  ];
  final TextEditingController txtNopol = new TextEditingController();
  final TextEditingController txtBpNBR = new TextEditingController();
  final TextEditingController txtDriverName = new TextEditingController();
  final TextEditingController txtAkomodasi = new TextEditingController();
  final TextEditingController txtEvakuasi = new TextEditingController();
  final TextEditingController txtKoordinasi = new TextEditingController();
  final TextEditingController txtPenggantianBarang =
      new TextEditingController();
  final TextEditingController txtPemakaianSparePart =
      new TextEditingController();
  final TextEditingController txtClaim = new TextEditingController();
  final TextEditingController txtAngsuran = new TextEditingController();
  final TextEditingController txtJasaPerbaikan = new TextEditingController();
  final TextEditingController txtPenggantianSemen = new TextEditingController();
  final TextEditingController txtKerugianIdle = new TextEditingController();
  final TextEditingController txtTotalSummaryLaka = new TextEditingController();
  final TextEditingController txtBuktiPalenggaran = new TextEditingController();
  final TextEditingController txtBpNotes = new TextEditingController();

  void resetTeksForm(){
    selSangsi = '';
    txtNopol.text = '';
    txtDriverName.text = '';
    txtBpNBR.text = '';
    txtClaim.text = '';
    txtAngsuran.text = '';
    txtAkomodasi.text = '';
    txtEvakuasi.text = '';
    txtKoordinasi.text = '';
    txtPenggantianBarang.text = '';
    txtPemakaianSparePart.text = '';
    txtJasaPerbaikan.text = '';
    txtPenggantianSemen.text = '';
    txtKerugianIdle.text = '';
    txtTotalSummaryLaka.text = '';
    txtBuktiPalenggaran.text = '';
  }

  void SaveObp(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("name") ?? "";
      String nopol = txtNopol.text;
      String bpnbr = txtBpNBR.text;
      String sangsi = selSangsi;
      String bpamount = txtClaim.text;
      String bpangsuran = txtAngsuran.text;
      String b_akomodasi = txtAkomodasi.text;
      String b_evakuasi = txtEvakuasi.text;
      String b_koordinasi = txtKoordinasi.text;
      String b_penggantian_barang = txtPenggantianBarang.text;
      String b_pemakaian_spare_part = txtPemakaianSparePart.text;
      String b_jasa_perbaikan = txtJasaPerbaikan.text;
      String b_penggantian_semen = txtPenggantianSemen.text;
      String b_kerugian_idle = txtKerugianIdle.text;
      String b_total_summary_laka = txtTotalSummaryLaka.text;
      String b_bukti_pelanggaran = txtBuktiPalenggaran.text;
      String bpnotes = txtBpNotes.text;
      if (bpnbr.isEmpty) {
        EasyLoading.showError("BP Number tidak boleh kosong");
      } else if (sangsi.isEmpty) {
        EasyLoading.showError("Sangsi tidak boleh kosong");
      } else {
        EasyLoading.show();
        var endpointUrl = "${GlobalData.baseUrl}api/laka/save_data_laka.jsp";
        var encoded = Uri.encodeFull(endpointUrl);
        var status_code = 100;
        var message = "";
        print(endpointUrl);
        var map = new Map<String, dynamic>();
        map['method'] = "update-obp-v1";
        map['bpnbr'] = bpnbr;
        map['nopol'] = nopol;
        map['sangsi'] = sangsi;
        map['bpamount'] = bpamount.isEmpty ? "0" : bpamount;
        map['bpangsuran'] = bpangsuran.isEmpty ? "0" : bpangsuran;
        map['b_akomodasi'] = b_akomodasi.isEmpty ? "0" : b_akomodasi;
        map['b_evakuasi'] = b_evakuasi.isEmpty ? "0" : b_evakuasi;
        map['b_koordinasi'] = b_koordinasi.isEmpty ? "0" : b_koordinasi;
        map['b_penggantian_barang'] =
            b_penggantian_barang.isEmpty ? "0" : b_penggantian_barang;
        map['b_pemakaian_spare_part'] =
            b_pemakaian_spare_part.isEmpty ? "0" : b_pemakaian_spare_part;
        map['b_jasa_perbaikan'] =
            b_jasa_perbaikan.isEmpty ? "0" : b_jasa_perbaikan;
        map['b_penggantian_semen'] =
            b_penggantian_semen.isEmpty ? "0" : b_penggantian_semen;
        map['b_kerugian_idle'] =
            b_kerugian_idle.isEmpty ? "0" : b_kerugian_idle;
        map['b_total_summary_laka'] =
            b_total_summary_laka.isEmpty ? "0" : b_total_summary_laka;
        map['b_bukti_pelanggaran'] =
            b_bukti_pelanggaran.isEmpty ? "0" : b_bukti_pelanggaran;
        map['userid'] = userid;
        map['notes'] = bpnotes;
        Uri urlEncode = Uri.parse(encoded);
        final response = await http.post(
          urlEncode,
          body: map,
          // headers: {
          //   "Content-Type": "application/x-www-form-urlencoded",
          // },
          // encoding: Encoding.getByName('utf-8'),
        );

        setState(() {
          status_code = json.decode(response.body)["status_code"];
          message = json.decode(response.body)["message"];
          print('success ${message} _status_code ${status_code}');
          if (status_code == 200) {
            EasyLoading.showSuccess("${message}");
            //resetTeksForm();
            Timer(const Duration(seconds: 1), () {
              _goBack(context);
            });
          } else {
            EasyLoading.showError(message);
            Timer(const Duration(seconds: 1), () {
              _goBack(context);
            });
          }
        });
        EasyLoading.dismiss();
      }
    } catch ($e) {
      //SweetAlert.show(context,style: SweetAlertStyle.error,title: "Error, failed register");
      print($e);
      EasyLoading.showError("failed client error update data");
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewListObp()));
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            centerTitle: true,
            title: const Text('Verifikasi OBP')),
        body: Container(
          key: globalScaffoldKey,
          constraints: BoxConstraints.expand(),
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 2),
          color: HexColor("#f0eff4"),
          child: SingleChildScrollView(
            //scrollDirection: Axis.horizontal,
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: TextField(
                    readOnly: true,
                    controller: txtDriverName,
                    decoration: const InputDecoration(
                        hintText: "Driver Name",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: TextField(
                    readOnly: true,
                    controller: txtNopol,
                    decoration: const InputDecoration(
                        hintText: "NoPol",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: TextField(
                    readOnly: true,
                    controller: txtBpNBR,
                    decoration: const InputDecoration(
                        hintText: "BP Number",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey),
                  ),
                ),
                // SmartSelect<String>.single(
                //   title: 'Sangsi',
                //   placeholder: 'Sangsi',
                //   value: selSangsi,
                //   onChange: (selected) =>
                //       setState(() => selSangsi = selected.value),
                //   choiceItems: S2Choice.listFrom<String, Map>(
                //       source: listSangsi,
                //       value: (index, item) => item['value'],
                //       title: (index, item) => item['title']),
                //   //choiceGrouped: true,
                //   modalType: S2ModalType.popupDialog,
                //   modalFilter: true,
                //   modalFilterAuto: true,
                // ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtClaim,
                    decoration: const InputDecoration(
                        hintText: "Claim", border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtAngsuran,
                    decoration: const InputDecoration(
                        hintText: "Angsuran", border: OutlineInputBorder()),
                  ),
                ),
                Text("DETAIL BIAYA LAKA",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                Divider(
                  color: Colors.transparent,
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtAkomodasi,
                    decoration: const InputDecoration(
                        hintText: "Akomodasi", border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtEvakuasi,
                    decoration: const InputDecoration(
                        hintText: "Evakuasi", border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtKoordinasi,
                    decoration: const InputDecoration(
                        hintText: "Koordinasi", border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtPenggantianBarang,
                    decoration: const InputDecoration(
                        hintText: "Penggantian Barang",
                        border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtPemakaianSparePart,
                    decoration: const InputDecoration(
                        hintText: "Pemakaian Spare Part",
                        border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtJasaPerbaikan,
                    decoration: const InputDecoration(
                        hintText: "Jasa Perbaikan",
                        border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtPenggantianSemen,
                    decoration: const InputDecoration(
                        hintText: "Penggantian Semen",
                        border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtKerugianIdle,
                    decoration: const InputDecoration(
                        hintText: "Kerugian IDLE",
                        border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtTotalSummaryLaka,
                    decoration: const InputDecoration(
                        hintText: "Total Summary Laka",
                        border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    controller: txtBuktiPalenggaran,
                    decoration: const InputDecoration(
                        hintText: "Bukti Pelanggaran (BIP)",
                        border: OutlineInputBorder()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    maxLines: 10,
                    controller: txtBpNotes,
                    decoration: const InputDecoration(
                        hintText: "Notes",
                        border: OutlineInputBorder()),
                  ),
                ),
                Container(
                    margin:
                        EdgeInsets.only(left: 0, top: 5, right: 0, bottom: 5),
                    child: Row(children: <Widget>[
                      Expanded(
                          child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 15.0,
                        ),
                        label: Text("Submit"),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContex) => new AlertDialog(
                              title: new Text('Information'),
                              content: new Text("Close?"),
                              actions: <Widget>[
                                new ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                  label: Text("No"),
                                  onPressed: () {
                                    Navigator.of(dialogContex).pop(false);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Colors.red,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 0),
                                      textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ),
                                new ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.save,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                  label: Text("Submit"),
                                  onPressed: () async {
                                    print('close data');
                                    Navigator.of(dialogContex).pop(false);
                                    if(txtBpNBR.text=='' || txtBpNBR.text==null){
                                      EasyLoading.showError("Back to close another data");
                                    }else{
                                      SaveObp(context);
                                    }

                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 0),
                                      textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 0),
                            textStyle: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      )),
                    ]))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      print(globals.bpnbr);
      txtBpNBR.text = globals.bpnbr == null || globals.bpnbr == ''
          ? '[Not Set]'
          : globals.bpnbr!;
      txtNopol.text = globals.bpvhcid == null || globals.bpvhcid == ''
          ? '[Not Set]'
          : globals.bpvhcid!;
      txtDriverName.text =
          globals.bpdrivername == null || globals.bpdrivername == ''
              ? '[Not Set]'
              : globals.bpdrivername!;
      txtClaim.text = '';
      txtAngsuran.text = '';
      txtAkomodasi.text = '';
      txtEvakuasi.text = '';
      txtKoordinasi.text = '';
      txtPenggantianBarang.text = '';
      txtPemakaianSparePart.text = '';
      txtJasaPerbaikan.text = '';
      txtPenggantianSemen.text = '';
      txtKerugianIdle.text = '';
      txtTotalSummaryLaka.text = '';
      txtBuktiPalenggaran.text = '';
    });
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }
}
