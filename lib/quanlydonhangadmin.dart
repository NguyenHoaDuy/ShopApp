import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderScreen extends StatefulWidget {
  @override
  _AdminOrderScreenState createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Danh sách trạng thái đơn hàng (không bao gồm "Tất cả" cho dropdown trạng thái đơn hàng)
  final List<String> _orderStatuses = ['pending', 'Chờ xử lý', 'Đang giao', 'Đã giao', 'Hủy'];

  // Trạng thái lọc hiện tại
  String _selectedStatus = 'Tất cả';

  // Hàm cập nhật trạng thái đơn hàng
  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trạng thái đơn hàng đã được cập nhật')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi cập nhật trạng thái: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đơn hàng'),
      ),
      body: Column(
        children: [
          // Dropdown chọn trạng thái lọc (giữ "Tất cả" để hiển thị tất cả đơn hàng)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (String? newStatus) {
                if (newStatus != null) {
                  setState(() {
                    _selectedStatus = newStatus;
                  });
                }
              },
              items: ['Tất cả', ..._orderStatuses].map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
            ),
          ),

          // Danh sách đơn hàng
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('orders').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Không có đơn hàng nào'));
                }

                // Lọc đơn hàng theo trạng thái
                final orders = snapshot.data!.docs.where((doc) {
                  final status = doc['status'] ?? 'pending';
                  if (_selectedStatus == 'Tất cả') {
                    return true;
                  }
                  return status == _selectedStatus;
                }).toList();

                if (orders.isEmpty) {
                  return const Center(child: Text('Không có đơn hàng phù hợp'));
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderId = order.id;
                    final customerName = order['name'] ?? 'Không rõ';
                    final phone = order['phone'] ?? 'Không rõ';
                    final address = order['address'] ?? 'Không rõ';
                    final totalAmount = order['totalAmount'] ?? 0;
                    final items = order['items'] as List<dynamic>? ?? [];
                    final currentStatus = order['status'] ?? 'pending';
                    final paymentMethod = order['paymentMethod'] ?? '??';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đơn hàng #$orderId',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text('Khách hàng: $customerName'),
                            Text('Số điện thoại: $phone'),
                            Text('Địa chỉ: $address'),
                            Text('Tổng tiền: \$${totalAmount.toStringAsFixed(2)}'),
                            Text('Phương thức thanh toán: $paymentMethod'),
                            const SizedBox(height: 8.0),
                            Text('Sản phẩm:', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ...items.map((item) {
                              final itemName = item['name'] ?? 'Không rõ';
                              final itemPrice = item['price'] ?? 0;
                              final itemQuantity = item['quantity'] ?? 0;
                              return Text(' - $itemName: \$${itemPrice} x $itemQuantity');
                            }).toList(),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Trạng thái:', style: TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<String>(
                                  value: _orderStatuses.contains(currentStatus) ? currentStatus : _orderStatuses.first,
                                  onChanged: (String? newStatus) {
                                    if (newStatus != null) {
                                      _updateOrderStatus(orderId, newStatus);
                                    }
                                  },
                                  items: _orderStatuses.map((String status) {
                                    return DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(status),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
