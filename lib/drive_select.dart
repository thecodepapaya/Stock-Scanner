import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:scan_gsheet/auth.dart';
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
  File? res;

  @override
  Widget build(BuildContext context) {
    return GenericScaffold(
      title: "Select Sheet",
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
                    res = (await DriveApi(authClient!).files.get(id)) as File;
                    result =
                        "File name: ${res?.name}\nKind: ${res?.kind}\nMime Type: ${res?.mimeType}";
                    Globals.spreadSheetId = id;
                  } on DetailedApiRequestError catch (e) {
                    result = e.message.toString();
                    res = null;
                  } on ApiRequestError catch (e) {
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
}
