import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _message;
  Color _messageColor = Colors.black;

  Future<void> _changePassword() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _message = 'Không tìm thấy người dùng!';
        _messageColor = Colors.red;
      });
      return;
    }

    setState(() {
      _message = null;
    });

    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      setState(() {
        _message = 'Mật khẩu xác nhận không đúng!';
        _messageColor = Colors.red;
      });
      return;
    }

    try {
      // Lấy mật khẩu cũ từ Firestore
      final userDoc =
      await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists || userDoc.data()?['password'] != oldPassword) {
        setState(() {
          _message = 'Mật khẩu cũ không chính xác!';
          _messageColor = Colors.red;
        });
        return;
      }

      // Cập nhật mật khẩu mới trên Firebase Auth
      await user.updatePassword(newPassword);

      // Lưu mật khẩu mới vào Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'password': newPassword,
      });

      setState(() {
        _message = 'Mật khẩu đã được thay đổi thành công!';
        _messageColor = Colors.green;
      });

      // Xóa dữ liệu nhập
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Quay lại màn hình trước sau 1 giây
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        _message = 'Có lỗi xảy ra: ${e.toString()}';
        _messageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đổi mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_message != null)
              Container(
                padding: EdgeInsets.all(10),
                color: _messageColor.withOpacity(0.1),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _messageColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 10),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu cũ',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Đổi mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}
