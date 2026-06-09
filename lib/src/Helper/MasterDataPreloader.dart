import 'package:dms_anp/src/Helper/MasterDataCache.dart';
import 'package:dms_anp/src/Helper/Provider.dart';

class MasterDataPreloader {
  static Future<void> preloadCommon({bool forceRefresh = false}) async {
    try {
      await Future.wait([
        MasterDataCache.getJsonList(
          cacheKey: "do:list_typeservice",
          url:
              "${GlobalData.baseUrl}api/do/refference_master.jsp?method=list_typeservice",
          forceRefresh: forceRefresh,
        ),
        MasterDataCache.getJsonList(
          cacheKey: "inventory:list_fromwh",
          url:
              "${GlobalData.baseUrl}api/inventory/refference_master.jsp?method=list_fromwh",
          forceRefresh: forceRefresh,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"},
        ),
        MasterDataCache.getJsonList(
          cacheKey: "inventory:list_towh",
          url:
              "${GlobalData.baseUrl}api/inventory/refference_master.jsp?method=list_towh",
          forceRefresh: forceRefresh,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"},
        ),
        MasterDataCache.getJsonList(
          cacheKey: "inventory:list_bengkel",
          url:
              "${GlobalData.baseUrl}api/inventory/refference_master.jsp?method=list_bengkel",
          forceRefresh: forceRefresh,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"},
        ),
      ]);
    } catch (e) {
      print("preload master data failed: $e");
    }
  }
}
