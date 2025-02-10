import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doimatkhau.dart';
import 'lichsudonhang.dart';
import 'dangnhap.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _userInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Lấy thông tin người dùng khi màn hình được hiển thị
  }

  // Hàm lấy UID của người dùng từ Firebase Authentication
  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Hàm đăng xuất
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
          (Route<dynamic> route) => false, // Đảm bảo rằng tất cả các route trước đó bị xóa
    );
  }

  // Hàm lấy dữ liệu người dùng từ Firestore
  void _fetchUserInfo() async {
    try {
      String? userId = _getCurrentUserId();

      if (userId == null) {
        // Nếu không có người dùng đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bạn chưa đăng nhập!')),
        );
        return;
      }

      // Lấy thông tin người dùng từ Firestore bằng UID
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        setState(() {
          _userInfo = doc.data() as Map<String, dynamic>;
          _isLoading = false; // Cập nhật trạng thái loading sau khi có dữ liệu
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy thông tin người dùng!')),
        );
        setState(() {
          _isLoading = false; // Cập nhật trạng thái loading
        });
      }
    } catch (e) {
      // Xử lý lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải thông tin người dùng: $e')),
      );
      setState(() {
        _isLoading = false; // Cập nhật trạng thái loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin người dùng'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app), // Icon đăng xuất
            onPressed: _logout, // Gọi hàm đăng xuất
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Nếu đang tải, hiển thị vòng xoay
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tên: ${_userInfo['name'] ?? 'Chưa có tên'}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${_userInfo['email'] ?? 'Chưa có email'}',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 10),
            Text(
              'Số điện thoại: ${_userInfo['phone'] ?? 'Chưa có số điện thoại'}',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Điều hướng tới màn hình đổi mật khẩu
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              },
              child: Text('Đổi mật khẩu', style: TextStyle(fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () {
                // Điều hướng tới màn hình xem lịch sử mua hàng
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryScreen(userId: _getCurrentUserId() ?? ''),
                  ),
                );
              },
              child: Text('Xem lịch sử mua hàng', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
