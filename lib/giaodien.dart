import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'thongtinnguoidung.dart'; // Import trang thông tin người dùng
import 'chitietsanpham.dart'; // Import màn hình chi tiết sản phẩm
import 'thanhtoan.dart'; // Import màn hình thanh toán

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _cart = [];
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<Map<String, dynamic>>> fetchProducts() {
    String searchQueryLower = _searchQuery.toLowerCase();

    return _firestore.collection('products')
        .where('name', isGreaterThanOrEqualTo: searchQueryLower)
        .where('name', isLessThan: searchQueryLower + '\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'productId': doc.id,
          'name': doc['name'],
          'price': (doc['price'] is int) ? (doc['price'] as int).toDouble() : doc['price'],
          'imageUrl': doc['imageUrl'],
          'manufacturer': doc['manufacturer'],
          'detailedImages': doc['detailedImages'],
        };
      }).toList();
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final index = _cart.indexWhere((item) => item['productId'] == product['productId']);
      if (index == -1) {
        _cart.add({
          ...product,
          'quantity': 1,
        });
      } else {
        _cart[index]['quantity']++;
      }
    });
  }

  double _calculateTotal() {
    double total = 0.0;
    _cart.forEach((item) {
      total += item['price'] * item['quantity'];
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('RomioShop', style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart),
                  if (_cart.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          '${_cart.length}',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 450),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_cart.isEmpty)
                                      const Center(child: Text('Giỏ hàng của bạn hiện tại không có sản phẩm.')),
                                    if (_cart.isNotEmpty)
                                      for (int i = 0; i < _cart.length; i++)
                                        Card(
                                          margin: const EdgeInsets.only(bottom: 8.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.all(10),
                                            title: Text(_cart[i]['name']),
                                            subtitle: Text('VND ${_cart[i]['price'].toStringAsFixed(2)} x ${_cart[i]['quantity']}'),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove, color: Colors.red),
                                                  onPressed: () {
                                                    if (_cart[i]['quantity'] > 1) {
                                                      setState(() {
                                                        _cart[i]['quantity']--;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _cart.removeAt(i);
                                                      });
                                                    }
                                                  },
                                                ),
                                                Container(
                                                  width: 30, // Set a fixed width to help with centering the quantity
                                                  child: Center(
                                                    child: Text(
                                                      '${_cart[i]['quantity']}',
                                                      style: const TextStyle(fontSize: 18),
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add, color: Colors.green),
                                                  onPressed: () {
                                                    setState(() {
                                                      _cart[i]['quantity']++;
                                                    });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.black),
                                                  onPressed: () {
                                                    setState(() {
                                                      _cart.removeAt(i);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    const SizedBox(height: 10),
                                    if (_cart.isNotEmpty)
                                      Text(
                                        'Tổng tiền: VND ${_calculateTotal().toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        backgroundColor: Colors.blue,
                                      ),
                                      onPressed: _cart.isNotEmpty
                                          ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentScreen(
                                              cartItems: _cart,
                                              totalAmount: _calculateTotal(),
                                            ),
                                          ),
                                        );
                                      }
                                          : null,
                                      child: const Text("Thanh toán"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Tìm kiếm sản phẩm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có sản phẩm nào.'));
                }

                final products = snapshot.data!;

                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
                  children: products.map((product) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productId: product['productId'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  product['imageUrl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              product['name'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'VND ${product['price'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () => _addToCart(product),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
