import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String currentImage;
  late String productName;
  late double productPrice;
  late List<dynamic> detailedImages;
  late String productOrigin;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  // Fetch product details from Firestore
  void fetchProductDetails() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    if (docSnapshot.exists) {
      setState(() {
        productName = docSnapshot['name'];
        productPrice = docSnapshot['price'].toDouble();
        productOrigin = docSnapshot['manufacturer'];
        currentImage = docSnapshot['imageUrl'];
        detailedImages = List<String>.from(docSnapshot['detailedImages']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Optional: Handle case when product does not exist
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isLoading ? Text('Loading...') : Text(productName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ảnh chính hiển thị ở giữa đầu màn hình
            currentImage.isEmpty
                ? const CircularProgressIndicator()
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Image.network(
                  currentImage,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Tên sản phẩm
            Text(
              productName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Giá sản phẩm
            Text(
              ' ${productPrice.toStringAsFixed(2)}VND',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            // Nơi sản xuất
            Text(
              'Sản xuất tại: $productOrigin',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Tiêu đề ảnh chi tiết
            const Text(
              'Chi tiết sản phẩm:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Ảnh chi tiết dạng cuộn ngang
            detailedImages.isEmpty
                ? const CircularProgressIndicator()
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: detailedImages.map((imageUrl) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentImage = imageUrl;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        imageUrl,
                        height: 80, // Kích thước ảnh nhỏ
                        width: 80, // Kích thước vuông
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
