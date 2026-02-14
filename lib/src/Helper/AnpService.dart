import 'package:flutter/material.dart';

class AnpService {
  final IconData? image;
  final Color? color;
  final String? title;
  final int? idKey;

  const AnpService({
    this.image,
    this.title,
    this.color,
    this.idKey,
  });
}

/*
/Users/adam/Downloads/flutter/bin/flutter --no-color pub outdated
Showing outdated packages.
[*] indicates versions that are not the latest available.

Package Name                           Current   Upgradable  Resolvable  Latest

direct dependencies:
cached_network_image                   *2.5.1    *2.5.1      3.0.0       3.0.0
flutter_staggered_grid_view            *0.3.4    *0.3.4      0.4.0       0.4.0
font_awesome_flutter                   *9.0.0    9.1.0       9.1.0       9.1.0
geolocator                             *7.0.3    *7.0.3      7.1.0       7.1.0
image_picker                           *0.7.5+4  *0.7.5+4    0.8.0+3     0.8.0+3
implicitly_animated_reorderable_list   *0.3.2    *0.3.2      0.4.0       0.4.0
location                               *4.2.1    4.3.0       4.3.0       4.3.0
permission_handler                     *6.1.3    *6.1.3      8.1.0       8.1.0
qrscan                                 *0.2.22   *0.2.22     0.3.1       0.3.1
sliding_up_panel                       *1.0.2    *1.0.2      2.0.0+1     2.0.0+1
sqflite                                *1.3.2+4  *1.3.2+4    2.0.0+3     2.0.0+3

transitive dependencies:
ansicolor                              *1.1.1    *1.1.1      *1.1.1      2.0.1
async                                  *2.5.0    *2.5.0      *2.5.0      2.7.0
charcode                               *1.2.0    *1.2.0      *1.2.0      1.3.1
flutter_blurhash                       *0.5.0    *0.5.0      0.6.0       0.6.0
flutter_cache_manager                  *2.1.2    *2.1.2      3.1.1       3.1.1
geolocator_platform_interface          *2.1.0    2.1.1       2.1.1       2.1.1
location_platform_interface            *2.2.0    2.3.0       2.3.0       2.3.0
location_web                           *3.1.0    3.1.1       3.1.1       3.1.1
logging                                *0.11.4   *0.11.4     *0.11.4     1.0.1
meta                                   *1.3.0    *1.3.0      *1.3.0      1.4.0
octo_image                             *0.3.0    *0.3.0      1.0.0+1     1.0.0+1
permission_handler_platform_interface  *3.5.1    3.6.0       3.6.0       3.6.0
petitparser                            *4.1.0    *4.1.0      *4.1.0      4.2.0
rxdart                                 *0.25.0   *0.25.0     0.27.1      0.27.1
source_span                            *1.8.0    *1.8.0      *1.8.0      1.8.1
sqflite_common                         *1.0.3+3  *1.0.3+3    2.0.0+2     2.0.0+2
synchronized                           *2.2.0+2  *2.2.0+2    3.0.0       3.0.0
win32                                  *2.0.5    *2.0.5      *2.0.5      2.1.5

transitive dev_dependencies:
test_api                               *0.2.19   *0.2.19     *0.2.19     0.4.1

6 upgradable dependencies are locked (in pubspec.lock) to older versions.
To update these dependencies, use `flutter pub upgrade`.

15  dependencies are constrained to versions that are older than a resolvable version.
To update these dependencies, edit pubspec.yaml, or run `flutter pub upgrade --major-versions`.
Process finished with exit code 0
 */