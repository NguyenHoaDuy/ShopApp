import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dkithanhcong.dart'; // Import màn hình đăng ký thành công

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  bool isLoading = false; // Biến trạng thái loading

  String? phoneError;
  String? emailError;
  String? passwordError;
  String? rePasswordError;

  String? validatePhone(String value) {
    if (value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    return null;
  }

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    return null;
  }

  String? validateRePassword(String value) {
    if (value.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  void _onRegister() async {
    setState(() {
      isLoading = true; // Bắt đầu loading
      phoneError = validatePhone(_phoneController.text);
      emailError = validateEmail(_emailController.text);
      passwordError = validatePassword(_passwordController.text);
      rePasswordError = validateRePassword(_rePasswordController.text);
    });

    if (phoneError != null || emailError != null || passwordError != null || rePasswordError != null) {
      setState(() {
        isLoading = false; // Tắt loading nếu có lỗi
      });
      return;
    }

    try {
      // Kiểm tra xem tên đăng nhập đã tồn tại trong Firestore chưa
      final usernameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: _usernameController.text)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        // Nếu tên đăng nhập đã tồn tại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tên đăng nhập đã tồn tại. Vui lòng chọn tên khác.')),

        );
        setState(() {
          isLoading = false; // Tắt loading
        });
        return;
      }

      // Kiểm tra xem email đã được sử dụng chưa
      final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_emailController.text);
      if (signInMethods.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email đã được đăng ký. Vui lòng đăng nhập.')),
        );
        setState(() {
          isLoading = false; // Tắt loading
        });
        return;
      }

      // Kiểm tra xem số điện thoại đã tồn tại trong Firestore chưa
      final phoneQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: _phoneController.text)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        // Nếu số điện thoại đã tồn tại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Số điện thoại đã được đăng ký. Vui lòng sử dụng số khác.')),
        );
        setState(() {
          isLoading = false; // Tắt loading
        });
        return;
      }

      // Đăng ký người dùng với Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Lấy UID của người dùng
      String uid = userCredential.user!.uid;

      // Lưu thông tin người dùng vào Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'name': _usernameController.text,
        'password': _passwordController.text,
      });

      // Chuyển hướng sang màn hình đăng ký thành công
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đăng ký: $error')),
      );
    } finally {
      setState(() {
        isLoading = false; // Tắt loading khi hoàn tất
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[100],
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Romio Shop',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32.0),
                  if (phoneError != null || emailError != null || passwordError != null || rePasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Vui lòng kiểm tra thông tin đăng ký.',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Số điện thoại',
                      errorText: phoneError,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 14.0,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      errorText: emailError,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 14.0,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Tên đăng nhập',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu',
                      errorText: passwordError,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _rePasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Nhập lại mật khẩu',
                      errorText: rePasswordError,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 24.0,
                      ),
                    ),
                    child: const Text(
                      'Đăng ký',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Đã có tài khoản? Đăng nhập',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
