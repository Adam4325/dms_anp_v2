import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/model/AduanItem.dart';
import 'package:dms_anp/src/services/AduanService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modul Aduan DMS ANP
/// Didesain ulang sesuai standar DMS ANP Visual Style Guide (form-redesign-template.md & design_tab.md)
/// Gaya Soft Orange Pastel (Non-Tera).
/// Mendukung lampiran foto opsional (Kamera / Galeri) dan preview gambar pada list aduan.
class AduanMainPage extends StatefulWidget {
  const AduanMainPage({Key? key}) : super(key: key);

  @override
  _AduanMainPageState createState() => _AduanMainPageState();
}

class _AduanMainPageState extends State<AduanMainPage>
    with SingleTickerProviderStateMixin {
  // Palet Warna Tema (Soft Orange Pastel) sesuai form-redesign-template.md & design_tab.md
  static const Color primaryOrange = Color(0xFFFF8C69); // #FF8C69
  static const Color lightOrange = Color(0xFFFFF4E6); // #FFF4E6
  static const Color accentOrange = Color(0xFFFFB347); // #FFB347
  static const Color darkOrange = Color(0xFFE07B39); // #E07B39
  static const Color backgroundColor = Color(0xFFFFFAF5); // #FFFAF5
  static const Color cardColor = Color(0xFFFFF8F0); // #FFF8F0
  static const Color shadowColor = Color(0x20FF8C69); // Soft shadow

  TabController? _tabController;
  final TextEditingController _pesanController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String? _imageBase64;

  List<AduanItem> _mine = [];
  List<AduanItem> _open = [];
  bool _loadingMine = false;
  bool _loadingOpen = false;

  String _username = '';
  String _loginname = '';
  String _statusK = '';
  String _drvid = '';
  String _kryid = '';

  bool _canSubmit = false;
  bool _canHandle = false;
  Set<String> _roleAksesNotifUsers = {};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    final username = p.getString('username') ?? '';
    final loginname = p.getString('loginname') ?? '';
    final statusK = (p.getString('status_karyawan') ?? '').trim().toUpperCase();
    final drvid = p.getString('drvid') ?? '';
    final kryid = p.getString('kryid') ?? '';
    final roleUsers = await AduanService.fetchRoleAksesNotifUsers();
    final canHandle = _isHandlerFromApiOrFallback(
      username: username,
      loginname: loginname,
      roleUsers: roleUsers,
    );

    final canSubmit = statusK == 'DRIVER' || statusK == 'KARYAWAN';

    int tabLength = 0;
    if (canSubmit) {
      tabLength = canHandle ? 3 : 2;
    } else if (canHandle) {
      tabLength = 1;
    }

    setState(() {
      _username = username;
      _loginname = loginname;
      _statusK = statusK;
      _drvid = drvid;
      _kryid = kryid;
      _roleAksesNotifUsers = roleUsers;
      _canSubmit = canSubmit;
      _canHandle = canHandle;

      _tabController?.dispose();
      _tabController = null;
      if (tabLength > 1) {
        _tabController = TabController(length: tabLength, vsync: this);
      }
    });

    if (_canSubmit) {
      _refreshMine();
    }
    if (_canHandle && _roleAksesNotifUsers.isNotEmpty) {
      _refreshOpen();
    }
  }

  bool _isHandlerFromApiOrFallback({
    required String username,
    required String loginname,
    required Set<String> roleUsers,
  }) {
    if (roleUsers.isEmpty) {
      return false;
    }

    final u = username.trim().toUpperCase();
    if (u.isEmpty) {
      return false;
    }

    const localAllow = {'ADMIN', 'ETIENNE', 'BUDI', 'GUTINI', 'MAJID'};
    if (localAllow.contains(u) || loginname.trim().toUpperCase() == 'ADMIN') {
      return true;
    }

    return roleUsers.contains(u);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  // ==========================================
  // IMAGE PICKER LOGIC (KAMERA / GALERI)
  // ==========================================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 60,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        setState(() {
          _imageFile = file;
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      _showSnackBar('Gagal mengambil gambar: $e', isError: true);
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lampirkan Foto / Bukti Aduan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pilih sumber foto bukti aduan dari Kamera atau Galeri (Opsional)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.white),
                        label: ntBtnLabel('Kamera'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.camera);
                        },
                        style: ntBtnStyle(primaryOrange),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library_outlined, size: 20, color: Colors.white),
                        label: ntBtnLabel('Galeri'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.gallery);
                        },
                        style: ntBtnStyle(accentOrange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _imageBase64 = null;
    });
  }

  // ==========================================
  // DATA REFRESH & ACTIONS
  // ==========================================

  Future<void> _refreshMine() async {
    if (!_canSubmit) return;
    setState(() => _loadingMine = true);
    try {
      final list = await AduanService.listMine(
        username: _username,
        statusKaryawan: _statusK,
        drvid: _drvid,
        kryid: _kryid,
      );
      if (mounted) {
        setState(() {
          _mine = list;
          _loadingMine = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingMine = false);
      }
    }
  }

  Future<void> _refreshOpen() async {
    if (!_canHandle) return;
    setState(() => _loadingOpen = true);
    try {
      final list = await AduanService.listOpen(_username);
      if (mounted) {
        setState(() {
          _open = list;
          _loadingOpen = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingOpen = false);
        _showSnackBar('Gagal memuat aduan terbuka: $e', isError: true);
      }
    }
  }

  Future<void> _submit() async {
    final text = _pesanController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Catatan aduan wajib diisi terlebih dahulu', isError: true);
      return;
    }
    if (text.length > 150) {
      _showSnackBar('Maksimal 150 karakter', isError: true);
      return;
    }

    EasyLoading.show(status: 'Mengirim...');
    String? err;
    try {
      err = await AduanService.create(
        username: _username,
        statusKaryawan: _statusK,
        drvid: _drvid,
        kryid: _kryid,
        loginname: _loginname,
        pesan: text,
        fotoBase64: _imageBase64,
      );
    } catch (e) {
      err = 'Terjadi kesalahan: $e';
    } finally {
      EasyLoading.dismiss();
    }

    if (!mounted) return;

    if (err != null) {
      _showSnackBar(err, isError: true);
      return;
    }

    _pesanController.clear();
    _removeImage();
    FocusScope.of(context).unfocus();
    _showSnackBar('Aduan Anda berhasil dikirim!', isError: false);

    // Refresh daftar riwayat
    await _refreshMine();

    // Auto-switch ke tab Riwayat jika ada tab controller
    if (_tabController != null && _tabController!.length >= 2) {
      _tabController!.animateTo(1);
    }
  }

  Future<void> _confirmSubmit() async {
    final text = _pesanController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Catatan aduan wajib diisi terlebih dahulu', isError: true);
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => ntAlertDialog(
        title: 'Konfirmasi Pengiriman Aduan',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: primaryOrange, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pastikan aduan disampaikan sesuai fakta operasional. Informasi yang tidak benar dapat dikenakan sanksi sesuai ketentuan perusahaan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x73FFB347)),
              ),
              child: Text(
                '"$text"',
                style: TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade900,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_imageFile != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.image_outlined,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Foto bukti terlampir',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(c, false),
            style: ntBtnStyle(Colors.grey.shade400),
            child: ntBtnLabel('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ntBtnStyle(primaryOrange),
            child: ntBtnLabel('Ya, Kirim'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _submit();
    }
  }

  Future<void> _confirmClose(AduanItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => ntAlertDialog(
        title: 'Tutup Aduan #${item.id}',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tutup dan selesaikan pengaduan ini? Aduan yang ditutup akan disembunyikan dari daftar terbuka.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${item.pesan}"',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade900,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(c, false),
            style: ntBtnStyle(Colors.grey.shade400),
            child: ntBtnLabel('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ntBtnStyle(Colors.green.shade600),
            child: ntBtnLabel('Tutup Aduan'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    EasyLoading.show(status: 'Menutup...');
    final err = await AduanService.close(username: _username, id: item.id);
    EasyLoading.dismiss();

    if (!mounted) return;

    if (err != null) {
      _showSnackBar(err, isError: true);
      return;
    }

    _showSnackBar('Aduan #${item.id} berhasil ditutup', isError: false);
    _refreshOpen();
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPhotoDialog(BuildContext ctx, String photoUrl) {
    showDialog(
      context: ctx,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.photo_outlined, color: primaryOrange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Foto Bukti Aduan',
                          style: TextStyle(
                            color: darkOrange,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 250,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(color: primaryOrange),
                          );
                        },
                        errorBuilder: (ctx, err, stack) {
                          return Container(
                            height: 200,
                            color: Colors.grey.shade100,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_outlined,
                                    size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'Gagal memuat gambar',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () => Navigator.pop(c),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER STYLES & WIDGETS DARI TEMPLATE MD
  // ==========================================

  InputDecoration softDecoration({
    String? label,
    String? hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primaryOrange, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.grey.shade800,
      ),
    );
  }

  ButtonStyle ntBtnStyle(Color bg) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    );
  }

  Widget ntBtnLabel(String text, {double size = 13}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: size,
      ),
    );
  }

  AlertDialog ntAlertDialog({
    required String title,
    required Widget content,
    List<Widget> actions = const <Widget>[],
  }) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: cardColor,
      titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      title: Text(
        title,
        style: const TextStyle(
          color: darkOrange,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      content: content,
      actions: actions,
    );
  }

  Widget _ntListCard({
    required String title,
    Widget? trailing,
    required List<Widget> rows,
    Widget? actions,
    bool compact = false,
  }) {
    final m = compact ? 8.0 : 12.0;
    final v = compact ? 4.0 : 6.0;
    final r = compact ? 10.0 : 14.0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: m, vertical: v),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: const Color(0x73FFB347)),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: compact
                ? const EdgeInsets.fromLTRB(12, 8, 12, 8)
                : const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(r),
                topRight: Radius.circular(r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 13 : 14,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(
            padding: compact
                ? const EdgeInsets.fromLTRB(12, 8, 12, 8)
                : const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          if (actions != null)
            Padding(
              padding: compact
                  ? const EdgeInsets.fromLTRB(10, 2, 10, 10)
                  : const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: actions,
            ),
        ],
      ),
    );
  }

  Widget _kv(
    String label,
    String value, {
    bool dense = false,
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 1.5 : 2.5),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FixedColumnWidth(14),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: dense ? 11.5 : 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                ":",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: dense ? 11.5 : 12.5,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: valueColor ?? Colors.grey.shade900,
                  fontSize: dense ? 11.5 : 12.5,
                  fontWeight: valueWeight ?? FontWeight.w600,
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusBg = lightOrange;
    Color statusText = darkOrange;
    Color statusBorder = accentOrange;

    final s = status.toUpperCase();
    if (s == 'APPROVED' || s == 'SELESAI' || s == 'CLOSED' || s == 'CLOSE') {
      statusBg = Colors.green.shade50;
      statusText = Colors.green.shade800;
      statusBorder = Colors.green.shade200;
    } else if (s == 'CANCEL' || s == 'REJECTED' || s == 'BATAL') {
      statusBg = Colors.red.shade50;
      statusText = Colors.red.shade800;
      statusBorder = Colors.red.shade200;
    } else if (s == 'OPEN' || s == 'PENDING') {
      statusBg = const Color(0xFFFFF8E7);
      statusText = const Color(0xFFB78103);
      statusBorder = const Color(0xFFFFD54F);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusBorder),
      ),
      child: Text(
        s.isEmpty ? 'OPEN' : s,
        style: TextStyle(
          color: statusText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ==========================================
  // FOTO PREVIEW WIDGET FOR LIST CARDS
  // ==========================================

  Widget _buildFotoCardWidget(String? foto) {
    if (foto == null || foto.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final rawFoto = foto.trim();
    final fullUrl = rawFoto.startsWith('http://') || rawFoto.startsWith('https://')
        ? rawFoto
        : '${GlobalData.baseUrlOri}${rawFoto.startsWith('/') ? rawFoto.substring(1) : rawFoto}';

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x73FFB347)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showPhotoDialog(context, fullUrl),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.network(
                    fullUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: lightOrange,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: primaryOrange),
                        ),
                      );
                    },
                    errorBuilder: (ctx, err, stack) {
                      return Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: Icon(Icons.broken_image_outlined, size: 24, color: Colors.grey.shade500),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.photo_library_outlined, size: 15, color: darkOrange),
                        SizedBox(width: 5),
                        Text(
                          'Foto Bukti Aduan',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ketuk untuk melihat foto ukuran penuh',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.zoom_in_rounded, color: primaryOrange, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // USER PROFILE INFO CARD
  // ==========================================

  Widget _buildUserProfileCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x59FFB347)),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: lightOrange,
            child: const Icon(Icons.person_rounded,
                color: primaryOrange, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username.isNotEmpty ? _username : _loginname,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: lightOrange,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0x73FFB347)),
                      ),
                      child: Text(
                        _statusK.isNotEmpty ? _statusK : 'USER',
                        style: const TextStyle(
                          color: darkOrange,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_drvid.isNotEmpty || _kryid.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        'ID: ${_drvid.isNotEmpty ? _drvid : _kryid}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: FORM PENGADUAN
  // ==========================================

  Widget _buildFormTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildUserProfileCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x59FFB347)),
                boxShadow: const [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.edit_note_outlined,
                            color: primaryOrange, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Formulir Pengaduan Driver',
                          style: TextStyle(
                            color: darkOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Form Body
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Disclaimer / Informasi Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  color: Color(0xFFF57C00), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Sampaikan aspirasi, keluhan, atau kendala operasional Anda secara jelas dan faktual.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.brown.shade800,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Label
                        _label('Isi Aduan / Kendala (Wajib) *'),
                        const SizedBox(height: 8),

                        // Text Field Aduan
                        TextField(
                          controller: _pesanController,
                          maxLines: 5,
                          maxLength: 150,
                          cursorColor: primaryOrange,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Colors.black87,
                          ),
                          decoration: softDecoration(
                            hint:
                                'Tuliskan rincian keluhan, kendala rute/kendaraan, atau permohonan Anda (maks. 150 karakter)...',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 50),
                              child: Icon(Icons.chat_bubble_outline_rounded,
                                  color: primaryOrange, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Section Lampiran Foto (Opsional)
                        _label('Foto Bukti / Dokumen (Opsional)'),
                        const SizedBox(height: 8),

                        if (_imageFile == null)
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _showImagePickerSheet,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: lightOrange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.add_a_photo_outlined,
                                        color: primaryOrange, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Unggah Foto / Gambar',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Kamera atau Galeri (Tidak wajib)',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14, color: Colors.grey),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _imageFile!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded,
                                              size: 16, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Foto Terlampir',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Foto siap dikirim bersama aduan',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: _showImagePickerSheet,
                                            child: const Text(
                                              'Ganti Foto',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: primaryOrange,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          InkWell(
                                            onTap: _removeImage,
                                            child: Text(
                                              'Hapus',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Tombol Kirim Aduan
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _confirmSubmit,
                            icon: const Icon(Icons.send_rounded,
                                size: 18, color: Colors.white),
                            label: ntBtnLabel('Kirim Aduan', size: 14),
                            style: ntBtnStyle(primaryOrange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: RIWAYAT ADUAN SAYA
  // ==========================================

  Widget _buildMineTab() {
    if (_loadingMine) {
      return const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      );
    }

    if (_mine.isEmpty) {
      return RefreshIndicator(
        color: primaryOrange,
        onRefresh: _refreshMine,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: lightOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x73FFB347)),
                    ),
                    child: const Icon(Icons.mark_email_read_outlined,
                        size: 36, color: accentOrange),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum Ada Riwayat Aduan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aduan yang Anda sampaikan akan tercatat di sini dan dipantau oleh tim terkait.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: primaryOrange,
      onRefresh: _refreshMine,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        itemCount: _mine.length,
        itemBuilder: (context, index) {
          final item = _mine[index];
          return _ntListCard(
            title: 'Aduan #${item.id}',
            trailing: _buildStatusBadge(item.status),
            rows: [
              // Quote-style Bubble untuk Pesan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x40FFB347)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        size: 20, color: accentOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.pesan,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tampilan Foto Bukti jika ada
              _buildFotoCardWidget(item.foto),

              const SizedBox(height: 4),
              _kv('Tanggal Pengajuan', item.createdAt ?? '-'),
              if (item.closedAt != null && item.closedAt!.isNotEmpty)
                _kv('Tanggal Selesai', item.closedAt!),
              if (item.closedByUsername != null &&
                  item.closedByUsername!.isNotEmpty)
                _kv('Ditangani Oleh', item.closedByUsername!),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 3: TINJAU STAFF (HR/HD/ADMIN)
  // ==========================================

  Widget _buildStaffPanel() {
    if (!_canHandle) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Akses Tinjau tidak tersedia untuk akun ini',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    if (_loadingOpen) {
      return const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      );
    }

    if (_open.isEmpty) {
      return RefreshIndicator(
        color: primaryOrange,
        onRefresh: _refreshOpen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Icon(Icons.task_alt_rounded,
                        size: 36, color: Colors.green.shade600),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak Ada Aduan Terbuka',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Semua aduan dari driver dan karyawan telah ditindaklanjuti.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: primaryOrange,
      onRefresh: _refreshOpen,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        itemCount: _open.length,
        itemBuilder: (c, i) {
          final item = _open[i];
          final isDriver = (item.submitterDrvId != null &&
                  item.submitterDrvId!.trim().isNotEmpty) ||
              (item.submitterLoginname != null &&
                  item.submitterLoginname!.toUpperCase() == 'DRIVER');

          // Pengirim: khusus driver, harus nama driver ambil field DRVNAME dari TBLDRIVER
          final String namaPengirim = (isDriver &&
                  item.drvname != null &&
                  item.drvname!.trim().isNotEmpty)
              ? item.drvname!.trim()
              : (item.submitterUsername.isNotEmpty ? item.submitterUsername : '-');

          final idInfo = item.submitterDrvId ?? item.submitterKryId ?? '-';

          return _ntListCard(
            title: 'Aduan #${item.id}',
            trailing: _buildStatusBadge(item.status),
            rows: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x40FFB347)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        size: 20, color: accentOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.pesan,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tampilan Foto Bukti jika ada
              _buildFotoCardWidget(item.foto),

              const SizedBox(height: 4),
              _kv('Pengirim', namaPengirim),
              _kv('ID Pengirim', idInfo),
              _kv('Waktu Pengajuan', item.createdAt ?? '-'),
            ],
            actions: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline,
                    size: 18, color: Colors.white),
                label: ntBtnLabel('Tutup & Selesaikan Aduan'),
                onPressed: () => _confirmClose(item),
                style: ntBtnStyle(Colors.green.shade600),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // BUILD UTAMA
  // ==========================================

  @override
  Widget build(BuildContext context) {
    if (!_canSubmit && !_canHandle) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Layanan Aduan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Anda tidak memiliki akses ke modul Aduan.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
        ),
      );
    }

    // Jika bisa kirim dan handle (Admin/HR/HD yang juga Driver/Karyawan) -> 3 Tab
    if (_canSubmit && _canHandle && _tabController != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Layanan Aduan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
            tabs: const [
              Tab(
                  icon: Icon(Icons.edit_note_outlined, size: 20),
                  text: 'Form Aduan'),
              Tab(
                  icon: Icon(Icons.history_rounded, size: 20),
                  text: 'Aduan Saya'),
              Tab(
                  icon: Icon(Icons.admin_panel_settings_outlined, size: 20),
                  text: 'Tinjau Staff'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFormTab(),
            _buildMineTab(),
            _buildStaffPanel(),
          ],
        ),
      );
    }

    // Jika canSubmit standar (DRIVER atau KARYAWAN biasa) -> 2 Tab (Form Input & Riwayat)
    if (_canSubmit && _tabController != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Layanan Aduan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(
                  icon: Icon(Icons.edit_note_outlined, size: 20),
                  text: 'Form Aduan'),
              Tab(
                  icon: Icon(Icons.history_rounded, size: 20),
                  text: 'Aduan Saya'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFormTab(),
            _buildMineTab(),
          ],
        ),
      );
    }

    // Jika hanya bisa handle staff review (tanpa submit)
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tinjau Aduan (Staff)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshOpen,
          ),
        ],
      ),
      body: _buildStaffPanel(),
    );
  }
}
