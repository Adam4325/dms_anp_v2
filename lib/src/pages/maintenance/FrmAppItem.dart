import 'dart:async';
import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FrmAppItem extends StatefulWidget {
  const FrmAppItem({Key? key}) : super(key: key);

  @override
  State<FrmAppItem> createState() => _FrmAppItemState();
}

class _FrmAppItemState extends State<FrmAppItem> {
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color darkOrange = Color(0xFFE65100);
  static const Color backgroundColor = Color(0xFFFFF8F0);

  final TextEditingController _txtSearch = TextEditingController();
  final TextEditingController _txtApproveNotes = TextEditingController();

  List<dynamic> _listWO = [];
  List<dynamic> _listDetailItems = [];
  bool _loading = false;
  String _username = '';
  String _userid = '';

  String get _apiUrl =>
      '${GlobalData.baseUrl}api/maintenance/sr/api_app_item.jsp';

  @override
  void initState() {
    super.initState();
    _loadSessionAndData();
  }

  @override
  void dispose() {
    _txtSearch.dispose();
    _txtApproveNotes.dispose();
    super.dispose();
  }

  Future<void> _loadSessionAndData() async {
    final prefs = await SharedPreferences.getInstance();
    _username = (prefs.getString('username') ?? '').toUpperCase();
    _userid = (prefs.getString('user_id') ?? _username).toUpperCase();

    if (!_hasAccess()) {
      if (mounted) {
        setState(() {});
        alert(context, 0, 'Akses ditolak. Khusus MT dan ADMIN.', 'error');
      }
      return;
    }

    _fetchListWO(isloading: true);
  }

  bool _hasAccess() {
    if (_username == 'ADMIN') return true;
    return globals.akses_pages.any((x) => x == 'MT' || x == 'ADMIN');
  }

