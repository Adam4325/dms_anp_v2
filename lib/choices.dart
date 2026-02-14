import 'package:json_annotation/json_annotation.dart';
import 'package:awesome_select/awesome_select.dart' show S2Choice;

class VehicleModel {
  final String value;
  final String title;

  VehicleModel({required this.value, required this.title});
  // factory VehicleModel.fromJson(Map<String, dynamic> json) => _$VehicleModelFromJson(json);
  // Map<String, dynamic> toJson() => _$VehicleModelToJson(this);
  factory VehicleModel.fromJson(Map<String, dynamic> vehiclejson) =>
      VehicleModel(
        value: vehiclejson["value"]?.toString() ?? '',
        title: vehiclejson["title"]?.toString() ?? '',
      );
}

class VehicleTypeMode {
  final String value;
  final String title;

  VehicleTypeMode({required this.value, required this.title});

  factory VehicleTypeMode.fromJson(Map<String, dynamic> json) => VehicleTypeMode(
        value: json['value']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'value': value,
      'title': title,
    };
  }
}

List<S2Choice<String>> days = [
  S2Choice<String>(value: 'mon', title: 'Monday'),
  S2Choice<String>(value: 'tue', title: 'Tuesday'),
  S2Choice<String>(value: 'wed', title: 'Wednesday'),
  S2Choice<String>(value: 'thu', title: 'Thursday'),
  S2Choice<String>(value: 'fri', title: 'Friday'),
  S2Choice<String>(value: 'sat', title: 'Saturday'),
  S2Choice<String>(value: 'sun', title: 'Sunday'),
];

List<S2Choice<String>> months = [
  S2Choice<String>(value: 'jan', title: 'January'),
  S2Choice<String>(value: 'feb', title: 'February'),
  S2Choice<String>(value: 'mar', title: 'March'),
  S2Choice<String>(value: 'apr', title: 'April'),
  S2Choice<String>(value: 'may', title: 'May'),
  S2Choice<String>(value: 'jun', title: 'June'),
  S2Choice<String>(value: 'jul', title: 'July'),
  S2Choice<String>(value: 'aug', title: 'August'),
  S2Choice<String>(value: 'sep', title: 'September'),
  S2Choice<String>(value: 'oct', title: 'October'),
  S2Choice<String>(value: 'nov', title: 'November'),
  S2Choice<String>(value: 'dec', title: 'December'),
];

List<S2Choice<String>> os = [
  S2Choice<String>(value: 'and', title: 'Android'),
  S2Choice<String>(value: 'ios', title: 'IOS'),
  S2Choice<String>(value: 'mac', title: 'Macintos'),
  S2Choice<String>(value: 'tux', title: 'Linux'),
  S2Choice<String>(value: 'win', title: 'Windows'),
];

List<S2Choice<String>> heroes = [
  S2Choice<String>(value: 'bat', title: 'Batman'),
  S2Choice<String>(value: 'sup', title: 'Superman'),
  S2Choice<String>(value: 'hul', title: 'Hulk'),
  S2Choice<String>(value: 'spi', title: 'Spiderman'),
  S2Choice<String>(value: 'iro', title: 'Ironman'),
  S2Choice<String>(value: 'won', title: 'Wonder Woman'),
];

List<S2Choice<String>> fruits = [
  S2Choice<String>(value: 'app', title: 'Apple'),
  S2Choice<String>(value: 'ore', title: 'Orange'),
  S2Choice<String>(value: 'mel', title: 'Melon'),
];

List<S2Choice<String>> collBanLT = [
  S2Choice<String>(value: '1', title: 'POSITION BAN 1'),
  S2Choice<String>(value: '2', title: 'POSITION BAN 2'),
  S2Choice<String>(value: '3', title: 'POSITION BAN 3'),
  S2Choice<String>(value: '4', title: 'POSITION BAN 4'),
  S2Choice<String>(value: '5', title: 'POSITION BAN 5'),
  S2Choice<String>(value: '6', title: 'POSITION BAN 6'),
  S2Choice<String>(value: '7', title: 'POSITION BAN 7'),
];

