class Product {
  final int id;
  final String productName;
  final String categoryName;
  final int subCategoryId;
  final String imageUrl;
  // final List<String> imageUrls; // list of images, never null
  final String sellingPrice;
  final String slug;

  Product({
    required this.id,
    required this.productName,
    required this.categoryName,
    required this.subCategoryId,
    required this.imageUrl,
    // required this.imageUrls,
    required this.sellingPrice,
    required this.slug,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productName: json['product_name'],
      categoryName: json['category_name'],
      subCategoryId: json['sub_category_id'],
      imageUrl: json['image_url'],
      // imageUrls: json['image_urls'] != null
      //     ? List<String>.from(json['image_urls'])
      //     : [], // if null, assign empty list
      sellingPrice: json['selling_price'],
      slug: json['slug'],
    );
  }
}
