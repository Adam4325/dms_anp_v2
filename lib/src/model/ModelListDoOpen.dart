//import 'package:tms/src/Service/date_utils.dart';
import 'package:intl/intl.dart';

class ModelListDoOpen {
  final String donumber;
  final String dlodonumber;
  final String itemUOM;
  final String customerName;
  final String origin;
  final String destination;

  const ModelListDoOpen({
    this.donumber = '',
    this.dlodonumber = '',
    this.itemUOM = '',
    this.customerName = '',
    this.origin = '',
    this.destination = '',
  });

  factory ModelListDoOpen.fromJson(Map<String, dynamic> json) {
    return ModelListDoOpen(
      donumber: json["donumber"]?.toString() ?? '',
      dlodonumber: json["dlodonumber"]?.toString() ?? '',
      itemUOM: json["itemUOM"]?.toString() ?? '',
      customerName: json["customerName"]?.toString() ?? '',
      origin: json["origin"]?.toString() ?? '',
      destination: json["destination"]?.toString() ?? '',
    );
  }
}