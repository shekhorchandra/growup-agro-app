class OrderResponse {
  final bool status;
  final String message;
  final List<Order> data;

  OrderResponse({required this.status, required this.message, required this.data});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      status: json['status'] == "success",
      message: json['message'] ?? "",
      data: (json['data'] as List).map((e) => Order.fromJson(e)).toList(),
    );
  }
}

class Order {
  final int serial;
  final int invoiceNo;
  final String orderDate;
  final String productName;
  final int quantity;
  final int totalPayable;
  final int paidAmount;
  final String status;

  Order({
    required this.serial,
    required this.invoiceNo,
    required this.orderDate,
    required this.productName,
    required this.quantity,
    required this.totalPayable,
    required this.paidAmount,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      serial: json['serial'],
      invoiceNo: json['invoice_no'],
      orderDate: json['order_date'],
      productName: json['product_name'],
      quantity: json['quantity'],
      totalPayable: json['total_payable'],
      paidAmount: json['paid_amount'],
      status: json['status'],
    );
  }
}
