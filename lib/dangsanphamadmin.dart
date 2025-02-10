import 'package:flutter/material.dart';

class ProductAddScreen extends StatefulWidget {
  @override
  _ProductAddScreenState createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng sản phẩm mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _productPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá sản phẩm',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Nút bấm chưa có logic xử lý
                  },
                  child: const Text('Đăng sản phẩm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
