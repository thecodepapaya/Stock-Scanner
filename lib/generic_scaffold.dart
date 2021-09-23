import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scan_gsheet/auth.dart';

class GenericScaffold extends StatelessWidget {
  const GenericScaffold(
      {Key? key, required this.title, this.body, this.fab, this.action})
      : super(key: key);

  final String title;
  final Widget? body;
  final Widget? fab;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              FirebaseAuth.instance.currentUser?.photoURL ?? "",
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Auth.logout();
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
          if (action != null) action!,
        ],
      ),
      body: body,
      floatingActionButton: fab,
    );
  }
}
