import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:scan_gsheet/drive_select.dart';
import 'package:scan_gsheet/login_page.dart';

class AuthHandler {
  AuthHandler._();
  static handler() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          return const DriveSelect();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
