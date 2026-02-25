import 'dart:convert';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewDetailApproved extends StatefulWidget {
  final String ponbr;
  const ViewDetailApproved({Key? key, required this.ponbr}) : super(key: key);
  @override
  State<ViewDetailApproved> createState() => _ViewDetailApprovedState();
}

class _ViewDetailApprovedState extends State<ViewDetailApproved> {
  List<dynamic> items = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final url = Uri.parse(GlobalData.baseUrl + "api/po/list_detail_po_approval.jsp?ponbr=${widget.ponbr}&method=list-view-approved");//
      final resp = await http.get(url, headers: {"Accept": "application/json"});
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          items = (data is List) ? data : [];
          loading = false;
        });
      } else {
        setState(() {
          error = "Server ${resp.statusCode}";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE6E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C69),
        foregroundColor: Colors.white,
        title: Text("PO ${widget.ponbr}"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.black87)))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final it = items[index] as Map<String, dynamic>;
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (it['PARTNAME'] ?? '').toString(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            _kv("Item ID", (it['ITDITEMID'] ?? '').toString()),
                            _kv("Merk", (it['MERK'] ?? '').toString()),
                            _kv("Type", (it['IDTYPE'] ?? '').toString()),
                            _kv("Access", (it['IDACCESS'] ?? '').toString()),
                            _kv("UOM", (it['UOMID'] ?? '').toString()),
                            _kv("Qty", (it['ITDQTY'] ?? '').toString()),
                            _kv("Unit Cost", (it['ITDUNITCOST'] ?? '').toString()),
                            _kv("Ext. Cost", (it['ITDEXTCOST'] ?? '').toString()),
                            _kv("Ext. After Disc", (it['ITDEXTCOSTAFTERDISCOUNT'] ?? '').toString()),
                            _kv("Real Harga", (it['REALHARGA'] ?? '').toString()),
                            _kv("Loc", (it['LOCID'] ?? '').toString()),
                            _kv("Status", (it['STATUS'] ?? '').toString()),
                            const SizedBox(height: 6),
                            _kv("PO Line", (it['POLINENBR'] ?? '').toString()),
                            _kv("PB Line", (it['PBLINENBR'] ?? '').toString()),
                            _kv("PB Nbr", (it['PBNBR'] ?? '').toString()),
                          ],
                        ),
                      ),
                    );
                  },
                )),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FixedColumnWidth(14),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(children: [
            Align(alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(color: Colors.black))),
            const Align(alignment: Alignment.center, child: Text(":", style: TextStyle(color: Colors.black))),
            Align(alignment: Alignment.centerRight, child: Text(value, style: const TextStyle(color: Colors.black))),
          ])
        ],
      ),
    );
  }
}
