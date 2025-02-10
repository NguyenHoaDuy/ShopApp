import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String userId;

  OrderHistoryScreen({required this.userId});

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      // Lấy tất cả đơn hàng của người dùng từ Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: widget.userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['orderDocId'] = doc.id; // Lưu lại ID tài liệu Firestore
        return data;
      }).toList();
    } catch (e) {
      print("Lỗi khi lấy đơn hàng: $e");
      return [];
    }
  }

  void _refreshOrders() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử mua hàng')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi tải lịch sử mua hàng'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có đơn hàng nào.'));
          }

          List<Map<String, dynamic>> orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['orderId'] ?? order['orderDocId']; // Ưu tiên hiển thị mã orderId

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('Đơn hàng #$orderId'),
                  subtitle: Text('Tổng tiền: \$${order['totalAmount']}'),
                  trailing: Text(order['status'] ?? 'Chưa có trạng thái'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(
                          order: order,
                          onOrderUpdated: _refreshOrders,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final VoidCallback onOrderUpdated;

  OrderDetailScreen({required this.order, required this.onOrderUpdated});

  Future<void> _cancelOrder(BuildContext context) async {
    try {
      await _firestore
          .collection('orders')
          .doc(order['orderDocId'])
          .update({'status': 'Hủy'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng đã được hủy thành công!')),
      );

      onOrderUpdated();
      Navigator.pop(context);
    } catch (e) {
      print("Lỗi khi hủy đơn hàng: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi hủy đơn hàng!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderId = order['orderId'] ?? order['orderDocId']; // Ưu tiên hiển thị mã orderId

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã đơn hàng: $orderId'),
            Text('Địa chỉ: ${order['address']}'),
            Text('Trạng thái: ${order['status']}'),
            Text('Số điện thoại: ${order['phone']}'),
            Text('phương thức thanh toán : ${order['paymentMethod']}'),
            const SizedBox(height: 20),
            const Text('Danh sách sản phẩm:'),
            for (var product in order['items'] ?? [])
              Text(
                '- ${product['name']} x${product['quantity']} (Giá: \$${product['price']})',
              ),
            const SizedBox(height: 20),
            Text('Tổng tiền: \$${order['totalAmount']}'),
            const SizedBox(height: 30),
            if (order['status'] == 'pending')
              ElevatedButton(
                onPressed: () => _cancelOrder(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hủy đơn hàng', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