List<S2Choice<String>> listServerName = [
  S2Choice<String>(value: 'default', title: 'Default'),
  S2Choice<String>(value: 'mirroring', title: 'Mirroring')
  ];

List<S2Choice<String>> listInventoryTrxType = [
  S2Choice<String>(value: 'IS-M', title: 'Pengeluaran barang ke Mekanik (IS-M)'),
  S2Choice<String>(value: 'IS-P', title: 'Retur Barang ke Purchasing (IS-P)'),
  S2Choice<String>(value: 'IS-W', title: 'Pengeluaran barang ke gudang lain (IS-W)'),
  S2Choice<String>(value: 'IS-B', title: 'Pengeluaran barang ke Body Repaire (IS-B)'),
  S2Choice<String>(value: 'IS-C', title: 'Pengeluaran barang ke Customer (IS-C)'),
  S2Choice<String>(value: 'IR-M', title: 'Pengembalian Barang dari Mekanik (Tidak Jadi dipakai)(IR-M)'),
  S2Choice<String>(value: 'IS-S', title: 'Pengeluaran Solar (IS-S)'),
  S2Choice<String>(value: 'IR-S', title: 'Penerimaan Solar (IR-S)'),
  S2Choice<String>(value: 'IR-P', title: 'Penerimaan Barang dari Pembelian (IR-P)'),
  S2Choice<String>(value: 'IR-W', title: 'Penerimaan Barang dari Gudang (IR-W)'),
  S2Choice<String>(value: 'IS-T', title: 'Pegeluaran Ban Ke Gudang Lain (Transfer) (IS-T)')
];

List<S2Choice<String>> collFitPost = [
  S2Choice<String>(value: 'A1', title: 'A1 - Depan Kiri'),
  S2Choice<String>(value: 'A2', title: 'A2 - Depan Kanan'),
  S2Choice<String>(value: 'B1', title: 'B1 - Tengah Belakang Kabin Kiri Luar'),
  S2Choice<String>(value: 'B2', title: 'B2 - Tengah Belakang Kabin Kiri Dalam'),
  S2Choice<String>(value: 'B3', title: 'B3 - Tengah Belakang Kabin Kiri Luar'),
  S2Choice<String>(value: 'B4', title: 'B4 - Tengah Belakang Kabin Kiri Dalam'),
  S2Choice<String>(value: 'C1', title: 'C1 - Belakang Kiri Luar'),
  S2Choice<String>(value: 'C2', title: 'C2 - Belakang Kiri Dalam'),
  S2Choice<String>(value: 'C3', title: 'C3 - Belakang Kanan Luar'),
  S2Choice<String>(value: 'C4', title: 'C4 - Belakang Kanan Dalam'),
  S2Choice<String>(value: 'D1', title: 'D1 - Belakang Kiri Luar'),
  S2Choice<String>(value: 'D2', title: 'D2 - Belakang Kiri Dalam'),
  S2Choice<String>(value: 'D3', title: 'D3 - Belakang Kanan Luar'),
  S2Choice<String>(value: 'D4', title: 'D4 - Belakang Kanan Dalam'),
  S2Choice<String>(value: 'E1', title: 'E1 - Belakang TRLR Kiri Luar'),
  S2Choice<String>(value: 'E2', title: 'E2 - Belakang TRLR Kiri Dalam'),
  S2Choice<String>(value: 'E3', title: 'E3 - Belakang TRLR Kanan Luar'),
  S2Choice<String>(value: 'E4', title: 'E4 - Belakang TRLR Kanan Dalam'),
  S2Choice<String>(value: 'F1', title: 'F1 - Belakang TRLR Kiri Luar'),
  S2Choice<String>(value: 'F2', title: 'F2 - Belakang TRLR Kiri Dalam'),
  S2Choice<String>(value: 'F3', title: 'F3 - Belakang TRLR Kanan Luar'),
  S2Choice<String>(value: 'F4', title: 'F4 - Belakang TRLR Kanan Dalam'),
  S2Choice<String>(value: 'S1', title: 'S1 - Stip'),
  S2Choice<String>(value: 'S2', title: 'S2 - Stip'),
];

