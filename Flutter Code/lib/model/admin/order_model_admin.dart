// ignore_for_file: unnecessary_null_comparison

class CustomerOrders {
  final String orderNo;
  final String itemPic;
  final int quantity;
  final double totalPrice;
  final int color;
  final int size;
  final String shippingAddress;
  final String userName;
  final String userEmail;
  final String productName;

  CustomerOrders({
    required this.color,
    required this.size,
    required this.orderNo,
    required this.itemPic,
    required this.quantity,
    required this.totalPrice,
    required this.shippingAddress,
    required this.userName,
    required this.userEmail,
    required this.productName,
  }) : assert(itemPic != null);

  // Factory constructor to create a RecentOrder object from a map of data
  factory CustomerOrders.fromMap(Map<String, dynamic> map) {
    return CustomerOrders(
      orderNo: map['orderNo'] as String? ?? "",
      itemPic: map['imageUrl'] as String? ?? "",
      quantity: map['value'] as int? ?? 0,
      totalPrice: (map['price'] as num? ?? 0.0).toDouble(),
      color: map['selectedColor'] as int? ?? 0,
      size: map['selectedSize'] as int? ?? 0,
      shippingAddress: map['shippingAddress'] as String? ?? "",
      userName: map['userName'] as String? ?? "",
      userEmail: map['userEmail'] as String? ?? "",
      productName: map['productName'] as String? ?? "",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'orderNo': orderNo,
      'imageUrl': itemPic,
      'value': quantity,
      'price': totalPrice,
      'selectedColor': color,
      'selectedSize': size,
      'shippingAddress': shippingAddress,
      'userName': userName,
      'userEmail': userEmail,
      'productName': productName,
    };
  }
}
