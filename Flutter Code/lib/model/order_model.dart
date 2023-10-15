// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';

class RecentOrder {
  final String orderNo;
  final String itemPic;
  final int quantity;
  final double totalPrice;
  final int color;
  final int size;
  final String itemName;
  final DateTime dateTime;
  final bool isCompleted;
  final String shippingAddress;
  final String userEmail; 
  // Add dateTime property

  RecentOrder({
    required this.color,
    required this.size,
    required this.orderNo,
    required this.itemPic,
    required this.quantity,
    required this.totalPrice,
    required this.itemName,
    required this.dateTime,
    required this.isCompleted,
    required this.shippingAddress,
    required this.userEmail,
  }) : assert(itemPic != null);

  factory RecentOrder.fromMap(Map<String, dynamic> map) {
    return RecentOrder(
      orderNo: map['orderNo'] as String? ?? "",
      itemPic: map['imageUrl'] as String? ?? "",
      quantity: map['value'] as int? ?? 0,
      totalPrice: (map['price'] as num? ?? 0.0).toDouble(),
      color: map['selectedColor'] as int? ?? 0,
      size: map['selectedSize'] as int? ?? 0,
      itemName: map['productName'] as String? ?? "",
      dateTime: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isCompleted: map['isCompleted']  as bool,
      shippingAddress: map['shippingAddress'] as String? ?? "",
       userEmail: map['userEmail'] as String? ?? "",// Provide a default value if dateTime is missing
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
      'productName': itemName,
      'timestamp': dateTime,
      'isCompleted' : isCompleted,
      'shippingAddress' : shippingAddress,
      'userEmail': userEmail,
    };
  }
}