List<S2Choice<String>> collStatusItemOpname = [
  S2Choice<String>(value: 'Ganti', title: 'Ganti Baru'),
  S2Choice<String>(value: 'Rusak', title: 'Rusak'),
  S2Choice<String>(value: 'Hilang', title: 'Hilang'),
  S2Choice<String>(value: 'Perbaikan', title: 'Perbaikan'),
];

List<S2Choice<String>> collEstimasi = [
  S2Choice<String>(value: '0', title: '0 hari'),
  S2Choice<String>(value: '1', title: '1 hari'),
  S2Choice<String>(value: '2', title: '2 hari'),
  S2Choice<String>(value: '3', title: '3 hari'),
  S2Choice<String>(value: '4', title: '4 hari'),
  S2Choice<String>(value: '5', title: '5 hari'),
  S2Choice<String>(value: '6', title: '6 hari'),
  S2Choice<String>(value: '7', title: '7 hari'),
  S2Choice<String>(value: '8', title: '8 hari'),
  S2Choice<String>(value: '9', title: '9 hari'),
  S2Choice<String>(value: '10', title: '10 hari'),
  S2Choice<String>(value: '11', title: '11 hari'),
  S2Choice<String>(value: '12', title: '12 hari'),
  S2Choice<String>(value: '13', title: '13 hari'),
  S2Choice<String>(value: '14', title: '14 hari'),
  S2Choice<String>(value: '15', title: '15 hari'),
  S2Choice<String>(value: '16', title: '16 hari'),
  S2Choice<String>(value: '17', title: '17 hari'),
  S2Choice<String>(value: '18', title: '18 hari'),
  S2Choice<String>(value: '19', title: '19 hari'),
  S2Choice<String>(value: '20', title: '20 hari'),
  S2Choice<String>(value: '21', title: '21 hari'),
  S2Choice<String>(value: '22', title: '22 hari'),
  S2Choice<String>(value: '23', title: '23 hari'),
  S2Choice<String>(value: '24', title: '24 hari'),
  S2Choice<String>(value: '25', title: '25 hari'),
  S2Choice<String>(value: '26', title: '26 hari'),
  S2Choice<String>(value: '27', title: '27 hari'),
  S2Choice<String>(value: '28', title: '28 hari'),
  S2Choice<String>(value: '29', title: '29 hari'),
  S2Choice<String>(value: '30', title: '30 hari'),
];

List<S2Choice<String>> collBanTR = [
  S2Choice<String>(value: '1', title: 'POSITION BAN 1'),
  S2Choice<String>(value: '2', title: 'POSITION BAN 2'),
  S2Choice<String>(value: '3', title: 'POSITION BAN 3'),
  S2Choice<String>(value: '4', title: 'POSITION BAN 4'),
  S2Choice<String>(value: '5', title: 'POSITION BAN 5'),
  S2Choice<String>(value: '6', title: 'POSITION BAN 6'),
  S2Choice<String>(value: '7', title: 'POSITION BAN 7'),
  S2Choice<String>(value: '8', title: 'POSITION BAN 8'),
  S2Choice<String>(value: '9', title: 'POSITION BAN 9'),
  S2Choice<String>(value: '10', title: 'POSITION BAN 10'),
  S2Choice<String>(value: '11', title: 'POSITION BAN 11')
];

List<S2Choice<String>> collBanTRAILLER = [
  S2Choice<String>(value: '1', title: 'POSITION BAN 1'),
  S2Choice<String>(value: '2', title: 'POSITION BAN 2'),
  S2Choice<String>(value: '3', title: 'POSITION BAN 3'),
  S2Choice<String>(value: '4', title: 'POSITION BAN 4'),
  S2Choice<String>(value: '5', title: 'POSITION BAN 5'),
  S2Choice<String>(value: '6', title: 'POSITION BAN 6'),
  S2Choice<String>(value: '7', title: 'POSITION BAN 7'),
  S2Choice<String>(value: '8', title: 'POSITION BAN 8'),
  S2Choice<String>(value: '9', title: 'POSITION BAN 9'),
  S2Choice<String>(value: '10', title: 'POSITION BAN 10'),
  S2Choice<String>(value: '11', title: 'POSITION BAN 11'),
  S2Choice<String>(value: '12', title: 'POSITION BAN 12'),
  S2Choice<String>(value: '13', title: 'POSITION BAN 13'),
  S2Choice<String>(value: '14', title: 'POSITION BAN 14'),
  S2Choice<String>(value: '15', title: 'POSITION BAN 15'),
  S2Choice<String>(value: '16', title: 'POSITION BAN 16'),
  S2Choice<String>(value: '17', title: 'POSITION BAN 17'),
  S2Choice<String>(value: '18', title: 'POSITION BAN 18'),
  S2Choice<String>(value: '19', title: 'POSITION BAN 19'),
  S2Choice<String>(value: '20', title: 'POSITION BAN 20'),
  S2Choice<String>(value: '21', title: 'POSITION BAN 21'),
  S2Choice<String>(value: '22', title: 'POSITION BAN 22'),
  S2Choice<String>(value: '23', title: 'POSITION BAN 23'),
  S2Choice<String>(value: '24', title: 'POSITION BAN 24'),
];

