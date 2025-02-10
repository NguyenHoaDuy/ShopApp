import 'package:flutter/material.dart';
import 'dangnhap.dart'; // Import màn hình đăng nhập

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký thành công')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đăng ký thành công!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()), // Chuyển đến màn hình đăng nhập
                );
              },
              child: Text('Quay lại Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
