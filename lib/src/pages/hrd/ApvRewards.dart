import 'dart:convert';
import 'dart:io';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'FormApvRewards.dart';

class ApvRewards extends StatefulWidget {
  @override
  _ApvRewardsState createState() => _ApvRewardsState();
}

class _ApvRewardsState extends State<ApvRewards> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Map<String, dynamic>>> _future;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  Icon _searchIcon = const Icon(Icons.search);
  Widget _searchBar = const Text('List Reward Driver');

  goBack(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ViewDashboard()));
  }


  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) EasyLoading.dismiss();
    _future = _fetchRewards();
  }

  Future<List<Map<String, dynamic>>> _fetchRewards() async {
    try {
      final String url = GlobalData.baseUrl +
          "api/hrd/apv-rewards.jsp?method=list-apv-rewards";
      print(url);
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<Map<String, dynamic>> items = [];
        jsonList.forEach((raw) {
          final Map<String, dynamic> row = {
            "RWDNBR": _safeString(raw, 'RWDNBR'),
            "RWDDATE": _safeString(raw, 'RWDDATE'),
            "RWDTYPEID": _safeString(raw, 'RWDTYPEID'),
            "REWARDTYP": _safeString(raw, 'REWARDTYP'),
            "RWDPOINTS": _safeString(raw, 'RWDPOINTS'),
            "RWDQTY": _safeString(raw, 'RWDQTY'),
            "RWDSTATUS": _safeString(raw, 'RWDSTATUS'),
            "DRVID": _safeString(raw, 'DRVID'),
            "RWDTO": _safeString(raw, 'RWDTO'),
            "RWDVNOTE": _safeString(raw, 'RWDVNOTE'),
          };
          items.add(row);
        });
        return items;
      } else {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) alert(ctx, 2, "Server error: ${response.statusCode}", "warning");
        return [];
      }
    } catch (e) {
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        if (e is IOException) {
          alert(ctx, 2, "Cek koneksi internet.", "warning");
        } else {
          alert(ctx, 2, "Terjadi kesalahan.", "warning");
        }
      }
      return [];
    }
  }

  String _safeString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return "";
    final text = value.toString();
    if (text.toLowerCase() == 'null') return "";
    return text;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetchRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      goBack(context);
      return false;
    },
    child:  Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C69),
        title: _searchBar,
        actions: [
          IconButton(
            icon: _searchIcon,
            onPressed: () {
              setState(() {
                if (_searchIcon.icon == Icons.search) {
                  _searchIcon = const Icon(Icons.cancel);
                  _searchBar = ListTile(
                    leading: const Icon(Icons.search, color: Colors.white),
                    title: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari RWDNBR...',
                        hintStyle:
                        TextStyle(color: Colors.white70, fontSize: 16),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) {
                        setState(() {
                          _searchText = _searchController.text;
                          _future = _fetchRewards();
                        });
                      },
                    ),
                  );
                } else {
                  _searchController.clear();
                  _searchText = '';
                  _searchIcon = const Icon(Icons.search);
                  _searchBar = const Text('List Reward Driver');
                  _future = _fetchRewards();
                }
              });
            },
          )
        ],
      ),
      body: RefreshIndicator(
        key: globalScaffoldKey,
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Terjadi kesalahan'));
            }
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Tidak ada data')),
                ],
              );
            }

            // Filter berdasarkan pencarian
            List<Map<String, dynamic>> filtered = data;
            if (_searchText.isNotEmpty) {
              filtered = data
                  .where((e) => e['RWDNBR']
                  .toString()
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
                  .toList();
            }

            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _buildCard(item);
              },
            );
          },
        ),
      ),
    )
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: RWDNBR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['RWDNBR'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (item['RWDSTATUS'] == 'OPEN')
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item['RWDSTATUS'] ?? '-',
                    style: TextStyle(
                      color: (item['RWDSTATUS'] == 'OPEN')
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // RWDDATE dan TYPE
            Row(
              children: [
                const Icon(Icons.date_range, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item['RWDDATE'] ?? '',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                const Icon(Icons.category_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item['RWDTYPEID'] ?? '',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Driver dan Reward To
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item['DRVID'] ?? '',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                const Icon(Icons.card_giftcard, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item['RWDTO'] ?? '',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Points dan Qty
            Row(
              children: [
                const Icon(Icons.star_border, size: 18, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  "Points: ${item['RWDPOINTS'] ?? '0'}",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 20),
                //const Icon(Icons.num, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Text(
                  "Qty: ${item['RWDQTY'] ?? '0'}",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Points dan Qty
            Row(
              children: [
                const Icon(Icons.star_border, size: 18, color: Colors.amber),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Rewards Name: ${item['REWARDTYP'] ?? ''}",
                    style: const TextStyle(color: Colors.black54),
                    overflow: TextOverflow.ellipsis, // atau bisa diganti wrap
                    maxLines: 3, // batasi jumlah baris
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormApvRewards(item: item),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Pilih'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardOLd(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.card_giftcard, color: Colors.orange),
        title: Text(item['RWDNBR'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Reward To: ${item['RWDTO'] ?? '-'}"),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FormApvRewards(item: item),
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          child: const Text('Pilih'),
        ),
      ),
    );
  }
}