List<S2Choice<String>> frameworks = [
  S2Choice<String>(value: 'ion', title: 'Ionic'),
  S2Choice<String>(value: 'flu', title: 'Flutter'),
  S2Choice<String>(value: 'rea', title: 'React Native'),
];

List<S2Choice<String>> jenisKelamin = [
  S2Choice<String>(value: 'MALE', title: 'MALE'),
  S2Choice<String>(value: 'FEMALE', title: 'FEMALE'),
];

List<S2Choice<String>> cStartStop = [
  S2Choice<String>(value: 'start', title: 'START'),
  S2Choice<String>(value: 'stop', title: 'STOP'),
];

List<S2Choice<String>> currencyID = [
  S2Choice<String>(value: 'IDR', title: 'IDR'),
  S2Choice<String>(value: 'USD', title: 'USD'),
];

List<S2Choice<String>> listTypePO = [
  S2Choice<String>(value: 'STOCK', title: 'STOCK'),
  S2Choice<String>(value: 'BK', title: 'BK'),
];

List<S2Choice<String>> listStatusRequest = [
  S2Choice<String>(value: 'OPEN', title: 'OPEN'),
  S2Choice<String>(value: 'CLOSE', title: 'CLOSE'),
  S2Choice<String>(value: 'CANCEL', title: 'CANCEL'),
];

List<S2Choice<String>> familyStatus = [
  S2Choice<String>(value: 'TK0', title: 'SINGLE'),
  S2Choice<String>(value: 'K0', title: 'KEL. ANAK 0'),
  S2Choice<String>(value: 'K1', title: 'KEL. ANAK 1'),
  S2Choice<String>(value: 'K2', title: 'KEL. ANAK 2'),
  S2Choice<String>(value: 'K3', title: 'KEL. ANAK 3'),
  S2Choice<String>(value: 'K4', title: 'KEL. ANAK 4'),
  S2Choice<String>(value: 'K5', title: 'KEL. ANAK 5'),
  S2Choice<String>(value: 'K6', title: 'KEL. ANAK 6'),
];

List<S2Choice<String>> golonganDarah = [
  S2Choice<String>(value: 'A', title: 'A'),
  S2Choice<String>(value: 'B', title: 'B'),
  S2Choice<String>(value: 'AB', title: 'AB'),
  S2Choice<String>(value: 'O', title: 'O'),
];

List<S2Choice<String>> categories = [
  S2Choice<String>(value: 'ele', title: 'Electronics'),
  S2Choice<String>(value: 'aud', title: 'Audio & Video'),
  S2Choice<String>(value: 'acc', title: 'Accessories'),
  S2Choice<String>(value: 'ind', title: 'Industrial'),
  S2Choice<String>(value: 'wat', title: 'Smartwatch'),
  S2Choice<String>(value: 'sci', title: 'Scientific'),
  S2Choice<String>(value: 'mea', title: 'Measurement'),
  S2Choice<String>(value: 'pho', title: 'Smartphone'),
];

List<S2Choice<String>> sorts = [
  S2Choice<String>(value: 'popular', title: 'Popular'),
  S2Choice<String>(value: 'review', title: 'Most Reviews'),
  S2Choice<String>(value: 'latest', title: 'Newest'),
  S2Choice<String>(value: 'cheaper', title: 'Low Price'),
  S2Choice<String>(value: 'pricey', title: 'High Price'),
];

