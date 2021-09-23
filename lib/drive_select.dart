import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis/drive/v3.dart' as d3;
import 'package:googleapis/sheets/v4.dart' as s4;
import 'package:hive/hive.dart';
import 'package:scan_gsheet/auth.dart';
import 'package:scan_gsheet/db_data.dart';
import 'package:scan_gsheet/generic_scaffold.dart';
import 'package:scan_gsheet/globals.dart';
import 'package:scan_gsheet/scanner.dart';

class DriveSelect extends StatefulWidget {
  const DriveSelect({Key? key}) : super(key: key);

  @override
  _DriveSelectState createState() => _DriveSelectState();
}

class _DriveSelectState extends State<DriveSelect> {
  final TextEditingController _controller = TextEditingController();

  String result = '';
  d3.File? res;

  @override
  Widget build(BuildContext context) {
    return GenericScaffold(
      title: "Select Sheet",
      action: IconButton(
        icon: const Icon(Icons.backup),
        onPressed: () async {
          var box = await Hive.openBox<DbData>(Globals.boxName);
          var data = box.values.toList();
          for (int i = 0; i < data.length; i++) {
            uploadToDrive(
              filepath: data[i].filePath!,
              barcodeData: data[i].barcodeData!,
              timestamp: data[i].timestamp!,
              sheetID: data[i].sheetId!,
            ).then((value) {
              box.deleteAt(0);
              debugPrint("Deleted entry 0");
            });
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Enter File URL or ID",
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                child: const Text("Select File from Drive"),
                onPressed: () async {
                  String id = '';

                  id = _controller.text.startsWith("https://")
                      ? id = _controller.text.split("/")[5]
                      : _controller.text;
                  var authClient = await Auth.authenticatedClient();
                  try {
                    res = (await d3.DriveApi(authClient!).files.get(id))
                        as d3.File;
                    result =
                        "File name: ${res?.name}\nKind: ${res?.kind}\nMime Type: ${res?.mimeType}";
                    Globals.spreadSheetId = id;
                  } on d3.DetailedApiRequestError catch (e) {
                    result = e.message.toString();
                    res = null;
                  } on d3.ApiRequestError catch (e) {
                    result = e.message.toString();
                    res = null;
                  } catch (e) {
                    result =
                        "Unknown Error occured. Try logging out and loggin in again.";
                    res = null;
                  }
                  setState(() {});
                  debugPrint(res?.name);
                  debugPrint(res?.mimeType);
                },
              ),
              const SizedBox(height: 50),
              Text(result),
              const SizedBox(height: 50),
              ElevatedButton(
                child: const Text("Proceed"),
                onPressed:
                    res?.mimeType == "application/vnd.google-apps.spreadsheet"
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) {
                                  return const CodeScanner();
                                },
                              ),
                            );
                          }
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadToDrive({
    required String filepath,
    required String barcodeData,
    required String timestamp,
    required String sheetID,
  }) async {
    debugPrint("Uploading $filepath");
    try {
      var fileToUpload = File(filepath);
      var result = await d3.DriveApi((await Auth.authenticatedClient())!)
          .files
          .create(
              d3.File()
                ..name =
                    "scanned_image_${DateTime.now().millisecondsSinceEpoch}.jpg",
              uploadMedia:
                  d3.Media(fileToUpload.openRead(), fileToUpload.lengthSync()));
      debugPrint("Uploaded file: " + result.id.toString());
      var uploadedFileId = result.id ?? '';
      addToSheets(
        barcodeData: barcodeData,
        sheetID: sheetID,
        timestamp: timestamp,
        uploadedFileId: uploadedFileId,
      );
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Could not upload file to Google Drive. Error $e');
    }
  }

  void addToSheets({
    required String barcodeData,
    required String timestamp,
    required String sheetID,
    required String uploadedFileId,
  }) async {
    debugPrint(
        'Adding to sheet $barcodeData $timestamp $sheetID $uploadedFileId');
    try {
      s4.AppendValuesResponse res =
          await s4.SheetsApi((await Auth.authenticatedClient())!)
              .spreadsheets
              .values
              .append(
                s4.ValueRange(
                  values: [
                    [
                      timestamp,
                      barcodeData,
                      uploadedFileId,
                    ],
                  ],
                ),
                sheetID,
                'A1:C1',
                valueInputOption: 'RAW',
              );
      debugPrint(res.toJson().toString());
      Fluttertoast.showToast(msg: 'Added new entry to GSheet from Local');
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Could not add new entry to GSheet from Local. Error $e');
    }
  }
}
