import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/DetailMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_select/awesome_select.dart';
import 'package:http/http.dart' as http;

class FrmObpDouble extends StatefulWidget {
  const FrmObpDouble({Key? key}) : super(key: key);

  @override
  _FrmObpDoubleState createState() => _FrmObpDoubleState();
}

enum asuransi_terdaftar {
  ada,
  tidak_ada,
}

enum asuransi_claim {
  ada,
  tidak_ada,
}

class _FrmObpDoubleState extends State<FrmObpDouble> {
  String selSangsi = '';
  List<Map<String, dynamic>> listSangsi = [
    {'value': 'PERINGANTAN 1', 'title': 'PERINGANTAN 1'},
    {'value': 'STOP OPERASI', 'title': 'STOP OPERASI'},
    {'value': 'GANTI TUNAI', 'title': 'GANTI TUNAI'},
    {'value': 'MENGANGSUR', 'title': 'MENGANGSUR'},
    {'value': 'PHK', 'title': 'PHK'},
  ];

  List<String> list_cost =
      []; //<String>['Aby', 'Aish', 'Ayan', 'Ben', 'Bob', 'Charlie', 'Cook', 'Carline'];

  File? _imageSTNK;
  File? _imageSIM;
  File? _imageKTP;

  File? _imageSTNK_KRBN;
  File? _imageSIM_KRBN;
  File? _imageKTP_KRBN;

  File? _imageKEJADIAN;
  String filePathImageProfile = "";
  String filePathImageSTNK = "";
  String filePathImageSIM = "";
  String filePathImageKTP = "";

  String filePathImageSTNK_KRBN = "";
  String filePathImageSIM_KRBN = "";
  String filePathImageKTP_KRBN = "";

  String filePathImageKEJADIAN = "";
  late Uint8List _bytesImageSTNK;
  late Uint8List _bytesImageSIM;
  late Uint8List _bytesImageKTP;
  final picker = ImagePicker();

  int currentStep = 0;
  List<Map<String, dynamic>> listDriverId = [];
  List<Map<String, dynamic>> dummySearchList = [];
  List<Map<String, dynamic>> listLocid = [];
  List<Map<String, dynamic>> dummySearchListCabang = [];
  List<Map<String, dynamic>> listNopol = [];
  List<Map<String, dynamic>> dummySearchListNopol = [];
  //List<Map<String, dynamic>> listTypeBp = [];
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  //STEP 1
  final TextEditingController txtTanggal = new TextEditingController();
  String tgl_berita = '';
  final TextEditingController txtNamaDriver = new TextEditingController();
  String selDriverId = '';
  final TextEditingController txtNamaCabang = new TextEditingController();
  String selCabangId = '';
  String selTypeBp = '';

  //STEP 2
  final TextEditingController txtNopol = new TextEditingController();
  String selNopol = '';

  final TextEditingController txtNamaKorban = new TextEditingController();
  final TextEditingController txtNopolKorban = new TextEditingController();
  final TextEditingController txtNoRangka = new TextEditingController();
  final TextEditingController txtNoRangkaKorban = new TextEditingController();
  final TextEditingController txtNoMesin = new TextEditingController();
  final TextEditingController txtNoMesinKorban = new TextEditingController();

  final TextEditingController txtNoSim = new TextEditingController();
  final TextEditingController txtNoSimKorban = new TextEditingController();
  final TextEditingController txtNoKtp = new TextEditingController();
  final TextEditingController txtNoKtpKorban = new TextEditingController();
  final TextEditingController txtJamKejadian = new TextEditingController();
  final TextEditingController txtLokasiKejadian = new TextEditingController();
  final TextEditingController txtKronologisKejadian =
      new TextEditingController();
  final TextEditingController txtAdvanceCost = new TextEditingController();
  final TextEditingController txtTotalAdvanceCost = new TextEditingController();
  String foto_kejadian = '';
  String foto_stnk = '';
  String foto_sim = '';
  String foto_ktp = '';
  String sel_jam_kejadian = '';

  double advanvce_cost = 0;
  double total_advanvce_cost = 0;

  //SUMMARY BIAYA LAKA
  final TextEditingController txtAkomodasi = new TextEditingController();
  final TextEditingController txtEvakuasi = new TextEditingController();
  final TextEditingController txtKoordinasi = new TextEditingController();
  final TextEditingController txtPenggantianBarang =
      new TextEditingController();
  final TextEditingController txtPemakaianSparePart =
      new TextEditingController();
  final TextEditingController txtJasaPerbaikan = new TextEditingController();
  final TextEditingController txtPenggantianSemen = new TextEditingController();
  final TextEditingController txtKerugianIdle = new TextEditingController();
  final TextEditingController txtTotalSummaryLaka = new TextEditingController();
  final TextEditingController txtBuktiPalenggaran = new TextEditingController();

