import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dangnhap.dart'; // Import màn hình đăng nhập của bạn
import 'quanlydonhangadmin.dart'; // Import màn hình quản lý đơn hàng
import 'dangsanphamadmin.dart'; // Import màn hình đăng sản phẩm mới
import 'doanhthu-admin.dart'; // Import màn hình thống kê doanh thu

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Hàm đăng xuất
  void _logout() {
    // Điều hướng đến màn hình đăng nhập khi đăng xuất
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()), // Thay SignInScreen bằng màn hình đăng nhập của bạn
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Quản Trị Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chào mừng bạn đến với trang quản trị admin!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Nút quản lý đơn hàng
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOrderScreen()),
                );
              },
              child: const Text('Quản lý Đơn hàng'),
            ),
            const SizedBox(height: 20),
            // Nút đăng sản phẩm mới
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductAddScreen()),
                );
              },
              child: const Text('Đăng sản phẩm mới'),
            ),
            const SizedBox(height: 20),
            // Nút thống kê doanh thu
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RevenueReportScreen()),
                );
              },
              child: const Text('Thống kê Doanh thu'),
            ),
          ],
        ),
      ),
    );
  }
}
