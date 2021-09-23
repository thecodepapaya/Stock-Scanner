import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scan_gsheet/auth_handler.dart';
import 'package:scan_gsheet/db_data.dart';
import 'package:scan_gsheet/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Globals.cameras = await availableCameras();
  await Hive.initFlutter();
  Hive.registerAdapter(DbDataAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIITV Scanner to GSheet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthHandler.handler(),
    );
  }
}
