import 'package:expense_tracker_flutter/pages/pencatat_keuangan_app.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // Theme configuration
          ),
      home: PencatatKeuanganApp(),
    );
  }
}
