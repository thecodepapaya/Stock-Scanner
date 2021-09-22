import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis/drive/v3.dart' as d3;
import 'package:googleapis/sheets/v4.dart';
import 'package:scan_gsheet/auth.dart';
import 'package:scan_gsheet/globals.dart';
import 'package:scan_gsheet/show_camera.dart';
import 'package:scan_gsheet/generic_scaffold.dart';

class CodeScanner extends StatefulWidget {
  const CodeScanner({Key? key}) : super(key: key);

  @override
  State<CodeScanner> createState() => _CodeScannerState();
}

class _CodeScannerState extends State<CodeScanner> {
  late Future<ScanResult> scanResult;
  String data = '';
  String message = '';
  XFile? file;
  String uploadedFileId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scanBarCode();
  }

  void scanBarCode() {
    scanResult = BarcodeScanner.scan();
    scanResult.then((res) {
      switch (res.type) {
        case ResultType.Barcode:
          message = "Data from Scanner:";
          break;
        case ResultType.Cancelled:
          message = "Scan Cancelled";
          break;
        case ResultType.Error:
          message = "Error occured";
          break;
      }
      setState(() {
        data = res.rawContent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GenericScaffold(
      title: "Scan Code",
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message + " " + data),
            const SizedBox(height: 50),
            ElevatedButton(
                child: const Text("Take a picture"),
                onPressed: data == '' ? null : takeAPicture),
            ElevatedButton(
              child: const Text("Upload to GSheet"),
              onPressed: file == null ? null : uploadToDrive,
            ),
          ],
        ),
      ),
      fab: FloatingActionButton(
        child: const Icon(Icons.qr_code_2_rounded),
        onPressed: () {
          data = '';
          scanBarCode();
        },
      ),
    );
  }

  void takeAPicture() async {
    debugPrint("Taking picture");
    file = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ShowCamera()));
    debugPrint("Returned file: $file");
    setState(() {});
  }

  Future<void> uploadToDrive() async {
    debugPrint("Uploading");
    try {
      var fileToUpload = File(file!.path);
      var res = await d3.DriveApi((await Auth.authenticatedClient())!)
          .files
          .create(
              d3.File()
                ..name =
                    "scanned_image_${DateTime.now().millisecondsSinceEpoch}.jpg",
              uploadMedia:
                  d3.Media(fileToUpload.openRead(), fileToUpload.lengthSync()));
      debugPrint("Uploaded file: " + res.toString());
      debugPrint("Uploaded file: " + res.id.toString());
      uploadedFileId = res.id ?? '';
      addToSheets();
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Could not upload file to Google Drive. Error $e');
    }
  }

  void addToSheets() async {
    try {
      AppendValuesResponse res =
          await SheetsApi((await Auth.authenticatedClient())!)
              .spreadsheets
              .values
              .append(
                ValueRange(
                  values: [
                    [
                      DateTime.now().toIso8601String(),
                      data,
                      uploadedFileId,
                    ],
                  ],
                ),
                Globals.spreadSheetId,
                'A1:C1',
                valueInputOption: 'RAW',
              );
      debugPrint(res.toJson().toString());
      Fluttertoast.showToast(msg: 'Added new entry to GSheet.');
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Could not add new entry to GSheet. Error $e');
    }
  }
}
