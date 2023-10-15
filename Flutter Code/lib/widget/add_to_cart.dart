// ignore_for_file: use_build_context_synchronously

import 'package:advance_notification/advance_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/base_model.dart';

class AddToCart {
  static final CollectionReference<Map<String, dynamic>> _cartCollection =
      FirebaseFirestore.instance.collection('UsersCartData');

  static void addToCart(
    BaseModel data,
    BuildContext context,
    int selectedSize,
    int selectedColor,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in, display a message to log in first
      const AdvanceSnackBar(
        textSize: 14.0,
        bgColor: Colors.red,
        message: 'Please log in to add items to your cart',
        mode: Mode.ADVANCE,
        duration: Duration(seconds: 5),
      ).show(context);
      return;
    }

    String userEmail = user.email ?? '';

    // Check if the item is already in the user's cart with the same name, size, and color
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cartCollection
        .doc(userEmail)
        .collection('cartItems')
        .where('name', isEqualTo: data.name)
        .where('selectedSize', isEqualTo: selectedSize)
        .where('selectedColor', isEqualTo: selectedColor)
        .get();

    bool contains = querySnapshot.docs.isNotEmpty;

    if (contains) {
      const AdvanceSnackBar(
        textSize: 14.0,
        bgColor: Colors.red,
        message: 'You have added this item to the cart before',
        mode: Mode.ADVANCE,
        duration: Duration(seconds: 5),
      ).show(context);
    } else {
      data.selectedSize = selectedSize;
      data.selectedColor = selectedColor;

      // Save the item to Firestore under the user's cart collection
      try {
        await _cartCollection
            .doc(userEmail)
            .collection('cartItems')
            .add(data.toMap());
        const AdvanceSnackBar(
          textSize: 14.0,
          message: 'Successfully added to your cart',
          mode: Mode.ADVANCE,
          duration: Duration(seconds: 5),
        ).show(context);
      } catch (e) {
        // Failed to save the item to Firestore
        debugPrint('Error adding item to cart: $e');
        const AdvanceSnackBar(
          textSize: 14.0,
          bgColor: Colors.red,
          message: 'Failed to add item to cart. Please try again.',
          mode: Mode.ADVANCE,
          duration: Duration(seconds: 5),
        ).show(context);
      }
    }
  }
}
