import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RevenueReportScreen extends StatefulWidget {
  @override
  _RevenueReportScreenState createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  double totalRevenue = 0;
  bool isLoading = true; // Biến kiểm tra trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    fetchRevenueData();
  }

  // Lấy dữ liệu thống kê doanh thu từ Firestore
  Future<void> fetchRevenueData() async {
    double revenue = 0;
    try {
      // Truy vấn các đơn hàng có trạng thái "Đã giao"
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders') // Tên collection của bạn
          .where('status', isEqualTo: 'Đã giao') // Trạng thái đơn hàng
          .get();

      // Kiểm tra nếu không có đơn hàng nào có trạng thái "Đã giao"
      if (ordersSnapshot.docs.isEmpty) {
        print('Không có đơn hàng nào có trạng thái "Đã giao".');
      }

      // Duyệt qua từng đơn hàng và cộng dồn doanh thu
      for (var orderDoc in ordersSnapshot.docs) {
        double orderTotal = orderDoc['totalAmount']; // Trường 'totalAmount' chứa tổng doanh thu
        print('Tổng số tiền của đơn hàng: $orderTotal'); // In ra giá trị để gỡ lỗi
        revenue += orderTotal; // Cộng dồn doanh thu
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu doanh thu: $e');
    }

    setState(() {
      totalRevenue = revenue;
      isLoading = false; // Đã hoàn tất tải dữ liệu
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Thống Kê Doanh Thu', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ) // Hiển thị vòng xoay khi đang tải
              : totalRevenue == 0
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 20),
              Text(
                'Không có đơn hàng nào có trạng thái "Đã giao".',
                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.attach_money, color: Colors.green, size: 50),
              const SizedBox(height: 20),
              Text(
                'Tổng Doanh Thu: ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                '${totalRevenue.toStringAsFixed(2)} VND',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 20),
              Text(
                'Cập nhật lúc: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
