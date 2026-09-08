import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewMapTransitDo extends StatefulWidget {
  final Map<String, dynamic> itemTransit;
  final bool isCsAdmin;

  const ViewMapTransitDo({
    Key? key,
    required this.itemTransit,
    this.isCsAdmin = false,
  }) : super(key: key);

  @override
  State<ViewMapTransitDo> createState() => _ViewMapTransitDoState();
}

class _ViewMapTransitDoState extends State<ViewMapTransitDo> {
  final Completer<GoogleMapController> _mapController = Completer();
  MapType _currentMapType = MapType.normal;

  double _lat = 0.0;
  double _lon = 0.0;
  bool _validCoordinates = false;

  // Non-Tera Soft Pastel Palette
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color cardColor = const Color(0xFFFFF8F0);

  @override
  void initState() {
    super.initState();
    _parseCoordinates();
  }

  void _parseCoordinates() {
    final latStr = (widget.itemTransit['lat'] ?? '').toString().trim();
    final lonStr = (widget.itemTransit['lon'] ?? '').toString().trim();
    final parsedLat = double.tryParse(latStr);
    final parsedLon = double.tryParse(lonStr);

    if (parsedLat != null && parsedLon != null && parsedLat != 0.0 && parsedLon != 0.0) {
      _lat = parsedLat;
      _lon = parsedLon;
      _validCoordinates = true;
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  Future<void> _centerCamera() async {
    if (!_validCoordinates) return;
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(_lat, _lon), zoom: 16),
      ),
    );
  }

  Future<void> _openExternalGoogleMaps() async {
    if (!_validCoordinates) return;
    final url = "https://www.google.com/maps/search/?api=1&query=$_lat,$_lon";
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error opening external maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final wonumber = widget.itemTransit['wonumber'] ?? '-';
    final namaPool = widget.itemTransit['nama_pool'] ?? '-';
    final drvid = widget.itemTransit['drvid'] ?? '-';
    final address = (widget.itemTransit['address'] ?? '').toString().trim();
    final isApproved = widget.itemTransit['is_approved']?.toString() == "1";

    final LatLng targetPos = _validCoordinates
        ? LatLng(_lat, _lon)
        : const LatLng(-6.181866, 106.829633);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        elevation: 1,
        title: Text(
          "Peta Transit DO: $wonumber",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: "Ganti Tipe Peta",
            icon: Icon(
              _currentMapType == MapType.normal ? Icons.satellite_alt : Icons.map,
              color: Colors.white,
            ),
            onPressed: _toggleMapType,
          ),
          if (_validCoordinates)
            IconButton(
              tooltip: "Pusatkan Lokasi",
              icon: const Icon(Icons.my_location, color: Colors.white),
              onPressed: _centerCamera,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map View
          if (_validCoordinates)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: targetPos,
                zoom: 16,
              ),
              mapType: _currentMapType,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              markers: {
                Marker(
                  markerId: MarkerId("transit_location_${widget.itemTransit['id'] ?? '0'}"),
                  position: targetPos,
                  infoWindow: InfoWindow(
                    title: namaPool.isNotEmpty ? namaPool : "Lokasi Transit DO",
                    snippet: "DO: $wonumber | Driver: $drvid",
                  ),
                ),
              },
              circles: {
                Circle(
                  circleId: const CircleId("geofence_transit_200m"),
                  center: targetPos,
                  radius: 200, // 200 meter radius geofence
                  strokeWidth: 2,
                  strokeColor: primaryOrange,
                  fillColor: primaryOrange.withOpacity(0.2),
                ),
              },
              onMapCreated: (controller) {
                if (!_mapController.isCompleted) {
                  _mapController.complete(controller);
                }
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      "Koordinat tidak valid atau belum tersedia",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Lat: ${widget.itemTransit['lat'] ?? '-'}, Lon: ${widget.itemTransit['lon'] ?? '-'}",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Bottom Info Sheet
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: accentOrange.withOpacity(0.4)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: DO & Status Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          wonumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? Colors.green.shade50
                              : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isApproved
                                ? Colors.green.shade400
                                : Colors.amber.shade600,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isApproved
                                  ? Icons.check_circle
                                  : Icons.hourglass_top,
                              size: 13,
                              color: isApproved
                                  ? Colors.green.shade700
                                  : Colors.amber.shade800,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isApproved ? "Disetujui" : "Menunggu Approval",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isApproved
                                    ? Colors.green.shade700
                                    : Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Detail: Pool & Driver
                  Row(
                    children: [
                      Icon(Icons.business, size: 16, color: primaryOrange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          namaPool.isNotEmpty ? namaPool : "Pool Transit",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      Text(
                        "Driver: $drvid",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Alamat Lengkap
                  if (address.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.place, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Koordinat & Geofence Radius
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Lat: ${_lat.toStringAsFixed(6)} | Lon: ${_lon.toStringAsFixed(6)}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: darkOrange,
                          ),
                        ),
                        Text(
                          "Radius: 200m",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: darkOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openExternalGoogleMaps,
                          icon: const Icon(Icons.navigation, size: 16),
                          label: const Text(
                            "Buka di Google Maps",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