  _goBack(BuildContext context) {
    EasyLoading.show();
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DetailMenu()));
    });
  }

  List<Map<String, dynamic>> listTypeBp = [
    {'value': 'LAKA', 'title': 'LAKA'},
    {'value': 'NON LAKA', 'title': 'NO LAKA'},
    {'value': 'PELANGGARAN', 'title': 'PELANGGARAN'},
    {'value': 'TINDAKAN KRIMINAL', 'title': 'TINDAKAN KRIMINAL'},
    {'value': 'BERHENTI', 'title': 'BERHENTI'},
  ];

  // Future<void> initUniqueIdentifierState() async {
  //   String identifier;
  //   try {
  //     identifier = (await UniqueIdentifier.serial);
  //     setState(() {
  //       txtImeiID.text = identifier != null
  //           ? "SRID${identifier.toString().toUpperCase()}"
  //           : '';
  //     });
  //   } catch (PlatformException) {
  //     identifier = 'Failed to get Unique Identifier';
  //   }
  //
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _identifier = identifier;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DetailMenu()));
        return Future.value(false);
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
            title: const Text('Open Bukti Pelanggaran')),
        body: Container(
            padding: const EdgeInsets.all(2),
            child: Stepper(
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: details.onStepContinue,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(currentStep != 3 ? 'Next' : 'Submit'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: details.onStepCancel,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
              type: StepperType.horizontal,
              currentStep: currentStep,
              onStepCancel: () => {
                if (currentStep == 0)
                  {print('back')}
                else
                  setState(() {
                    currentStep -= 1;
                  })
              },
              onStepContinue: () {
                bool isLastStep = (currentStep == getSteps().length - 1);
                print('currentStep ${currentStep}');
                if (isLastStep) {
                  print('save');
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => new AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.0))),
                      title: new Text('Alert'),
                      content: new Text('Create data BP?'),
                      actions: <Widget>[
                        new TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: new Text('No'),
                        ),
                        new TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(false);
                            SaveObp(context);
                          },
                          child: new Text('Yes'),
                        ),
                      ],
                    ),
                  );
                  //save data
                } else {
                  setState(() {
                    currentStep += 1;
                  });
                }
              },
              onStepTapped: (step) => setState(() {
                currentStep = step;
                print('currentStep ${currentStep}');
              }),
              steps: getSteps(),
            )),
      ),
    );
  }

  dateTimePickerWidget(BuildContext context) {
    return DatePicker.showDatePicker(
      context,
      dateFormat: 'HH:mm',
      initialDateTime: DateTime.now(),
      minDateTime: DateTime(2000),
      maxDateTime: DateTime(3000),
      onMonthChangeStartWithFirstDate: true,
      onConfirm: (dateTime, List<int> index) {
        print('Done');
        DateTime selectdate = dateTime;
        sel_jam_kejadian = DateFormat('HH:mm').format(selectdate);
        print(sel_jam_kejadian);
        setState(() {
          txtJamKejadian.text = sel_jam_kejadian.toString() + ":00";
        });
      },
    );
  }

  void resetTeks() {
    setState(() {
      selSangsi = '';
      txtTanggal.text = '';
      selDriverId = '';
      selCabangId = '';
      selTypeBp = '';
      selNopol = '';
      txtNopol.text = '';
      txtNopolKorban.text = '';
      txtNoRangka.text = '';
      txtNoRangkaKorban.text = '';
      txtNoMesin.text = '';
      txtNoMesinKorban.text = '';
      txtNoSim.text = '';
      txtNoSimKorban.text = '';
      txtNoKtp.text = '';
      txtNoKtpKorban.text = '';
      txtJamKejadian.text = '';
      txtLokasiKejadian.text = '';
      txtKronologisKejadian.text = '';
      list_cost = [];
      txtTotalAdvanceCost.text = '';
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

      _imageSTNK = null;
      _imageSIM = null;
      _imageKTP = null;
      _imageKEJADIAN = null;

      filePathImageSTNK = '';
      filePathImageSIM = '';
      filePathImageKTP = '';
      filePathImageKEJADIAN = '';
      tgl_berita = '';

      foto_kejadian = '';
      foto_stnk = '';
      foto_sim = '';
      foto_ktp = '';
      sel_jam_kejadian = '';
      advanvce_cost = 0;
      total_advanvce_cost = 0;
    });
  }

  void GetAttribute(String detail_name, String id) async {
    try {
      EasyLoading.show();
      var url = '';
      if (detail_name == 'vehicle') {
        url =
            "${GlobalData.baseUrl}api/laka/refference.jsp?method=list-detail-nopol-v1&vhcid=${id}";
      }
      if (detail_name == 'driver') {
        url =
            "${GlobalData.baseUrl}api/laka/refference.jsp?method=list-detail-driver-v1&drvid=${id}";
      }
      var urlData = url;
      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(myUri);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (detail_name == 'vehicle') {
          txtNoMesin.text = json.decode(response.body)["nomesin"].toString();
          txtNoRangka.text = json.decode(response.body)["norangka"].toString();
        }
        if (detail_name == 'driver') {
          txtNoKtp.text = json.decode(response.body)["ktpnumber"].toString();
          txtNoSim.text = json.decode(response.body)["simnumber"].toString();
        }
      });
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  void SaveObp(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("name");
      String tgl = txtTanggal.text;
      String driver_id = selDriverId;
      String locid = selCabangId;
      String type_bp = selTypeBp;
      String sangsi = selSangsi;
      String nopol = txtNopol.text;
      String no_rangka = txtNoRangka.text;
      String no_mesin = txtNoMesin.text;
      String no_sim = txtNoSim.text;
      String no_ktp = txtNoKtp.text;
      String _jam_kejadian = txtJamKejadian.text;
      String lokasi_kejadian = txtLokasiKejadian.text;
      String kronologi_kejadian = txtKronologisKejadian.text;
      String _foto_stnk = filePathImageSTNK;
      String _foto_sim = filePathImageSIM;
      String _foto_ktp = filePathImageKTP;
      String _foto_kejadian = filePathImageKEJADIAN;
      String arr_advance_cost = list_cost.length > 0 ? list_cost.join(';') : '';
      String total_advance_cost = txtTotalAdvanceCost.text;
      print('arr_advance_cost ${arr_advance_cost}');

      String nama_krbn = txtNamaKorban.text;
      String nopol_krbn = txtNopolKorban.text;
      String no_rangka_krbn = txtNoRangkaKorban.text;
      String no_mesin_krbn = txtNoMesinKorban.text;
      String no_sim_krbn = txtNoSimKorban.text;
      String no_ktp_krbn = txtNoKtpKorban.text;

      String _foto_stnk_krbn = filePathImageSTNK_KRBN;
      String _foto_sim_krbn = filePathImageSIM_KRBN;
      String _foto_ktp_krbn = filePathImageKTP_KRBN;

      if (tgl == null || tgl == "") {
        EasyLoading.showError("Tanggal berita tidak boleh kosong");
      } else if (driver_id == null || driver_id == "") {
        EasyLoading.showError("Driver tidak boleh kosong");
      } else if (locid == null || locid == "") {
        EasyLoading.showError("Cabang tidak boleh kosong");
      } else if (nopol == null || nopol == "") {
        EasyLoading.showError("Nopol tidak boleh kosong");
      } else if (type_bp == null || type_bp == "") {
        EasyLoading.showError("Type BP tidak boleh kosong");
      } else if (sangsi == null || sangsi == "") {
        EasyLoading.showError("Sangsi tidak boleh kosong");
      } else if (nama_krbn == null || nama_krbn == "") {
        EasyLoading.showError("Nama korban tidak boleh kosong");
      } else if (nopol_krbn == null || nopol_krbn == "") {
        EasyLoading.showError("Nopol mobil korban tidak boleh kosong");
      } else {
        EasyLoading.show();
        var endpointUrl = "${GlobalData.baseUrl}api/laka/save_data_laka.jsp";
        var encoded = Uri.encodeFull(endpointUrl);
        var status_code = 100;
        var message = "";
        print(endpointUrl);
        var claim = selectedRadioClaim.toString();
        var asuransi = selectedRadioAsuransi.toString();
        var map = new Map<String, dynamic>();
        map['method'] = "create-obp-double-v1";
        map['claim_asuransi'] = claim;
        map['terdaftar_asuransi'] = asuransi;
        map['tgl'] = tgl;
        map['driver_id'] = driver_id.toString();
        map['locid'] = locid;
        map['nopol'] = nopol;
        map['type_bp'] = type_bp;
        map['sangsi'] = sangsi;
        map['no_rangka'] = no_rangka;
        map['no_mesin'] = no_mesin;
        map['no_sim'] = no_sim;
        map['no_ktp'] = no_ktp;
        map['jam_kejadian'] = _jam_kejadian;
        map['lokasi_kejadian'] = lokasi_kejadian;
        map['kronologi_kejadian'] = kronologi_kejadian;
        map['foto_stnk'] = _foto_stnk;
        map['foto_sim'] = _foto_sim;
        map['foto_ktp'] = _foto_ktp;
        map['foto_kejadian'] = _foto_kejadian;
        map['nama_krbn'] = nama_krbn; //
        map['nopol_krbn'] = nopol_krbn; //
        map['no_rangka_krbn'] = no_rangka_krbn; //
        map['no_mesin_krbn'] = no_mesin_krbn; //
        map['no_sim_krbn'] = no_sim_krbn; //
        map['no_ktp_krbn'] = no_ktp_krbn; //
        map['foto_stnk_krbn'] = _foto_stnk_krbn; //
        map['foto_sim_krbn'] = _foto_sim_krbn; //
        map['foto_ktp_krbn'] = _foto_ktp_krbn; //
        map['arr_advance_cost'] = arr_advance_cost;
        map['total_advance_cost'] = total_advance_cost;
        map['userid'] = userid;
        print(map);

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
          if (status_code == 200) {
            print('success ${message}');
            EasyLoading.showSuccess(message);
            resetTeks();
          } else {
            EasyLoading.showError(message);
          }
        });
        EasyLoading.dismiss();
      }
    } catch ($e) {
      //SweetAlert.show(context,style: SweetAlertStyle.error,title: "Error, failed register");
      print($e);
      EasyLoading.showError("failed save data");
      EasyLoading.dismiss();
    }
  }

  Future getListCabangOld() async {
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/maintenance/sr/refferencce_mcn.jsp?method=list_cabang");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      listLocid = json.decode(response.body);
      print(listLocid);
      if (listLocid.length == 0 && listLocid == []) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal Load data list cabang", "error");
      } else {
        listLocid = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        dummySearchListCabang = listLocid;
      }
    } else {
      alert(globalScaffoldKey.currentContext!, 0,
          "Gagal Load data Type List Cabang", "error");
    }
  }

  void getListNopol() async {
    try {
      var urlData =
          "${GlobalData.baseUrlOri}api/refference.jsp?method=lookup&list=list-nopol";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          print('loaded driver');
          listNopol = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          dummySearchListNopol = listNopol;
        } else {
          alert(globalScaffoldKey.currentContext!, 0,
              "Gagal load data detail nopol", "error");
        }
      });
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data nopol",
          "error");
      print(e.toString());
    }
  }

  void getListDriverById() async {
    try {
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/sr/list_driver.jsp?method=lookup-driver-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          print('loaded driver');
          listDriverId = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          dummySearchList = listDriverId;
        } else {
          alert(globalScaffoldKey.currentContext!, 0,
              "Gagal load data detail driver", "error");
        }
      });
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data driver",
          "error");
      print(e.toString());
    }
  }

  void getListCabang() async {
    try {
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/sr/refferencce_mcn.jsp?method=list_cabang";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          print('loaded driver');
          listLocid = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          dummySearchListCabang = listLocid;
        } else {
          alert(globalScaffoldKey.currentContext!, 0,
              "Gagal load data detail cabang", "error");
        }
      });
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data cabang",
          "error");
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getListDriverById();
    getListCabang();
    getListNopol();
    EasyLoading.dismiss();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showAlertDialogListCost() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('List Cost Advance'),
          content: SingleChildScrollView(
            padding: EdgeInsets.all(2.0),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                    height: 150, // Change as per your requirement
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        padding: const EdgeInsets.all(0.0),
                        itemCount: list_cost == null ? 0 : list_cost.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 25,
                            margin: EdgeInsets.all(2),
                            //color: Colors.black,
                            child: Center(
                                child: Text(
                              'Cost ${index + 1}: ${list_cost[index]}',
                              style: TextStyle(fontSize: 18),
                            )),
                          );
                        }))
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
    //return
  }

  void getPicture(String opsi, String nama_photo) async {
    if (opsi == 'GALLERY') {
      var pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          if (nama_photo == 'STNK') {
            _imageSTNK = File(pickedFile.path);
            List<int> imageBytes = _imageSTNK!.readAsBytesSync();
            filePathImageSTNK = base64Encode(imageBytes);
            //prefs.setString("photoSTNK", filePathImageSTNK);
            //print(filePathImageSTNK);
          }

          if (nama_photo == 'STNK-KRBN') {
            _imageSTNK_KRBN = File(pickedFile.path);
            List<int> imageBytes = _imageSTNK_KRBN!.readAsBytesSync();
            filePathImageSTNK_KRBN = base64Encode(imageBytes);
            //prefs.setString("photoSTNK", filePathImageSTNK);
            //print(filePathImageSTNK);
          }

          if (nama_photo == 'SIM') {
            _imageSIM = File(pickedFile.path);
            List<int> imageBytes = _imageSIM!.readAsBytesSync();
            filePathImageSIM = base64Encode(imageBytes);
            //prefs.setString("photoSIM", filePathImageSIM);
            //print(filePathImageSIM);
          }

          if (nama_photo == 'SIM-KRBN') {
            _imageSIM_KRBN = File(pickedFile.path);
            List<int> imageBytes = _imageSIM_KRBN!.readAsBytesSync();
            filePathImageSIM_KRBN = base64Encode(imageBytes);
            //prefs.setString("photoSIM", filePathImageSIM);
            //print(filePathImageSIM);
          }

          if (nama_photo == 'KTP') {
            _imageKTP = File(pickedFile.path);
            List<int> imageBytes = _imageKTP!.readAsBytesSync();
            filePathImageKTP = base64Encode(imageBytes);
            //prefs.setString("photoKTP", filePathImageKTP);
            //print(filePathImageKTP);
          }

          if (nama_photo == 'KTP-KRBN') {
            _imageKTP_KRBN = File(pickedFile.path);
            List<int> imageBytes = _imageKTP_KRBN!.readAsBytesSync();
            filePathImageKTP_KRBN = base64Encode(imageBytes);
            //prefs.setString("photoKTP", filePathImageKTP);
            //print(filePathImageKTP);
          }

          if (nama_photo == 'KEJADIAN') {
            _imageKEJADIAN = File(pickedFile.path);
            List<int> imageBytes = _imageKEJADIAN!.readAsBytesSync();
            filePathImageKEJADIAN = base64Encode(imageBytes);
            //prefs.setString("photoKTP", filePathImageKTP);
            //print(filePathImageKEJADIAN);
          }
        });
      }
    } else {
      var pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          if (nama_photo == 'STNK') {
            _imageSTNK = File(pickedFile.path);
            List<int> imageBytes = _imageSTNK!.readAsBytesSync();
            filePathImageSTNK = base64Encode(imageBytes);
            //prefs.setString("photoSTNK", filePathImageSTNK);
            //(filePathImageSTNK);
          }

          if (nama_photo == 'STNK-KRBN') {
            _imageSTNK_KRBN = File(pickedFile.path);
            List<int> imageBytes = _imageSTNK_KRBN!.readAsBytesSync();
            filePathImageSTNK_KRBN = base64Encode(imageBytes);
            //prefs.setString("photoSTNK", filePathImageSTNK);
            //print(filePathImageSTNK);
          }

          if (nama_photo == 'SIM') {
            _imageSIM = File(pickedFile.path);
            List<int> imageBytes = _imageSIM!.readAsBytesSync();
            filePathImageSIM = base64Encode(imageBytes);
            //prefs.setString("photoSIM", filePathImageSIM);
          }

          if (nama_photo == 'SIM-KRBN') {
            _imageSIM_KRBN = File(pickedFile.path);
            List<int> imageBytes = _imageSIM_KRBN!.readAsBytesSync();
            filePathImageSIM_KRBN = base64Encode(imageBytes);
            //prefs.setString("photoSIM", filePathImageSIM);
          }

          if (nama_photo == 'KTP') {
            _imageKTP = File(pickedFile.path);
            List<int> imageBytes = _imageKTP!.readAsBytesSync();
            filePathImageKTP = base64Encode(imageBytes);
            //prefs.setString("photoKTP", filePathImageKTP);
          }

          if (nama_photo == 'KTP-KRBN') {
            _imageKTP_KRBN = File(pickedFile.path);
            List<int> imageBytes = _imageKTP_KRBN!.readAsBytesSync();
            filePathImageKTP_KRBN = base64Encode(imageBytes);
            //prefs.setString("photoKTP", filePathImageKTP);
            //print(filePathImageKTP);
          }

          if (nama_photo == 'KEJADIAN') {
            _imageKEJADIAN = File(pickedFile.path);
            List<int> imageBytes = _imageKEJADIAN!.readAsBytesSync();
            filePathImageKEJADIAN = base64Encode(imageBytes);
            //prefs.setString("photoKTP", filePathImageKTP);
            //print(filePathImageKEJADIAN);
          }
        });
      }
    }
  }

  Future getImageFromCamera(BuildContext contexs, String namaPhoto) async {
    // Navigator.of(contexs).pop(false);
    // Timer(Duration(seconds: 1), () {
    // });
    showDialog(
      context: contexs,
      builder: (contexs) => new AlertDialog(
        title: new Text('Information'),
        content: new Text("Get Picture"),
        actions: <Widget>[
          new ElevatedButton.icon(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20.0,
            ),
            label: Text("Camera"),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
               getPicture('CAMERA', namaPhoto);
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                textStyle:
                    TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          new ElevatedButton.icon(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20.0,
            ),
            label: Text("Gallery"),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
               getPicture('GALLERY', namaPhoto);
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                textStyle:
                    TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAlertDialogPicture(str_photo, name_photo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        if (name_photo == 'STNK') {
          return AlertDialog(
            // <-- SEE HERE
            title: Text('Picture ${name_photo}'),
            content: SingleChildScrollView(
              padding: EdgeInsets.all(2.0),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          Navigator.of(context).pop(false);
                          await getImageFromCamera(context, name_photo);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageSTNK != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageSTNK!,
                                    width: 175,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ))
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10)),
                                  width: 175,
                                  height: 200,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                      size: 15.0,
                                    ),
                                    label: Text("Photo ${name_photo}"), onPressed: () {  },
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        } else if (name_photo == 'SIM') {
          return AlertDialog(
            // <-- SEE HERE
            title: Text('Picture ${name_photo}'),
            content: SingleChildScrollView(
              padding: EdgeInsets.all(2.0),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          Navigator.of(context).pop(false);
                          await getImageFromCamera(context, name_photo);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageSIM != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageSIM!,
                                    width: 175,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ))
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10)),
                                  width: 175,
                                  height: 200,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                      size: 15.0,
                                    ),
                                    label: Text("Photo ${name_photo}"), onPressed: () {  },
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        } else if (name_photo == 'KTP') {
          return AlertDialog(
            // <-- SEE HERE
            title: Text('Picture ${name_photo}'),
            content: SingleChildScrollView(
              padding: EdgeInsets.all(2.0),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          Navigator.of(context).pop(false);
                          await getImageFromCamera(context, name_photo);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageKTP != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageKTP!,
                                    width: 175,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ))
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10)),
                                  width: 175,
                                  height: 200,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                      size: 15.0,
                                    ),
                                    label: Text("Photo ${name_photo}"), onPressed: () {  },
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        } else if (name_photo == 'KEJADIAN') {
          return AlertDialog(
            // <-- SEE HERE
            title: Text('Picture ${name_photo}'),
            content: SingleChildScrollView(
              padding: EdgeInsets.all(2.0),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          Navigator.of(context).pop(false);
                          await getImageFromCamera(context, name_photo);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageKEJADIAN != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageKEJADIAN!,
                                    width: 175,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ))
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10)),
                                  width: 175,
                                  height: 200,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                      size: 15.0,
                                    ),
                                    label: Text("Photo ${name_photo}"), onPressed: () {  },
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
        if (name_photo == 'STNK-KRBN') {
          return AlertDialog(
            // <-- SEE HERE
            title: Text('Picture ${name_photo}'),
            content: SingleChildScrollView(
              padding: EdgeInsets.all(2.0),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          Navigator.of(context).pop(false);
                          await getImageFromCamera(context, name_photo);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageSTNK_KRBN != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageSTNK_KRBN!,
                                    width: 175,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ))
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10)),
                                  width: 175,
                                  height: 200,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                      size: 15.0,
                                    ),
                                    label: Text("Photo ${name_photo}"), onPressed: () {  },
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        } else if (name_photo == 'SIM-KRBN') {
          return AlertDialog(
            // <-- SEE HERE
            title: Text('Picture ${name_photo}'),
            content: SingleChildScrollView(
              padding: EdgeInsets.all(2.0),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          Navigator.of(context).pop(false);
                          await getImageFromCamera(context, name_photo);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageSIM_KRBN != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageSIM_KRBN!,
                                    width: 175,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ))
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10)),
                                  width: 175,
                                  height: 200,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                      size: 15.0,
                                    ),
                                    label: Text("Photo ${name_photo}"), onPressed: () {  },
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        } else if (name_photo == 'KTP-KRBN') {
          return AlertDialog(
            // <-- SEE HERE
            title: Text('Picture ${name_photo}'),
            content: SingleChildScrollView(
              padding: EdgeInsets.all(2.0),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          Navigator.of(context).pop(false);
                          await getImageFromCamera(context, name_photo);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageKTP_KRBN != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageKTP_KRBN!,
                                    width: 175,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ))
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10)),
                                  width: 175,
                                  height: 200,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                      size: 15.0,
                                    ),
                                    label: Text("Photo ${name_photo}"), onPressed: () {  },
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        } else{
          return Container();
        }
      },
    );
    //return
  }

  int? selectedRadioAsuransi;
  int? selectedRadioClaim;
  asuransi_terdaftar? g_asuransi_terdaftar;

  setSelectedRadio(int val) {
    setState(() {
      selectedRadioAsuransi = val;
    });
  }

  setSelectedRadioClaim(int val) {
    setState(() {
      selectedRadioClaim = val;
    });
  }

  List<Step> getSteps() {
    return <Step>[
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: const Text("B.A"),
        content: Column(
          children: [
            Container(
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text('Asuransi:',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 18,
                      ))
                ])),
            Container(
                child: RadioListTile(
              value: 1,
              groupValue: selectedRadioAsuransi,
              title: Text("Ada"),
              //subtitle: Text("Radio 1 Subtitle"),
              onChanged: (val) {
                print("Radio $val");
                setSelectedRadio(val!);
              },
              //activeColor: Colors.black,
              //selected: true,
            )),
            Container(
                child: RadioListTile(
              value: 0,
              groupValue: selectedRadioAsuransi,
              title: Text("Tidak Ada"),
              //subtitle: Text("Radio 1 Subtitle"),
              onChanged: (val) {
                print("Radio $val");
                setSelectedRadio(val!);
              },
              //activeColor: Colors.black,
              //selected: true,
            )),
            Container(
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text('Claim Asuransi:',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 18,
                      ))
                ])),
            Container(
                child: RadioListTile(
              value: 1,
              groupValue: selectedRadioClaim,
              title: Text("DILAPORKAN"),
              //subtitle: Text("Radio 1 Subtitle"),
              onChanged: (val) {
                print("Radio $val");
                setSelectedRadioClaim(val!);
              },
              //activeColor: Colors.black,
              //selected: true,
            )),
            Container(
                child: RadioListTile(
              value: 0,
              groupValue: selectedRadioClaim,
              title: Text("TIDAK DILAPORKAN"),
              //subtitle: Text("Radio 1 Subtitle"),
              onChanged: (val) {
                print("Radio $val");
                setSelectedRadioClaim(val!);
              },
              //activeColor: Colors.black,
              //selected: true,
            )),
            DateTimePicker(
              dateMask: 'yyyy-MM-dd',
              controller: txtTanggal,
              //initialValue: _initialValue,
              firstDate: DateTime(1970),
              lastDate: DateTime(2100),
              icon: Icon(Icons.event),
              dateLabelText: 'Tanggal',
              selectableDayPredicate: (date) {
                return true;
              },
              onChanged: (val) => setState(() => tgl_berita = val),
              validator: (val) {
                setState(() => tgl_berita = val ?? '');
                return null;
              },
              onSaved: (val) => setState(() => tgl_berita = val ?? ''),
            ),
            SmartSelect<String?>.single(
              title: 'Nama Driver',
              placeholder: 'Nama Driver',
              selectedValue: selDriverId,
              onChange: (selected) {
                setState(() => selDriverId = selected.value!);
                GetAttribute('driver', selDriverId);
              },
              choiceItems: S2Choice.listFrom<String, Map>(
                  source: listDriverId,
                  value: (index, item) => item['value'],
                  title: (index, item) => item['title']),
              //choiceGrouped: true,
              modalType: S2ModalType.popupDialog,
              modalFilter: true,
              modalFilterAuto: true,
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtNoSim,
                //style: TextStyle(fontSize: 30.0, height: 0.2, color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: _imageSIM != null && _imageSIM != ''
                      ? Icon(Icons.image)
                      : null,
                  hintText: "NO. SIM",
                  border: OutlineInputBorder(),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(70, 30),
                        backgroundColor: Colors.blueAccent,
                        // shape: new RoundedRectangleBorder(
                        //   borderRadius: new BorderRadius.circular(30.0),
                        // ),
                      ),
                      child: Text("Picture SIM"),
                      onPressed: () {
                        _showAlertDialogPicture('', 'SIM');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtNoKtp,
                decoration: InputDecoration(
                  prefixIcon: _imageKTP != null && _imageKTP != ''
                      ? Icon(Icons.image)
                      : null,
                  hintText: "NO.KTP",
                  border: OutlineInputBorder(),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(70, 30),
                        backgroundColor: Colors.blueAccent,
                        // shape: new RoundedRectangleBorder(
                        //   borderRadius: new BorderRadius.circular(30.0),
                        // ),
                      ),
                      child: Text("Picture KTP"),
                      onPressed: () {
                        _showAlertDialogPicture('', 'KTP');
                      },
                    ),
                  ),
                ),
              ),
            ),
            SmartSelect<String?>.single(
              title: 'Cabang',
              placeholder: 'Cabang',
              selectedValue: selCabangId,
              onChange: (selected) =>
                  setState(() => selCabangId = selected.value!),
              choiceItems: S2Choice.listFrom<String, Map>(
                  source: listLocid,
                  value: (index, item) => item['id'],
                  title: (index, item) => item['text']),
              //choiceGrouped: true,
              modalType: S2ModalType.popupDialog,
              modalFilter: true,
              modalFilterAuto: true,
            ),
            SmartSelect<String?>.single(
              title: 'Type BP',
              placeholder: 'Type BP',
              selectedValue: selTypeBp,
              onChange: (selected) =>
                  setState(() => selTypeBp = selected.value!),
              choiceItems: S2Choice.listFrom<String, Map>(
                  source: listTypeBp,
                  value: (index, item) => item['value'],
                  title: (index, item) => item['title']),
              //choiceGrouped: true,
              modalType: S2ModalType.popupDialog,
              modalFilter: true,
              modalFilterAuto: true,
            ),
            SmartSelect<String?>.single(
              title: 'Sangsi',
              placeholder: 'Sangsi',
              selectedValue: selSangsi,
              onChange: (selected) =>
                  setState(() => selSangsi = selected.value!),
              choiceItems: S2Choice.listFrom<String, Map>(
                  source: listSangsi,
                  value: (index, item) => item['value'],
                  title: (index, item) => item['title']),
              //choiceGrouped: true,
              modalType: S2ModalType.popupDialog,
              modalFilter: true,
              modalFilterAuto: true,
            ),
          ],
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text("ID UNITS"),
        content: Column(
          children: [
            SmartSelect<String?>.single(
              title: 'Select Nopol',
              placeholder: 'Select Nopol',
              selectedValue: txtNopol.text,
              onChange: (selected) {
                setState(() => txtNopol.text = selected.value!);
                GetAttribute('vehicle', txtNopol.text);
              },
              choiceItems: S2Choice.listFrom<String, Map>(
                  source: listNopol,
                  value: (index, item) => item['id'],
                  title: (index, item) => item['text']),
              //choiceGrouped: true,
              modalType: S2ModalType.popupDialog,
              modalFilter: true,
              modalFilterAuto: true,
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                readOnly: true,
                controller: txtNopol,
                decoration: InputDecoration(
                  prefixIcon: _imageSTNK != null && _imageSTNK != ''
                      ? Icon(Icons.image)
                      : null,
                  hintText: "Nopol",
                  border: OutlineInputBorder(),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(70, 30),
                        backgroundColor: Colors.blueAccent,
                        // shape: new RoundedRectangleBorder(
                        //   borderRadius: new BorderRadius.circular(30.0),
                        // ),
                      ),
                      child: Text("Picture STNK"),
                      onPressed: () {
                        _showAlertDialogPicture('', 'STNK');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtNoRangka,
                decoration: const InputDecoration(
                    hintText: "No Rangka", border: OutlineInputBorder()),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtNoMesin,
                decoration: const InputDecoration(
                    hintText: "No. Mesin", border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text("ID KRBN"),
        content: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                //readOnly: true,
                controller: txtNopolKorban,
                decoration: InputDecoration(
                  prefixIcon: _imageSTNK_KRBN != null && _imageSTNK_KRBN != ''
                      ? Icon(Icons.image)
                      : null,
                  hintText: "Nopol",
                  border: OutlineInputBorder(),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(70, 30),
                        backgroundColor: Colors.blueAccent,
                        // shape: new RoundedRectangleBorder(
                        //   borderRadius: new BorderRadius.circular(30.0),
                        // ),
                      ),
                      child: Text("Picture STNK"),
                      onPressed: () {
                        _showAlertDialogPicture('', 'STNK-KRBN');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtNoRangkaKorban,
                decoration: const InputDecoration(
                    hintText: "No Rangka", border: OutlineInputBorder()),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtNoMesinKorban,
                decoration: const InputDecoration(
                    hintText: "No. Mesin", border: OutlineInputBorder()),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                readOnly: true,
                onTap: () {
                  dateTimePickerWidget(context);
                },
                controller: txtJamKejadian,
                decoration: const InputDecoration(
                    hintText: "Jam Kejadian", border: OutlineInputBorder()),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtLokasiKejadian,
                decoration: const InputDecoration(
                    hintText: "Lokasi Kejadian", border: OutlineInputBorder()),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtKronologisKejadian,
                maxLines: 10,
                //style: TextStyle(fontSize: 30.0, height: 0.2, color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: _imageKEJADIAN != null && _imageKEJADIAN != ''
                      ? Icon(Icons.image)
                      : null,
                  hintText: "Kronologis Kejadian",
                  border: OutlineInputBorder(),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(70, 30),
                        backgroundColor: Colors.blueAccent,
                        // shape: new RoundedRectangleBorder(
                        //   borderRadius: new BorderRadius.circular(30.0),
                        // ),
                      ),
                      child: Text("Picture KEJ"),
                      onPressed: () {
                        _showAlertDialogPicture('', 'KEJADIAN');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtNamaKorban,
                decoration: const InputDecoration(
                    hintText: "Nama Korban", border: OutlineInputBorder()),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtNoKtpKorban,
                //style: TextStyle(fontSize: 30.0, height: 0.2, color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: _imageKTP_KRBN != null && _imageKTP_KRBN != ''
                      ? Icon(Icons.image)
                      : null,
                  hintText: "No KTP",
                  border: OutlineInputBorder(),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(70, 30),
                        backgroundColor: Colors.blueAccent,
                        // shape: new RoundedRectangleBorder(
                        //   borderRadius: new BorderRadius.circular(30.0),
                        // ),
                      ),
                      child: Text("Picture KTP"),
                      onPressed: () {
                        _showAlertDialogPicture('', 'KTP-KRBN');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtNoSimKorban,
                //style: TextStyle(fontSize: 30.0, height: 0.2, color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: _imageSIM_KRBN != null && _imageSIM_KRBN != ''
                      ? Icon(Icons.image)
                      : null,
                  hintText: "No SIM",
                  border: OutlineInputBorder(),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(70, 30),
                        backgroundColor: Colors.blueAccent,
                        // shape: new RoundedRectangleBorder(
                        //   borderRadius: new BorderRadius.circular(30.0),
                        // ),
                      ),
                      child: Text("Picture SIM"),
                      onPressed: () {
                        _showAlertDialogPicture('', 'SIM-KRBN');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Step(
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
        title: const Text("Advance"),
        content: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                ],
                controller: txtAdvanceCost,
                decoration: InputDecoration(
                  //prefixIcon: Icon(Icons.camera),
                  hintText: "Cost Advance", border: OutlineInputBorder(),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(70, 30),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Text("+ Add"),
                      onPressed: () {
                        if (txtAdvanceCost.text == "" ||
                            txtAdvanceCost.text == null ||
                            txtAdvanceCost.text == '0') return;
                        setState(() {
                          advanvce_cost =
                              advanvce_cost + double.parse(txtAdvanceCost.text);
                          txtTotalAdvanceCost.text = advanvce_cost.toString();
                          list_cost.add(txtAdvanceCost.text.toString());
                          txtAdvanceCost.text = '0';
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: txtTotalAdvanceCost,
                readOnly: true,
                decoration: InputDecoration(
                  //prefixIcon: Icon(Icons.camera),
                  hintText: "Total Cost Advance", border: OutlineInputBorder(),
                  suffixIcon: Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(70, 30),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Text("Detail"),
                      onPressed: () {
                        print(list_cost);
                        _showAlertDialogListCost();
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  advanvce_cost = 0;
                  txtAdvanceCost.text = '0';
                  txtTotalAdvanceCost.text = '0';
                  list_cost = [];
                },
                style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white),
                child: Text('Reset'),
              ),
            ),
          ],
        ),
      ),
      // Step(
      //   state: currentStep > 3 ? StepState.complete : StepState.indexed,
      //   isActive: currentStep >= 3,
      //   title: const Text("Summary Biaya"),
      //   content: Column(
      //     children: [
      //       Container(
      //         margin: const EdgeInsets.only(bottom: 10),
      //         child: TextField(
      //           controller: txtAkomodasi,
      //           decoration: const InputDecoration(
      //               hintText: "Akomodasi", border: OutlineInputBorder()),
      //         ),
      //       ),
      //       Container(
      //         margin: const EdgeInsets.only(bottom: 10),
      //         child: TextField(
      //           controller: txtEvakuasi,
      //           decoration: const InputDecoration(
      //               hintText: "Evakuasi", border: OutlineInputBorder()),
      //         ),
      //       ),
      //       Container(
      //         margin: const EdgeInsets.only(bottom: 10),
      //         child: TextField(
      //           controller: txtKoordinasi,
      //           decoration: const InputDecoration(
      //               hintText: "Koordinasi", border: OutlineInputBorder()),
      //         ),
      //       ),
      //       Container(
      //         margin: const EdgeInsets.only(bottom: 10),
      //         child: TextField(
      //           controller: txtPenggantianBarang,
      //           decoration: const InputDecoration(
      //               hintText: "Penggantian Barang",
      //               border: OutlineInputBorder()),
      //         ),
      //       ),
      //       Container(
      //         margin: const EdgeInsets.only(bottom: 10),
      //         child: TextField(
      //           controller: txtPemakaianSparePart,
      //           decoration: const InputDecoration(
      //               hintText: "Pemakaian Spare Part",
      //               border: OutlineInputBorder()),
      //         ),
      //       ),
      //       Container(
      //         margin: const EdgeInsets.only(bottom: 10),
      //         child: TextField(
      //           controller: txtJasaPerbaikan,
      //           decoration: const InputDecoration(
      //               hintText: "Jasa Perbaikan", border: OutlineInputBorder()),
      //         ),
      //       ),
      //       Container(
      //         margin: const EdgeInsets.only(bottom: 10),
      //         child: TextField(
      //           controller: txtPenggantianSemen,
      //           decoration: const InputDecoration(
      //               hintText: "Penggantian Semen",
      //               border: OutlineInputBorder()),
      //         ),
      //       ),
      //       Container(
      //         margin: const EdgeInsets.only(bottom: 10),
      //         child: TextField(
      //           controller: txtKerugianIdle,
      //           decoration: const InputDecoration(
      //               hintText: "Kerugian IDLE", border: OutlineInputBorder()),
      //         ),
      //       ),
      //       Container(
      //         margin: const EdgeInsets.only(bottom: 10),
      //         child: TextField(
      //           controller: txtTotalSummaryLaka,
      //           decoration: const InputDecoration(
      //               hintText: "Total Summary Laka",
      //               border: OutlineInputBorder()),
      //         ),
      //       ),
      //       Container(
      //         margin: const EdgeInsets.only(bottom: 10),
      //         child: TextField(
      //           controller: txtBuktiPalenggaran,
      //           decoration: const InputDecoration(
      //               hintText: "Bukti Pelanggaran (BIP)",
      //               border: OutlineInputBorder()),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    ];
  }
}
