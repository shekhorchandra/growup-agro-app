class ProductDetailsResponse {
  final String status;
  final String message;
  final ProductData data;

  ProductDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResponse(
      status: json['status'],
      message: json['message'],
      data: ProductData.fromJson(json['data']),
    );
  }
}

class ProductData {
  final Product product;

  ProductData({required this.product});

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      product: Product.fromJson(json['product']),
    );
  }
}

class Product {
  final int id;
  final String productName;
  final String slug;
  final int subCategoryId;
  final String subCategoryName;
  final String categoryName;
  final List<String> imageUrls;
  final String sellingPrice;
  final String videoEmbedHtml;
  final String metaDescription;
  final int inStock;
  final String stockUnit;
  final List<String> tags;

  Product({
    required this.id,
    required this.productName,
    required this.slug,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.categoryName,
    required this.imageUrls,
    required this.sellingPrice,
    required this.videoEmbedHtml,
    required this.metaDescription,
    required this.inStock,
    required this.stockUnit,
    required this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productName: json['product_name'],
      slug: json['slug'],
      subCategoryId: json['sub_category_id'],
      subCategoryName: json['sub_category_name'],
      categoryName: json['category_name'],
      imageUrls: List<String>.from(json['image_urls']),
      sellingPrice: json['selling_price'],
      videoEmbedHtml: json['video_embed_html'],
      metaDescription: json['meta_description'],
      inStock: json['in_stock'],
      stockUnit: json['stock_unit'],
      tags: List<String>.from(json['tags']),
    );
  }
}