//ASSET
List<S2Choice<String>> assetSelStatus = [
  S2Choice<String>(value: 'Active', title: 'Active'),
  S2Choice<String>(value: 'Non Active', title: 'Non Active')
];

List<S2Choice<String>> assetSelType = [
  S2Choice<String>(value: 'KOMPUTER', title: 'KOMPUTER'),
  S2Choice<String>(value: 'MONITOR', title: 'MONITOR'),
  S2Choice<String>(value: 'UPS', title: 'UPS'),
  S2Choice<String>(value: 'AC', title: 'AC'),
  S2Choice<String>(value: 'CAMERA', title: 'CAMERA'),
  S2Choice<String>(value: 'PRINTER', title: 'PRINTER'),
  S2Choice<String>(value: 'LAIN-LAIN', title: 'LAIN-LAIN'),
];

List<S2Choice<String>> assetSelDivisi = [
  S2Choice<String>(value: 'Accounting', title: 'Accounting'),
  S2Choice<String>(value: 'Aus', title: 'Aus'),
  S2Choice<String>(value: 'Finance', title: 'Finance'),
  S2Choice<String>(value: 'HRD', title: 'HRD'),
  S2Choice<String>(value: 'GM', title: 'GM'),
  S2Choice<String>(value: 'IT', title: 'IT'),
  S2Choice<String>(value: 'Marketing', title: 'Marketing'),
  S2Choice<String>(value: 'Maintenance', title: 'Maintenance'),
  S2Choice<String>(value: 'Motive', title: 'Motive'),
  S2Choice<String>(value: 'Operational', title: 'Operational'),
  S2Choice<String>(value: 'Purchassing', title: 'Purchassing'),
  S2Choice<String>(value: 'Rawamangun', title: 'Rawamangun'),
  S2Choice<String>(value: 'R&D', title: 'R&D'),
  S2Choice<String>(value: 'Warehouse', title: 'Warehouse'),
];

