import 'dart:convert';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class FrmKoordinat extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;
  const FrmKoordinat({Key? key, this.initialLat, this.initialLon}) : super(key: key);
  @override
  State<FrmKoordinat> createState() => _FrmKoordinatState();
}

class _FrmKoordinatState extends State<FrmKoordinat> {
  final TextEditingController _searchCtrl = TextEditingController();
  final List<Map<String, dynamic>> _results = [];
  bool _searching = false;
  GoogleMapController? _mapController;
  Marker? _marker;
  double _lat = -6.181866111111;
  double _lon = 106.829632777778;
  String _address = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      _lat = widget.initialLat!;
      _lon = widget.initialLon!;
    }
    _setMarker(LatLng(_lat, _lon), clearResults: false, moveCamera: false);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _setMarker(LatLng pos, {String? title, bool clearResults = true, bool moveCamera = false}) {
    _lat = pos.latitude;
    _lon = pos.longitude;
    final label = (title != null && title.isNotEmpty)
        ? title
        : (_address.isNotEmpty ? _address : 'Geser pin untuk sesuaikan');
    setState(() {
      _marker = Marker(
        markerId: const MarkerId('selected'),
        position: pos,
        draggable: true,
        infoWindow: InfoWindow(title: label),
        onDragEnd: _onMarkerDragEnd,
      );
      if (clearResults) _results.clear();
    });
    if (moveCamera) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 16));
    }
  }

  void _onMarkerDragEnd(LatLng newPos) {
    _lat = newPos.latitude;
    _lon = newPos.longitude;
    _address = '';
    setState(() {
      _marker = Marker(
        markerId: const MarkerId('selected'),
        position: newPos,
        draggable: true,
        infoWindow: InfoWindow(
          title: 'Lat ${_lat.toStringAsFixed(6)}, Lon ${_lon.toStringAsFixed(6)}',
        ),
        onDragEnd: _onMarkerDragEnd,
      );
    });
  }

  Future<List<Map<String, dynamic>>> _parseList(String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty || trimmed == '[]') return [];
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOsm(String q) async {
    try {
      final url = Uri.parse('${GlobalData.baseUrlOri}api/osm_address.jsp').replace(
        queryParameters: {'query': q},
      );
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        final list = await _parseList(response.body);
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}

    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search').replace(
        queryParameters: {
          'q': q,
          'format': 'json',
          'addressdetails': '0',
          'limit': '8',
          'countrycodes': 'id',
        },
      );
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "User-Agent": "DMS-ANP-MasterData/1.0 (Flutter; contact: admin@tuluatas.com)",
      });
      if (response.statusCode == 200) {
        return await _parseList(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _searchOSM() async {
    final q = _searchCtrl.text.trim();
    if (q.length < 2) return;
    setState(() => _searching = true);
    final list = await _fetchOsm(q);
    if (!mounted) return;
    setState(() {
      _results
        ..clear()
        ..addAll(list);
      _searching = false;
    });
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat tidak ditemukan. Coba kata kunci lain.')),
      );
    }
  }

  void _selectResult(Map<String, dynamic> item) {
    final lat = double.tryParse(item['lat']?.toString() ?? '');
    final lon = double.tryParse(item['lon']?.toString() ?? '');
    final name = item['display_name'] ?? item['name'] ?? '';
    if (lat == null || lon == null) return;
    _address = name is String ? name : '$name';
    if (_address.isNotEmpty) {
      _searchCtrl.text = _address;
    }
    _setMarker(LatLng(lat, lon), title: _address, moveCamera: true);
  }

  void _onMapTap(LatLng pos) {
    _address = '';
    _setMarker(pos, title: 'Lat ${pos.latitude.toStringAsFixed(6)}, Lon ${pos.longitude.toStringAsFixed(6)}');
  }

  void _getLonLat() {
    Navigator.pop(context, {
      'lat': _lat,
      'lon': _lon,
      'address': _address,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambil Koordinat')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(_lat, _lon), zoom: 12),
            onMapCreated: (c) => _mapController = c,
            onTap: _onMapTap,
            markers: _marker == null ? {} : {_marker!},
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchOSM(),
                        decoration: const InputDecoration(
                          hintText: 'Cari alamat/lokasi',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: _searching
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.search),
                      onPressed: _searching ? null : _searchOSM,
                    )
                  ],
                ),
              ),
            ),
          ),
          if (_results.isNotEmpty)
            Positioned(
              top: 70,
              left: 12,
              right: 12,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    itemBuilder: (context, i) {
                      final item = _results[i];
                      final name = item['display_name'] ?? item['name'] ?? '';
                      return ListTile(
                        dense: true,
                        title: Text(name is String ? name : '$name', maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => _selectResult(item),
                      );
                    },
                  ),
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 140,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lat: ${_lat.toStringAsFixed(6)}   Lon: ${_lon.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tahan & geser pin untuk sesuaikan koordinat',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 80,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: _getLonLat,
              child: const Text('Get Lon Lat', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
