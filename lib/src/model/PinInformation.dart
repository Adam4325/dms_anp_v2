import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinInformation {
  final String pinPath;
  final String avatarPath;
  final LatLng location;
  final String locationName;
  final double acc;
  final double speed;
  final String no_do;
  final String gps_time;
  final String nopol;
  final String ket_status_do;
  final double lat;
  final double lon;
  final Color labelColor;

  PinInformation({
    this.pinPath = '',
    this.avatarPath = '',
    required this.location,
    this.locationName = '',
    required this.labelColor,
    this.nopol = '',
    this.gps_time = '',
    this.acc = 0,
    this.speed = 0,
    this.no_do = '',
    this.ket_status_do = '',
    this.lat = 0,
    this.lon = 0,
  });
}

class PinInformation2 {
  final String pinPath;
  final String avatarPath;
  final String addr;
  final double acc;
  final double speed;
  final String no_do;
  final String gps_time;
  final String nopol;
  final double lat;
  final double lon;
  final Color labelColor;

  PinInformation2({
    this.pinPath = '',
    this.avatarPath = '',
    this.addr = '',
    required this.labelColor,
    this.nopol = '',
    this.gps_time = '',
    this.acc = 0,
    this.speed = 0,
    this.no_do = '',
    this.lat = 0,
    this.lon = 0,
  });
}