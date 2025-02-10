import 'package:flutter/material.dart';
import 'giaodien.dart';
import 'dangnhap.dart';
import 'package:firebase_core/firebase_core.dart';  // Đảm bảo import firebase_core

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROMIO SHOP',
      debugShowCheckedModeBanner: false,
      home: SignInScreen(),
    );
  }
}
