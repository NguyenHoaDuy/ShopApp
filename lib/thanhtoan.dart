import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'giaodien.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  PaymentScreen({required this.cartItems, required this.totalAmount});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _paymentMethod = "Tiền mặt";
  bool _isProcessing = false;
  bool _disableBackButton = false;

  Future<void> addOrderToFirestore(
      String name, String address, String phone) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Không có người dùng đăng nhập.");
      return;
    }

    CollectionReference orders =
    FirebaseFirestore.instance.collection('orders');
    await orders.add({
      'name': name,
      'address': address,
      'phone': phone,
      'status': 'pending',
      'userId': userId,
      'totalAmount': widget.totalAmount,
      'items': widget.cartItems,
      'paymentMethod': _paymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _processPayment(BuildContext context) async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('Vui lòng nhập đầy đủ Họ và Tên, Địa chỉ, và Số điện thoại.'),
        ),
      );
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _disableBackButton = true; // Chặn nút quay lại
    });

    try {
      await addOrderToFirestore(
        _nameController.text,
        _addressController.text,
        _phoneController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thanh toán thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(Duration(seconds: 2));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Lỗi khi xử lý thanh toán: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra, vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_disableBackButton,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Thanh Toán'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'Thông tin giao hàng',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Họ và Tên',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Phương thức thanh toán',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      title: Text("Tiền mặt"),
                      leading: Radio<String>(
                        value: "Tiền mặt",
                        groupValue: _paymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text("Chuyển khoản"),
                      leading: Radio<String>(
                        value: "Chuyển khoản",
                        groupValue: _paymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                    ),
                    Divider(thickness: 2),
                    Text(
                      'Danh sách sản phẩm',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            backgroundImage: NetworkImage(item['imageUrl'] ?? ''),
                            child: item['imageUrl'] == null
                                ? Text(
                              item['quantity'].toString(),
                              style: TextStyle(color: Colors.white),
                            )
                                : null,
                          ),
                          title: Text(item['name']),
                          subtitle: Text('Giá: \$${item['price']}'),
                          trailing: Text(
                            'Tổng: ${(item['price'] * item['quantity']).toStringAsFixed(2)} VND',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                    Divider(thickness: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng Cộng:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.totalAmount.toStringAsFixed(2)} VND',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _isProcessing ? Colors.grey : Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isProcessing ? null : () => _processPayment(context),
                child: Text(
                  _isProcessing ? 'Đang xử lý...' : 'Hoàn Tất Thanh Toán',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
