import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/sub_menu_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MasterInventory extends StatefulWidget {
  @override
  MasterInventoryState createState() => MasterInventoryState();
}

class MasterInventoryState extends State<MasterInventory> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txtSearch = new TextEditingController();
  final picker = ImagePicker();
  String filePathImage = "";
  File? _image;
  List listMasterInv = [];
  final String BASE_URL = GlobalData.baseUrl;
  _goBack(BuildContext context) async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SubMenuInventory()));
  }

  void resetTeks() {
    setState(() {
      _image = null;
      filePathImage = "";
      cacheItemID = "";
    });
  }

  Future getImageFromCamera(BuildContext contexs, String namaPhoto) async {
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
            label: Text("No"),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
              resetTeks();
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.orangeAccent,
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
            label: Text("Camera"),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
              getPicture(namaPhoto, 'CAMERA');
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

  void getPicture(String namaPhoto, opsi) async {
    print('nama photo ${namaPhoto}');
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      if (namaPhoto == "DRIVER") {
        setState(() {
          _image = File(pickedFile.path);
          List<int> imageBytes = _image!.readAsBytesSync();
          var kb = _image!.readAsBytesSync().lengthInBytes / 1024;
          var mb = kb / 1024;
          print("MB " + mb.toString());
          print("KB " + kb.toString());
          filePathImage = base64Encode(imageBytes);
        });
      }
    }
  }

  Future GetListMasterInv(String search) async {
    try {
      EasyLoading.show();
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/inventory/list_master_inventory.jsp?method=list-inventory-master-v1&search=${search}");
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        setState(() {
          listMasterInv = json.decode(response.body);
        });
        //print(listLocidCHK);
        if (listMasterInv.length == 0 && listMasterInv == []) {
          alert(globalScaffoldKey.currentContext!, 0, "data tidak di temukan",
              "error");
        } else {
          listMasterInv = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal Load data Type List Master item", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SubMenuInventory()));
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 20.0,
            onPressed: () {
              _goBack(context);
            },
          ),
          title: Text('Master Inventory'),
        ),
        key: globalScaffoldKey,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: txtSearch,
                          style: TextStyle(fontSize: 16.0),
                          maxLines: null,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 10.0),
                            hintText: 'Search...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          if (txtSearch.text != "" && txtSearch.text != "") {
                            await GetListMasterInv(txtSearch.text);
                          } else {
                            await GetListMasterInv("");
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(5.0),
                    itemCount: listMasterInv == null ? 0 : listMasterInv.length,
                    itemBuilder: (context, index) {
                      return buildListInv(context, listMasterInv[index], index);
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String cacheItemID = "";
  var status_code = 100;
  var message = "";
  void SaveOrUpdatePhotoItem() async {
    try {
      EasyLoading.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("name");
      if (cacheItemID == null || cacheItemID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Item ID tidak boleh kosong", "error");
      } else if (userid == null || userid == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "User ID tidak boleh kosong", "error");
      } else if (filePathImage == "" || filePathImage == null) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Photo item tidak boleh kosong", "error");
      } else {
        //PHOTOPART
        //var encoded = Uri.encodeFull("${GlobalData.baseUrl}api/vehicle/update_or_view_photo_vehicle.jsp");
        var encoded = Uri.encodeFull(
            "${GlobalData.baseUrl}api/inventory/update_photo_item.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'update-photo-item',
          'ititemid': cacheItemID,
          'userid': userid,
          'str_photo': filePathImage
        };
        print(data);
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
        setState(() {
          if (response.statusCode == 200) {
            var dataRes = json.decode(response.body);
            if (dataRes.length > 0) {
              status_code = dataRes["status_code"];
              message = dataRes["message"];
              print(response);
              if (status_code == 200) {
                alert(globalScaffoldKey.currentContext!, 1, message, "success");
                GetListMasterInv("");
              } else {
                alert(globalScaffoldKey.currentContext!, 0,
                    "Gagal update ${message}", "error");
              }
            } else {
              alert(globalScaffoldKey.currentContext!, 0,
                  "Gagal update photo item", "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "Gagal update ${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Failed, ${e.toString()} ",
          "error");
      print(e.toString());
    }
  }

  Widget buildListInv(BuildContext context, dynamic item, int index) {
    String partname = item["partname"].toString().length > 11
        ? item["partname"].substring(0, 10)
        : item["partname"].substring(0, item["partname"].toString().length);
    print(partname);
    // print('item["partname"].toString().length ${item["partname"].toString().length}');
    // String partname = item["partname"].substring(0, 12)+"...";
    return Container(
      margin: const EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
        border: Border.all(
          color: Colors.grey, // Set border color
          width: 1.0, // Set border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.only(bottom: 1, top: 8, right: 5, left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ITEM ID ${item["ititemid"]}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8)
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                border: Border(
                  //top: BorderSide(width: 1.0, color: Colors.black),
                  bottom: BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              child: Divider(
                height: 0.0,
                color: Colors.transparent,
              ),
            ),
            Container(
                padding:
                    const EdgeInsets.only(bottom: 1, top: 8, right: 5, left: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () async {
                          resetTeks();
                          cacheItemID = item["ititemid"].toString();
                          await getImageFromCamera(context, "DRIVER");
                        },
                        child: cacheItemID == item["ititemid"].toString() &&
                                _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _image!,
                                  width: 50,
                                  height: 100.0,
                                  scale: 0.8,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Optional: for rounded borders
                                ),
                                child: Image.network(
                                  "http://apps.tuluatas.com:8080/trucking/photo_items/${item["photo_item"]}",
                                  width:
                                      50.0, // Adjust the image width as needed
                                  height:
                                      100.0, // Adjust the image height as needed
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                        'Image not found'); // Placeholder text or widget
                                  }, // Image fit
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(Icons.inventory),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '\Name: ${partname} \nVH Type: ${item["vhtid"]} \nMerk: ${item["merk"]} \nSize: ${item["itemsize"]}',
                                        textAlign: TextAlign.justify,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          )),
                    ),
                  ],
                )),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                border: Border(
                  //top: BorderSide(width: 1.0, color: Colors.black),
                  bottom: BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              child: Divider(
                height: 0.0,
                color: Colors.transparent,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.only(bottom: 1, top: 8, right: 5, left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          SaveOrUpdatePhotoItem();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Update Photo Item'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    resetTeks();
    GetListMasterInv("");
    super.initState();
  }
}

class TripCard extends StatelessWidget {
  final String tripStatus;
  final bool isCompleted;
  final dynamic item;
  final int index;

  TripCard(
      {required this.tripStatus,
      required this.isCompleted,
      required this.item,
      required this.index});

  @override
  Widget build(BuildContext context) {
    String partname = item["partname"].toString().length > 11
        ? item["partname"].substring(0, 10)
        : item["partname"].substring(0, item["partname"].toString().length);
    print(partname);
    // print('item["partname"].toString().length ${item["partname"].toString().length}');
    // String partname = item["partname"].substring(0, 12)+"...";
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
        border: Border.all(
          color: Colors.grey, // Set border color
          width: 1.0, // Set border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.only(bottom: 1, top: 8, right: 5, left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ITEM ID ${item["ititemid"]}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8)
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                border: Border(
                  //top: BorderSide(width: 1.0, color: Colors.black),
                  bottom: BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              child: Divider(
                height: 0.0,
                color: Colors.transparent,
              ),
            ),
            Container(
                padding:
                    const EdgeInsets.only(bottom: 1, top: 8, right: 5, left: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () async {
                          MasterInventoryState v = new MasterInventoryState();
                          await v.getImageFromCamera(context, "DRIVER");
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional: for rounded borders
                          ),
                          child: Image.network(
                            "http://apps.tuluatas.com:8080/trucking/photo_items/${item["photo_item"]}",
                            width: 50.0, // Adjust the image width as needed
                            height: 100.0, // Adjust the image height as needed
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                  'Image not found'); // Placeholder text or widget
                            }, // Image fit
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(Icons.inventory),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '\Name: ${partname} \nVH Type: ${item["vhtid"]} \nMerk: ${item["merk"]} \nSize: ${item["itemsize"]}',
                                        textAlign: TextAlign.justify,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          )),
                    ),
                  ],
                )),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                border: Border(
                  //top: BorderSide(width: 1.0, color: Colors.black),
                  bottom: BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              child: Divider(
                height: 0.0,
                color: Colors.transparent,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.only(bottom: 1, top: 8, right: 5, left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Update Photo Item'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
