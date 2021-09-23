import 'package:hive/hive.dart';

part 'db_data.g.dart';

@HiveType(typeId: 0)
class DbData extends HiveObject {
  @HiveField(0)
  String? filePath;

  @HiveField(1)
  String? barcodeData;

  @HiveField(2)
  String? sheetId;

  @HiveField(3)
  String? timestamp;

  @HiveField(4)
  bool? isUploaded;
}
