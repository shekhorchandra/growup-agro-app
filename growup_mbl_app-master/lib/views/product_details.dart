import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:growup_agro/models/product_details_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_order_model.dart';
// import 'product_details.model.dart';
// import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailsPage extends StatefulWidget {
  final String slug; // Add slug

  const ProductDetailsPage({super.key, required this.slug});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}


class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<ProductDetailsResponse> _futureProduct;

  @override
  void initState() {
    super.initState();
    _futureProduct = fetchProductDetails();
  }

  Future<ProductDetailsResponse> fetchProductDetails() async {
    final response = await http.get(
      Uri.parse(
          "https://admin-growup.onebitstore.site/api/product-details/${widget.slug}"),
    );

    if (response.statusCode == 200) {
      return ProductDetailsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load product details");
    }
  }

  Future<void> placeOrder(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final investorCode = prefs.getString('investor_code') ?? '';

      final response = await http.post(
        Uri.parse("https://admin-growup.onebitstore.site/api/place-order"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "investor_code": investorCode,
          "product_id": product.id,
          "total_price": int.tryParse(product.sellingPrice.toString()) ?? 0,
          //"billing_address": "123 Green Road, Dhaka",
          "comment": "Deliver between 9am–12pm"
        }),
      );

      final jsonData = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order placed successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${jsonData['message'] ?? response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details", style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ProductDetailsResponse>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No product found"));
          }

          final product = snapshot.data!.data.product;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image carousel
                    if (product.imageUrls.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 250,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          viewportFraction: 0.9,
                        ),
                        items: product.imageUrls.map((url) {
                          return ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              "https://admin-growup.onebitstore.site$url",
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),

                    // Product info
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(product.productName,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                            const SizedBox(height: 6),
                            Text("Category: ${product.categoryName}",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700])),
                            const SizedBox(height: 12),
                            Html(data: product.metaDescription),
                            const SizedBox(height: 12),

                            // Video embed
                            // Html(
                            //   data: product.videoEmbedHtml,
                            // ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(),

                    // Card footer
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Product: ${product.productName}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                            Text("Category: ${product.categoryName}"),
                            Text("Price: ${product.sellingPrice}"),
                            Text("Available: ${product.inStock} ${product.stockUnit}"),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      title: Center(
                                        child: const Text(
                                          "Place Order",
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text("Payment Method: Cash on Delivery."),
                                          const Text("Pay with cash upon delivery."),
                                          const SizedBox(height: 8),
                                          Text("Price: ৳ ${product.sellingPrice}"),
                                        ],
                                      ),
                                      actionsAlignment: MainAxisAlignment.spaceEvenly, // evenly space
                                      actions: [
                                        SizedBox(
                                          width: 130,
                                          height: 45,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close dialog
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        SizedBox(
                                          width: 130,
                                          height: 45,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop(); // Close dialog
                                              await placeOrder(product); // API call
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            child: const Text(
                                              "Place Order",
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'Buy Now',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
