import 'package:flutter/material.dart';
import 'login_page.dart';
import 'pencatat_keuangan_page.dart';

class HomePage extends StatelessWidget {
  final bool isLoggedIn =
      false; // Contoh status login, bisa disesuaikan dengan implementasi Anda

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? PencatatKeuanganPage() : LoginPage();
  }
}
