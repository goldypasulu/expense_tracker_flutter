import 'package:flutter/material.dart';
import '../pages/pencatat_keuangan_page.dart';

class PencatatKeuanganApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatat Keuangan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PencatatKeuanganPage(),
    );
  }
}