List<Map<String, dynamic>> provinsi = [
  {'value': 'Aceh', 'title': 'Aceh (NAD)'},
  {'value': 'Sumatra Utara', 'title': 'Sumatra Utara'},
  {'value': 'Riau', 'title': 'Riau'},
  {'value': 'Sumatra Barat', 'title': 'Sumatra Barat'},
  {'value': 'Jambi', 'title': 'Jambi'},
  {'value': 'Sumatra Selatan', 'title': 'Sumatra Selatan'},
  {'value': 'Bengkulu', 'title': 'Bengkulu'},
  {'value': 'Lampung', 'title': 'Lampung'},
  {'value': 'Jawa Timur', 'title': 'Jawa Timur'},
  {'value': 'Jawa Tengah', 'title': 'Jawa Tengah'},
  {'value': 'Yogyakarta', 'title': 'Yogyakarta (DIY)'},
  {'value': 'Jakarta', 'title': 'Jakarta (DKI)'},
  {'value': 'Jawa Barat', 'title': 'Jawa Barat'},
  {'value': 'Banten', 'title': 'Banten'},
  {'value': 'Kalimantan Selatan', 'title': 'Kalimantan Selatan'},
  {'value': 'Kalimantan Timur', 'title': 'Kalimantan Timur'},
  {'value': 'Kalimantan Tengah', 'title': 'Kalimantan Tengah'},
  {'value': 'Kalimantan Barat', 'title': 'Kalimantan Barat'},
  {'value': 'Sulawesi Selatan', 'title': 'Sulawesi Selatan'},
  {'value': 'Sulawesi Tengah', 'title': 'Sulawesi Tengah'},
  {'value': 'Sulawesi Tenggara', 'title': 'Sulawesi Tenggara'},
  {'value': 'Sulawesi Utara', 'title': 'Sulawesi Utara'},
  {'value': 'Nusa Tenggara Timur', 'title': 'Nusa Tenggara Timur'},
  {'value': 'Nusa Tenggara Barat', 'title': 'Nusa Tenggara Barat'},
  {'value': 'Bali ', 'title': 'Bali'},
  {'value': 'Maluku', 'title': 'Maluku'},
  {'value': 'Papua', 'title': 'Papua'}
];
List<Map<String, dynamic>> cars = [
  {'value': 'bmw-x1', 'title': 'BMW X1', 'brand': 'BMW', 'body': 'SUV'},
  {'value': 'bmw-x7', 'title': 'BMW X7', 'brand': 'BMW', 'body': 'SUV'},
  {'value': 'bmw-x2', 'title': 'BMW X2', 'brand': 'BMW', 'body': 'SUV'},
  {'value': 'bmw-x4', 'title': 'BMW X4', 'brand': 'BMW', 'body': 'SUV'},
  {
    'value': 'honda-crv',
    'title': 'Honda C-RV',
    'brand': 'Honda',
    'body': 'SUV'
  },
  {
    'value': 'honda-hrv',
    'title': 'Honda H-RV',
    'brand': 'Honda',
    'body': 'SUV'
  },
  {
    'value': 'mercedes-gcl',
    'title': 'Mercedes-Benz G-class',
    'brand': 'Mercedes',
    'body': 'SUV'
  },
  {
    'value': 'mercedes-gle',
    'title': 'Mercedes-Benz GLE',
    'brand': 'Mercedes',
    'body': 'SUV'
  },
  {
    'value': 'mercedes-ecq',
    'title': 'Mercedes-Benz ECQ',
    'brand': 'Mercedes',
    'body': 'SUV'
  },
  {
    'value': 'mercedes-glcc',
    'title': 'Mercedes-Benz GLC Coupe',
    'brand': 'Mercedes',
    'body': 'SUV'
  },
  {
    'value': 'lr-ds',
    'title': 'Land Rover Discovery Sport',
    'brand': 'Land Rover',
    'body': 'SUV'
  },
  {
    'value': 'lr-rre',
    'title': 'Land Rover Range Rover Evoque',
    'brand': 'Land Rover',
    'body': 'SUV'
  },
  {
    'value': 'honda-jazz',
    'title': 'Honda Jazz',
    'brand': 'Honda',
    'body': 'Hatchback'
  },
  {
    'value': 'honda-civic',
    'title': 'Honda Civic',
    'brand': 'Honda',
    'body': 'Hatchback'
  },
  {
    'value': 'mercedes-ac',
    'title': 'Mercedes-Benz A-class',
    'brand': 'Mercedes',
    'body': 'Hatchback'
  },
  {
    'value': 'hyundai-i30f',
    'title': 'Hyundai i30 Fastback',
    'brand': 'Hyundai',
    'body': 'Hatchback'
  },
  {
    'value': 'hyundai-kona',
    'title': 'Hyundai Kona Electric',
    'brand': 'Hyundai',
    'body': 'Hatchback'
  },
  {
    'value': 'hyundai-i10',
    'title': 'Hyundai i10',
    'brand': 'Hyundai',
    'body': 'Hatchback'
  },
  {'value': 'bmw-i3', 'title': 'BMW i3', 'brand': 'BMW', 'body': 'Hatchback'},
  {
    'value': 'bmw-sgc',
    'title': 'BMW 4-serie Gran Coupe',
    'brand': 'BMW',
    'body': 'Hatchback'
  },
  {
    'value': 'bmw-sgt',
    'title': 'BMW 6-serie GT',
    'brand': 'BMW',
    'body': 'Hatchback'
  },
  {
    'value': 'audi-a5s',
    'title': 'Audi A5 Sportback',
    'brand': 'Audi',
    'body': 'Hatchback'
  },
  {
    'value': 'audi-rs3s',
    'title': 'Audi RS3 Sportback',
    'brand': 'Audi',
    'body': 'Hatchback'
  },
  {
    'value': 'audi-ttc',
    'title': 'Audi TT Coupe',
    'brand': 'Audi',
    'body': 'Coupe'
  },
  {
    'value': 'audi-r8c',
    'title': 'Audi R8 Coupe',
    'brand': 'Audi',
    'body': 'Coupe'
  },
  {
    'value': 'mclaren-570gt',
    'title': 'Mclaren 570GT',
    'brand': 'Mclaren',
    'body': 'Coupe'
  },
  {
    'value': 'mclaren-570s',
    'title': 'Mclaren 570S Spider',
    'brand': 'Mclaren',
    'body': 'Coupe'
  },
  {
    'value': 'mclaren-720s',
    'title': 'Mclaren 720S',
    'brand': 'Mclaren',
    'body': 'Coupe'
  },
];