  Future<void> _fetchListWO({bool isloading = false}) async {
    if (!_hasAccess()) return;
    if (isloading) EasyLoading.show(status: 'Memuat data...');
    setState(() => _loading = true);

    try {
      final search = _txtSearch.text.trim();
      final uri = Uri.parse(_apiUrl).replace(queryParameters: {
        'method': 'list',
        'search': search,
      });

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          setState(() {
            _listWO = decoded;
          });
        } else {
          setState(() => _listWO = []);
        }
      } else {
        alert(context, 0, 'Gagal memuat list WO (${response.statusCode})',
            'error');
      }
    } catch (e) {
      alert(context, 0, 'Gagal koneksi ke server: $e', 'error');
    } finally {
      setState(() => _loading = false);
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _fetchDetailItems(String wonumber) async {
    EasyLoading.show(status: 'Memuat detail item...');
    try {
      final uri = Uri.parse(_apiUrl).replace(queryParameters: {
        'method': 'list-detail',
        'wonumber': wonumber,
      });

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          setState(() {
            _listDetailItems = decoded;
          });
        } else {
          setState(() => _listDetailItems = []);
        }
      }
    } catch (e) {
      alert(context, 0, 'Gagal memuat detail item: $e', 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _updateDetailItem({
    required String detailId,
    required String itemId,
    required String statusItem,
    required String qty,
    required String wonumber,
  }) async {
    EasyLoading.show(status: 'Mengupdate item...');
    try {
      final uri = Uri.parse(_apiUrl);
      final response = await http.post(
        uri,
        body: {
          'method': 'update-detail',
          'id_detail': detailId,
          'item_id': itemId,
          'status_item': statusItem,
          'qty': qty,
          'userid': _userid,
        },
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        if (res['status_code'] == 200) {
          alert(context, 1, res['message'] ?? 'Berhasil update status item',
              'success');
          await _fetchDetailItems(wonumber);
        } else {
          alert(context, 0, res['message'] ?? 'Gagal update status item',
              'error');
        }
      }
    } catch (e) {
      alert(context, 0, 'Error update item: $e', 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _deleteDetailItem(String id, String wonumber) async {
    EasyLoading.show(status: 'Menghapus item...');
    try {
      final uri = Uri.parse(_apiUrl);
      final response = await http.post(
        uri,
        body: {
          'method': 'delete-detail',
          'id': id,
          'wonumber': wonumber,
          'userid': _userid,
        },
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        if (res['status_code'] == 200) {
          alert(context, 1, res['message'] ?? 'Berhasil menghapus item',
              'success');
          await _fetchDetailItems(wonumber);
        } else {
          alert(
              context, 0, res['message'] ?? 'Gagal menghapus item', 'error');
        }
      }
    } catch (e) {
      alert(context, 0, 'Error hapus item: $e', 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _approveWO(Map<String, dynamic> item) async {
    final srnumber = (item['srnumber'] ?? '').toString();
    final wonumber = (item['wodwonbr'] ?? '').toString();
    final vhcid = (item['vhcid'] ?? '').toString();
    final woprint = (item['woprint'] ?? '1').toString();
    final notes = _txtApproveNotes.text.trim();

    EasyLoading.show(status: 'Memproses approve...');
    try {
      final uri = Uri.parse(_apiUrl);
      final response = await http.post(
        uri,
        body: {
          'method': 'approve',
          'srnumber': srnumber,
          'wodnumber': wonumber,
          'vhcid': vhcid,
          'woprint': woprint,
          'wodnotes': notes,
          'userid': _userid,
        },
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        if (res['status_code'] == 200) {
          alert(context, 1, res['message'] ?? 'Berhasil approve WO', 'success');
          _txtApproveNotes.clear();
          await _fetchListWO(isloading: false);
        } else {
          alert(context, 0, res['message'] ?? 'Gagal approve WO', 'error');
        }
      }
    } catch (e) {
      alert(context, 0, 'Error approve WO: $e', 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  void _showApproveDialog(Map<String, dynamic> item) {
    _txtApproveNotes.clear();
    final srnumber = (item['srnumber'] ?? '').toString();
    final wonumber = (item['wodwonbr'] ?? '').toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Approve WO',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SR: $srnumber\nWO: $wonumber',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _txtApproveNotes,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Catatan Approval / Close',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _approveWO(item);
            },
            child: const Text('Approve & Selesai',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDetailDialog(
      Map<String, dynamic> itm, String wonumber, StateSetter setModalState) {
    final detailId = (itm['id_detail'] ?? itm['id'] ?? '').toString();
    final itemId = (itm['item_id'] ?? itm['itemid'] ?? '').toString();
    final currentQty = (itm['qty'] ?? '0').toString();
    String currentStatus = (itm['status_item'] ?? 'OK').toString();

    final txtQtyEdit = TextEditingController(text: currentQty);

    final statusOptions = [
      'OK',
      'Ganti',
      'Rusak',
      'Hilang',
      'Perbaikan',
      'REPLACE',
      'REPAIR',
      'REJECT',
    ];

    if (!statusOptions.contains(currentStatus) && currentStatus.isNotEmpty) {
      statusOptions.add(currentStatus);
    }

    showDialog(
      context: context,
      builder: (dialogCtx) {
        String selStatus = currentStatus;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Update Detail Item',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Part: ${itm['partname'] ?? '-'}\nSN: ${itm['genuineno'] ?? '-'}',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: txtQtyEdit,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'QTY',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selStatus,
                    decoration: InputDecoration(
                      labelText: 'Status Item',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    items: statusOptions
                        .map((val) => DropdownMenuItem(
                              value: val,
                              child: Text(val,
                                  style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selStatus = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    await _updateDetailItem(
                      detailId: detailId,
                      itemId: itemId,
                      statusItem: selStatus,
                      qty: txtQtyEdit.text.trim(),
                      wonumber: wonumber,
                    );
                    setModalState(() {});
                  },
                  child: const Text('Update',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(
      Map<String, dynamic> itm, String wonumber, StateSetter setModalState) {
    final id = (itm['id'] ?? itm['id_detail'] ?? '').toString();
    final partname = (itm['partname'] ?? '-').toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Hapus Item',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Yakin ingin menghapus item "$partname"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteDetailItem(id, wonumber);
              setModalState(() {});
            },
            child:
                const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDetailListModal(String wonumber) async {
    await _fetchDetailItems(wonumber);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.list_alt, color: darkOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'List Item WO: $wonumber',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: _listDetailItems.isEmpty
                      ? const Center(
                          child: Text('Tidak ada item pada WO ini',
                              style: TextStyle(color: Colors.black54)),
                        )
                      : ListView.separated(
                          itemCount: _listDetailItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final itm = _listDetailItems[idx];
                            final vhcid = (itm['vhcid'] ?? '-').toString();
                            final itemId = (itm['item_id'] ??
                                    itm['itemid'] ??
                                    '-')
                                .toString();
                            final partname =
                                (itm['partname'] ?? '-').toString();
                            final genuineno =
                                (itm['genuineno'] ?? '-').toString();
                            final merk = (itm['merk'] ?? '-').toString();
                            final idaccess =
                                (itm['idaccess'] ?? '-').toString();
                            final status =
                                (itm['status_item'] ?? 'OK').toString();
                            final qty = (itm['qty'] ?? '0').toString();

                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              color: const Color.fromRGBO(245, 246, 248, 1.0),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VHCID : $vhcid',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Divider(height: 12),
                                    _itemKv('ItemID', itemId),
                                    _itemKv('Partname', partname),
                                    _itemKv('Genuino', genuineno),
                                    _itemKv('Merk', merk),
                                    _itemKv('ID Access', idaccess),
                                    _itemKv('Status Item', status),
                                    _itemKv('QTY', qty),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        // Delete button
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.redAccent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            icon: const Icon(Icons.cancel,
                                                size: 16,
                                                color: Colors.white),
                                            label: const Text('Delete',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            onPressed: () =>
                                                _showDeleteConfirmDialog(
                                                    itm, wonumber, setModalState),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Edit button
                                        // Expanded(
                                        //   child: ElevatedButton.icon(
                                        //     style: ElevatedButton.styleFrom(
                                        //       backgroundColor:
                                        //           Colors.orangeAccent,
                                        //       padding:
                                        //           const EdgeInsets.symmetric(
                                        //               vertical: 8),
                                        //       shape: RoundedRectangleBorder(
                                        //         borderRadius:
                                        //             BorderRadius.circular(8),
                                        //       ),
                                        //     ),
                                        //     icon: const Icon(Icons.edit,
                                        //         size: 16,
                                        //         color: Colors.white),
                                        //     label: const Text('Edit',
                                        //         style: TextStyle(
                                        //             fontSize: 12,
                                        //             color: Colors.white,
                                        //             fontWeight:
                                        //                 FontWeight.bold)),
                                        //     onPressed: () =>
                                        //         _showEditDetailDialog(
                                        //             itm, wonumber, setModalState),
                                        //   ),
                                        // ),
                                        // const SizedBox(width: 8),
                                        // Close button
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                  color: Colors.grey.shade400),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(ctx),
                                            child: const Text('Close',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _itemKv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const Text(': ',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAccess()) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryOrange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
          ),
          title: const Text('Apv WO', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Akses Ditolak. Menu Apv WO hanya untuk role MT atau ADMIN.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.red),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
          ),
          title: const Text(
            'Apv WO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _txtSearch,
                  onSubmitted: (_) => _fetchListWO(isloading: true),
                  decoration: InputDecoration(
                    hintText: 'Cari Nopol / WO / SR Number...',
                    hintStyle: const TextStyle(fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    prefixIcon: const Icon(Icons.search, color: primaryOrange),
                    suffixIcon: _txtSearch.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _txtSearch.clear();
                              _fetchListWO(isloading: true);
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Content List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _fetchListWO(isloading: false),
                  color: primaryOrange,
                  child: _loading && _listWO.isEmpty
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: primaryOrange))
                      : _listWO.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 100),
                                Center(
                                  child: Text(
                                    'Tidak ada data Service Request untuk Apv WO.',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _listWO.length,
                              itemBuilder: (context, index) {
                                final item = _listWO[index];
                                return _buildWOCard(item);
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWOCard(dynamic item) {
    final srnumber = (item['srnumber'] ?? '-').toString();
    final wonumber = (item['wodwonbr'] ?? '-').toString();
    final vhcid = (item['vhcid'] ?? '-').toString();
    final drvname = (item['drvname'] ?? '-').toString();
    final srnotes = (item['srnotes'] ?? '-').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build_circle_outlined,
                    color: primaryOrange, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SR: $srnumber',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'PENDING APV',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            _infoRow('WO Number', wonumber),
            _infoRow('Vehicle ID', vhcid),
            _infoRow('Driver', drvname),
            if (srnotes.isNotEmpty && srnotes != '-')
              _infoRow('Notes', srnotes),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkOrange,
                      side: const BorderSide(color: darkOrange),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: const Text('Detail List',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showDetailListModal(wonumber),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Approve',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showApproveDialog(item),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const Text(': ',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
