import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'giaodien.dart'; // Màn hình chính sau khi đăng nhập
import 'dangki.dart'; // Màn hình đăng ký
import 'manhinhadmin.dart'; // Màn hình admin

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  // Hàm xử lý đăng nhập
  void _handleSignIn() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: username)
          .get();

      if (userDoc.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Tên người dùng không tồn tại';
        });
        return;
      }

      var userData = userDoc.docs.first;

      if (userData['password'] != password) {
        setState(() {
          _errorMessage = 'Mật khẩu không đúng';
        });
        return;
      }

      if (userData.data().containsKey('isadmin') && userData['isadmin'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi đăng nhập: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm xử lý quên mật khẩu
  void _handleForgotPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Tìm kiếm email trong Firestore
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Email không hợp lệ. Vui lòng kiểm tra lại';
        });
        return;
      }

      // Gửi thông báo yêu cầu reset mật khẩu
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        _successMessage = 'Mật khẩu đã được gửi đến email của bạn';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi gửi yêu cầu quên mật khẩu: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
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
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _successMessage,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Tên người dùng',
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
                    decoration: const InputDecoration(
                      hintText: 'Mật khẩu',
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
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 24.0,
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Text(
                      'Đăng nhập',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Chưa có tài khoản? Đăng ký ngay',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Nhập email để lấy lại mật khẩu'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: 'Email của bạn',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _handleForgotPassword();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Gửi'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Hủy'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'Quên mật khẩu?',
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
