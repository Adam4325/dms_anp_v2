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

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      _lat = widget.initialLat!;
      _lon = widget.initialLon!;
    }
  }

  Future<void> _searchOSM() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _searching = true);
    try {
      final url = Uri.parse('${GlobalData.baseUrlOri}api/osm_address.jsp?query=${Uri.encodeComponent(q)}');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _results
          ..clear()
          ..addAll((decoded is List ? decoded : []).map((e) => (e is Map ? e : {}) as Map<String, dynamic>));
      } else {
        _results.clear();
      }
    } catch (_) {
      _results.clear();
    } finally {
      setState(() => _searching = false);
    }
  }

  void _selectResult(Map<String, dynamic> item) {
    final lat = double.tryParse(item['lat']?.toString() ?? '');
    final lon = double.tryParse(item['lon']?.toString() ?? '');
    final name = item['display_name'] ?? item['name'] ?? '';
    if (lat == null || lon == null) return;
    _lat = lat;
    _lon = lon;
    final marker = Marker(markerId: const MarkerId('selected'), position: LatLng(_lat, _lon), infoWindow: InfoWindow(title: name is String ? name : '$name'));
    setState(() {
      _marker = marker;
    });
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(_lat, _lon), 16));
  }

  void _getLonLat() {
    Navigator.pop(context, {'lat': _lat, 'lon': _lon});
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
            markers: _marker == null ? {} : {_marker!},
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
                        decoration: const InputDecoration(
                          hintText: 'Cari alamat/lokasi',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: _searching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
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
