# Mastering (Master)

Dokumentasi menu **Master** di Android DMS ANP: hub master data + Master UJ Baru, beserta API mobile terkait.

## Akses

| Item | Syarat |
|------|--------|
| Tile dashboard **Master** (`idKey: 32`) | `akses_pages` mengandung **`MK`**, atau `username == ADMIN` |
| **Master Data Lainnya** | Sama (lewat hub Master, tanpa gate tambahan) |
| **Master UJ Baru** | Sama (lewat hub Master, tanpa gate tambahan) |

Tidak ada tile dashboard terpisah untuk UJ Baru.

## Alur navigasi Android

```
ViewDashboard
  └─ Master (idKey 32)
       └─ FrmMasterMenu (hub)
            ├─ Master Data Lainnya  → FrmMasterData
            └─ Master UJ Baru       → ListUjBaru
                                        ├─ Add (fixed bottom) → FrmUjBaru (add)
                                        ├─ Edit               → FrmUjBaru (edit)
                                        └─ Close              → STATUS = ADVANCE
```

Back dari `FrmMasterData` / `ListUjBaru` kembali ke **FrmMasterMenu**, bukan langsung dashboard.

## File Android

| File | Peran |
|------|--------|
| `lib/src/pages/ViewDashboard.dart` | Tile **Master**, navigasi ke hub |
| `lib/src/pages/master/FrmMasterMenu.dart` | Hub: Data Lainnya + UJ Baru |
| `lib/src/pages/FrmMasterData.dart` | Master Data Lainnya (Customer, Origin, Destination, Item, …) |
| `lib/src/pages/master/ListUjBaru.dart` | List draft UJ Baru + Edit / Close + Add fixed |
| `lib/src/pages/master/FrmUjBaru.dart` | Form add / edit UJ Baru |

## Master Data Lainnya

Layar tab existing (`FrmMasterData`): Customer, Origin, Destination, Item Type, dll.

- Base URL: `GlobalData.baseUrlOri` + `api/master/...` (web API di `trucking/web/api/master/`, bukan folder mobile).
- Contoh: `refference_api.jsp`, `save_new_customer_api2.jsp`, `save_new_origin_api.jsp`, dll.

## Master UJ Baru (Uang Jalan / UJS Baru)

Port dari web `trucking/web/master/uj-baru.jsp`.

### Entity & aturan bisnis

| Item | Nilai |
|------|--------|
| Tabel | `TBLCUSTITEMTYPERIT` |
| List filter | `CTRSTATUS='Active'`, `STATUS='0'`, `CUSNBR` tidak kosong, `DATE(CREATED_DATETIME) >= '2022-10-01'` |
| Add `CUSNBR` | `TL` + nomor dari `TBLNUMBER` (`NUMBERTYPE='TOL'`, `CPYID='RR'`) |
| Add `CTPID` | Dari alias kendaraan (non-BOX) via `tblvehicle` + `tblvehicletype` |
| Add force | `STATUS='0'`, `CTRSTATUS='Active'`, `CTRUJ`/`CTRTUJ`=0, currency default `IDR` |
| Close (Android) | Update `STATUS` → **`ADVANCE`** (hilang dari list draft) |
| PK update/close | `CUSNBR` + `CTPID` + `VHTALIAS` + `CTRORIGIN` |

### Field form / mapping

| UI | DB |
|----|-----|
| Number | `CUSNBR` |
| Customer | `CPYID` |
| Origin | `CTRORIGIN` |
| Destination | `CTRDESTINATION` |
| Vehicle Type Alias | `VHTALIAS` |
| Item Type | `ITEMTYPE` |
| Tariff | `CTRTARIFF` |
| Tariff UOM | `CTRTARIFFUOM` |
| Type UJ | `RITASE` |
| Rute | `CTRRUTE` |
| Effective Date | `CTREFFECTIVEDATE` |

Validasi wajib (add/update): Origin, Destination, Customer, Alias, Tariff, UOM, Type UJ, Effective Date.

Lookup “New Customer / Origin / Destination / Item” **tidak** digandakan di form UJ; buat master baru lewat **Master Data Lainnya**.

### API mobile UJ Baru

Base: `GlobalData.baseUrl` + `api/master/...`  
Folder deploy: `trucking/web/mobile/api/master/`

| File | Method / act | Fungsi |
|------|----------------|--------|
| `list_uj_baru.jsp` | `method=list` | List draft + pagination/search |
| `detail_uj_baru.jsp` | `method=detail` | Detail 1 baris (edit) |
| `save_uj_baru.jsp` | `method=add` / `method=update` | Insert / update |
| `close_uj_baru.jsp` | `method=close` | Set `STATUS=ADVANCE` |
| `refference_uj_baru.jsp` | `list_customer`, `list_origin`, `list_destination`, `list_item_type`, `list_uom`, `list_typeuj`, `list_vehicle_alias` | Dropdown form |

#### Contoh pemanggilan

```
GET  .../mobile/api/master/list_uj_baru.jsp?method=list&page=1&search=
GET  .../mobile/api/master/refference_uj_baru.jsp?method=list_customer
POST .../mobile/api/master/save_uj_baru.jsp
     method=add|update, userid, cusnbr, ctpid, destination, cpyid,
     tariff, uom, currency, effective_date, vhtalias, origin, ritase, rute, itemtype
POST .../mobile/api/master/close_uj_baru.jsp
     method=close, cusnbr, ctpid, vhtalias, origin, userid
```

Response sukses/gagal umumnya: `{"status":"success|failed","message":"..."}`.

## Referensi web (asal UJS Baru)

- Screen: `trucking/web/master/uj-baru.jsp` (title UJS Baru, screenID `MK1`)
- Lookup web: `trucking/web/api/do/refference_uj.jsp`
- Master helper web: `trucking/web/api/master/refference.jsp`, `save_new_*.jsp`
- Sibling workflow Close→ADVANCE: `cust-item-type-ritsok2-new.jsp` (bukan `window.close()` di uj-baru.jsp)

## Deploy checklist

1. Deploy semua JSP di `trucking/web/mobile/api/master/` ke Tomcat.
2. Hot restart / rebuild app Android setelah ubah menu Master / halaman UJ.
3. Pastikan user uji punya akses **MK** (atau login ADMIN).

## Catatan

- Theme UI: orange soft (`#FF8C69`, cream background) selaras inventory/PO.
- JSP mobile: gaya Java 6 / string JSON seperti API mobile lain di project ini.