List<Map<String, dynamic>> smartphones = [
  {
    'id': 'sk3',
    'name': 'Samsung Keystone 3',
    'brand': 'Samsung',
    'category': 'Budget Phone'
  },
  {
    'id': 'n106',
    'name': 'Nokia 106',
    'brand': 'Nokia',
    'category': 'Budget Phone'
  },
  {
    'id': 'n150',
    'name': 'Nokia 150',
    'brand': 'Nokia',
    'category': 'Budget Phone'
  },
  {
    'id': 'r7a',
    'name': 'Redmi 7A',
    'brand': 'Xiaomi',
    'category': 'Mid End Phone'
  },
  {
    'id': 'ga10s',
    'name': 'Galaxy A10s',
    'brand': 'Samsung',
    'category': 'Mid End Phone'
  },
  {
    'id': 'rn7',
    'name': 'Redmi Note 7',
    'brand': 'Xiaomi',
    'category': 'Mid End Phone'
  },
  {
    'id': 'ga20s',
    'name': 'Galaxy A20s',
    'brand': 'Samsung',
    'category': 'Mid End Phone'
  },
  {
    'id': 'mc9',
    'name': 'Meizu C9',
    'brand': 'Meizu',
    'category': 'Mid End Phone'
  },
  {
    'id': 'm6',
    'name': 'Meizu M6',
    'brand': 'Meizu',
    'category': 'Mid End Phone'
  },
  {
    'id': 'ga2c',
    'name': 'Galaxy A2 Core',
    'brand': 'Samsung',
    'category': 'Mid End Phone'
  },
  {
    'id': 'r6a',
    'name': 'Redmi 6A',
    'brand': 'Xiaomi',
    'category': 'Mid End Phone'
  },
  {
    'id': 'r5p',
    'name': 'Redmi 5 Plus',
    'brand': 'Xiaomi',
    'category': 'Mid End Phone'
  },
  {
    'id': 'ga70',
    'name': 'Galaxy A70',
    'brand': 'Samsung',
    'category': 'Mid End Phone'
  },
  {
    'id': 'ai11',
    'name': 'iPhone 11 Pro',
    'brand': 'Apple',
    'category': 'Flagship Phone'
  },
  {
    'id': 'aixr',
    'name': 'iPhone XR',
    'brand': 'Apple',
    'category': 'Flagship Phone'
  },
  {
    'id': 'aixs',
    'name': 'iPhone XS',
    'brand': 'Apple',
    'category': 'Flagship Phone'
  },
  {
    'id': 'aixsm',
    'name': 'iPhone XS Max',
    'brand': 'Apple',
    'category': 'Flagship Phone'
  },
  {
    'id': 'hp30',
    'name': 'Huawei P30 Pro',
    'brand': 'Huawei',
    'category': 'Flagship Phone'
  },
  {
    'id': 'ofx',
    'name': 'Oppo Find X',
    'brand': 'Oppo',
    'category': 'Flagship Phone'
  },
  {
    'id': 'gs10',
    'name': 'Galaxy S10+',
    'brand': 'Samsung',
    'category': 'Flagship Phone'
  },
];

List<Map<String, dynamic>> transports = [
  {
    'title': 'Plane',
    'image': 'https://source.unsplash.com/Eu1xLlWuTWY/100x100',
  },
  {
    'title': 'Train',
    'image': 'https://source.unsplash.com/Njq3Nz6-5rQ/100x100',
  },
  {
    'title': 'Bus',
    'image': 'https://source.unsplash.com/qoXgaF27zBc/100x100',
  },
  {
    'title': 'Car',
    'image': 'https://source.unsplash.com/p7tai9P7H-s/100x100',
  },
  {
    'title': 'Bike',
    'image': 'https://source.unsplash.com/2LTMNCN4nEg/100x100',
  },
];
