import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/driver/ApprovedDriverRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FrmApprovalReqDriver extends StatefulWidget {
  final String vhcid;
  final String rdtype;
  final String locid;

  FrmApprovalReqDriver({this.vhcid = '', this.rdtype = '', this.locid = ''});

  @override
  _FrmApprovalReqDriverState createState() => _FrmApprovalReqDriverState();
}

class _FrmApprovalReqDriverState extends State<FrmApprovalReqDriver> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _notesController = TextEditingController();
  bool _submitting = false;
  String _selectedRdtype = '';
  String _selectedVhcid = '';
  String _selectedLocid = '';
  List<Map<String, dynamic>> _vehicleList = [];
  List<Map<String, dynamic>> _locidList = [];
  bool _loadingVehicles = true;
  bool _loadingLocid = true;

  @override
  void initState() {
    super.initState();
    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    _selectedRdtype = (widget.rdtype == null || widget.rdtype.isEmpty)
        ? 'BATANGAN'
        : widget.rdtype;
    _selectedVhcid = widget.vhcid ?? '';
    _selectedLocid = '';
    _fetchVehicleList();
    _fetchLocidList();
  }

  Future<void> _add_request() async {
    SharedPreferences prefs =
    await SharedPreferences.getInstance();
    var username = prefs.getString("name");
    if (_submitting) return;
    setState(() {
      _submitting = true;
    });

    try {
      if(_selectedVhcid.isEmpty){
        alert(globalScaffoldKey.currentContext!, 2, 'VHCID tidak boleh kosong',
            'warning');
        return ;
      }
      if(_selectedRdtype.isEmpty){
        alert(globalScaffoldKey.currentContext!, 2, 'Default Driver tidak boleh kosong',
            'warning');
        return ;
      }
      if(_selectedLocid.isEmpty){
        alert(globalScaffoldKey.currentContext!, 2, 'Locid tidak boleh kosong',
            'warning');
        return ;
      }
      if(_notesController.text.isEmpty){
        alert(globalScaffoldKey.currentContext!, 2, 'Notes tidak boleh kosong',
            'warning');
        return ;
      }
      final String userid = username!;
      final String notes = _notesController.text ?? '';

      final String url = GlobalData.baseUrl +
          'api/driver/add_request_driver.jsp?method=add-req-driver' +
          '&vhcid=' +
          Uri.encodeComponent(_selectedVhcid) +
          '&rdtype=' +
          Uri.encodeComponent(_selectedRdtype) +
          '&locid=' +
          Uri.encodeComponent(_selectedLocid) +
          '&notes=' +
          Uri.encodeComponent(notes) +
          '&userid=' +
          Uri.encodeComponent(userid);
      print(url);
      final uri = Uri.parse(url);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        Map<String, dynamic> body;
        try {
          body = json.decode(response.body) as Map<String, dynamic>;
        } catch (_) {
          body = <String, dynamic>{};
        }
        final int statusCode = (body['status_code'] is int)
            ? body['status_code'] as int
            : int.tryParse((body['status_code'] ?? '').toString()) ?? 0;
        if (statusCode == 200) {
          final String rdnbr = (body['rdnbr'] ?? '').toString();
          alert(globalScaffoldKey.currentContext!, 1, 'Add request driver sukses: ' + rdnbr, 'success');
          Navigator.pop(context, body);
        } else {
          final String msg = (body['message'] ?? 'Gagal').toString();
          alert(globalScaffoldKey.currentContext!, 2, msg, 'warning');
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 2, 'Server error: ' + response.statusCode.toString(),
            'warning');
      }
    } catch (e) {
      if (e is IOException) {
        alert(globalScaffoldKey.currentContext!, 2, 'Please check your internet connection.', 'warning');
      } else {
        alert(globalScaffoldKey.currentContext!, 2, 'Something went wrong.', 'warning');
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  goBack(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        goBack(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF8C69),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              goBack(context);
            },
          ),
          title: const Text('Form Request Driver'),
        ),
        body: SingleChildScrollView(
          key: globalScaffoldKey,
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _vhcidDropdown(),
              SizedBox(height: 8),
              _rdtypeDropdown(),
              SizedBox(height: 8),
              _locidDropdown(),
              //_readonlyField('LOCID', widget.locid),
              SizedBox(height: 16),
              Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                    hintText: 'Tambahkan catatan (opsional)'),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _submitting
                            ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                            : Icon(Icons.check, color: Colors.white, size: 18.0),
                        label: Text(_submitting ? 'Memproses...' : 'Add'),
                        onPressed: _submitting
                            ? null
                            : () async {
                          final bool confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: Text('Konfirmasi'),
                                content: Text('Add request driver ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    },
                                    child: Text('Tidak'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop(true);
                                    },
                                    child: Text('Ya'),
                                  ),
                                ],
                              );
                            },
                          ) ??
                              false;

                          if (!confirm) {
                            Navigator.pop(context);
                            return;
                          }

                          await _add_request();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 2.0,
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          textStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.info, color: Colors.white, size: 18.0),
                      label: Text("Detail"),
                      onPressed: () {
                        // Arahkan ke halaman detail
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => ApprovedDriverRequest()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 2.0,
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Text(value ?? '',
              style: TextStyle(color: Colors.black87, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _rdtypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Degault Driver', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: (_selectedRdtype == null || _selectedRdtype.isEmpty)
              ? 'BATANGAN'
              : _selectedRdtype,
          items: <String>['BATANGAN', 'SEREP']
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedRdtype = val ?? 'BATANGAN';
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  String _safeString(Map<String, dynamic> map, String key) {
    final dynamic value = map[key];
    if (value == null) return "";
    final String text = value.toString();
    if (text.toLowerCase() == 'null') return "";
    return text;
  }

  Future<void> _fetchVehicleList() async {
    try {
      final String url = GlobalData.baseUrl +
          'api/driver/master_vehicle.jsp?method=list-vehicle-close';
      print(url);
      final uri = Uri.parse(url);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int statusCode = responseData['status_code'] ?? 0;

        if (statusCode == 200) {
          final List<dynamic> dataList = responseData['data'] ?? [];
          final List<Map<String, dynamic>> vehicles = [];

          dataList.forEach((item) {
            vehicles.add({
              'id': _safeString(item, 'id'),
              'text': _safeString(item, 'text'),
            });
          });

          setState(() {
            _vehicleList = vehicles;
            _loadingVehicles = false;
            // Set default selection only if widget vhcid exists in the list
            if (widget.vhcid != null && widget.vhcid.isNotEmpty) {
              final foundVehicle = vehicles.firstWhere(
                (v) => v['id'] == widget.vhcid,
                orElse: () => {'id': '', 'text': ''},
              );
              _selectedVhcid = foundVehicle['id']; // Will be empty if not found
            } else {
              _selectedVhcid = ''; // Default to empty if no widget vhcid
            }
          });
        } else {
          // No data or error from API
          setState(() {
            _vehicleList = [];
            _loadingVehicles = false;
          });
          print(
              'API returned status: $statusCode, message: ${responseData['message']}');
        }
      } else {
        setState(() {
          _loadingVehicles = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingVehicles = false;
      });
      print('Error fetching vehicle list: $e');
    }
  }

  Future<void> _fetchLocidList() async {
    try {
      final String url = GlobalData.baseUrl +
          'api/driver/master_locid.jsp?method=list-locid';
      print(url);
      final uri = Uri.parse(url);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int statusCode = responseData['status_code'] ?? 0;

        if (statusCode == 200) {
          final List<dynamic> dataList = responseData['data'] ?? [];
          final List<Map<String, dynamic>> locid = [];

          dataList.forEach((item) {
            locid.add({
              'id': _safeString(item, 'id'),
              'text': _safeString(item, 'text'),
            });
          });

          setState(() {
            _locidList = locid;
            _loadingLocid = false;
          });
        } else {
          // No data or error from API
          setState(() {
            _locidList = [];
            _loadingLocid = false;
          });
          print(
              'API returned status: $statusCode, message: ${responseData['message']}');
        }
      } else {
        setState(() {
          _loadingLocid = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingLocid = false;
      });
      print('Error fetching locid list: $e');
    }
  }

  Widget _vhcidDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VHCID', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        _loadingVehicles
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading vehicles...'),
                  ],
                ),
              )
            : Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _vehicleList
                        .map((vehicle) => vehicle['id'].toString())
                        .toList();
                  }
                  return _vehicleList
                      .where((vehicle) => vehicle['id']
                          .toString()
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()))
                      .map((vehicle) => vehicle['id'].toString())
                      .toList();
                },
                onSelected: (String selection) {
                  setState(() {
                    _selectedVhcid = selection;
                  });
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                  // Set initial value
                  if (controller.text.isEmpty && _selectedVhcid.isNotEmpty) {
                    controller.text = _selectedVhcid;
                  }

                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                      hintText: 'Cari ID kendaraan...',
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final String option = options.elementAt(index);
                            final vehicle = _vehicleList.firstWhere(
                              (v) => v['id'] == option,
                              orElse: () => {'id': '', 'text': ''},
                            );

                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Text(
                                  '${vehicle['id']} - ${vehicle['text']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _locidDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LOCID', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        _loadingLocid
            ? Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading locid...'),
            ],
          ),
        )
            : Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _locidList
                  .map((locid) => locid['id'].toString())
                  .toList();
            }
            return _locidList
                .where((locid) => locid['id']
                .toString()
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()))
                .map((locid) => locid['id'].toString())
                .toList();
          },
          onSelected: (String selection) {
            setState(() {
              _selectedLocid = selection;
            });
          },
          fieldViewBuilder:
              (context, controller, focusNode, onEditingComplete) {
            // Set initial value
            if (controller.text.isEmpty && _selectedLocid.isNotEmpty) {
              controller.text = _selectedLocid;
            }

            return TextField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                hintText: 'Cari LOCID...',
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final String option = options.elementAt(index);
                      final locid = _locidList.firstWhere(
                            (v) => v['id'] == option,
                        orElse: () => {'id': '', 'text': ''},
                      );

                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Text(
                            '${locid['id']} - ${locid['text']}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
