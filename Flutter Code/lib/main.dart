// ignore_for_file: avoid_print, avoid_function_literals_in_foreach_calls, unused_import

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fashion_ecommerce_app/main_wrapper.dart';
import 'package:fashion_ecommerce_app/screens/SplashScreen/splash_screen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_theme.dart';

import 'model/base_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreferences.getInstance();
  Stripe.publishableKey =
      "pk_test_51NSDXeFhFNOnKMY7ATVTt1fYvaFx4Yv4DmErHR1wDVI1ixWLihD1d5m5znQMTDV4a6tg0fAD0UYSO6EDoSU9Ba1N00kJVuHfUA";

  updatePopularProducts();
  recommenderSystem();

  runApp(
    MaterialApp(
      theme: AppTheme.appTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    ),
  );
}

Future<void> updatePopularProducts() async {
  List<BaseModel> products = [];

  try {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('products2').get();

    for (final doc in snapshot.docs) {
      final BaseModel product = BaseModel.fromMap(doc.data());
      String name = product.name;
      print(name.toString());

      // Query "comments" collection to get the reviews for the current product
      final QuerySnapshot<Map<String, dynamic>> reviewsSnapshot =
          await FirebaseFirestore.instance
              .collection('comments')
              .doc(name)
              .collection('users')
              .get();

      double totalRating = 0;
      int totalCount = 0;

      // Calculate the total ratings and count of reviews
      reviewsSnapshot.docs.forEach((doc) {
        final double? rating = doc['x`'];
        if (rating != null) {
          totalRating += rating;
          totalCount++;
        }
      });

      double averageRating = totalCount > 0 ? totalRating / totalCount : 0;

      // Set the average rating for the product
      product.review = averageRating;

      // Add the product to the list
      products.add(product);
    }

    // Sort products based on average rating in descending order
    products.sort((a, b) => b.review.compareTo(a.review));

    // Save only the top 10 products to the "PopularProducts" collection
    final CollectionReference<Map<String, dynamic>> popularProductsCollection =
        FirebaseFirestore.instance.collection('PopularProducts');

    // Clear the existing documents in the "PopularProducts" collection
    await popularProductsCollection.get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    int count = products.length < 10 ? products.length : 10;

    for (int i = 0; i < count; i++) {
      await popularProductsCollection.add(products[i].toMap());
    }

    print('PopularProducts collection updated successfully.');
  } catch (e) {
    print('Error updating PopularProducts collection: $e');
  }

}

void recommenderSystem() async {
  // Step 1: Check if the user is logged in
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo;
      String model = '';
      try {
        androidInfo = await deviceInfo.androidInfo;
        model = androidInfo.model;
        print('Model: $model');
      } catch (e) {
        print('Error getting device info: $e');
      }

  

  String? userEmail = user?.email!;
  print(userEmail.toString());

  // Step 2: Fetch user data from Firestore
  CollectionReference userDataCollection;
  if(user == null){
    userDataCollection = FirebaseFirestore.instance
      .collection('GuestUsers')
      .doc(model)
      .collection('data');
  } else {
  userDataCollection = FirebaseFirestore.instance
      .collection('PastHistory')
      .doc('data')
      .collection(userEmail!);
  }

  QuerySnapshot userDocsSnapshot = await userDataCollection.get();

  if (userDocsSnapshot.docs.isEmpty) {
    print("User data not found.");
    return;
  }

  List<Map<String, dynamic>> products = [];

  for (QueryDocumentSnapshot productDoc in userDocsSnapshot.docs) {
    products.add(productDoc.data() as Map<String, dynamic>);
  }

  double totalPrice = 0.0;

  Map<String, double> categoryCount = {};
  Map<String, double> typeCount = {};
  Map<String, double> colorCount = {};

  // Step 3, 4, 5, 6: Process each product
  for (Map<String, dynamic> productData in products) {
    double productPrice = productData['price'] as double;
    totalPrice += productPrice;

    String category = productData['category'] as String;
    categoryCount.update(category, (value) => value + 1, ifAbsent: () => 1);

    String type = productData['type'] as String;
    typeCount.update(type, (value) => value + 1, ifAbsent: () => 1);
    String color = productData['color'] as String;
    colorCount.update(color, (value) => value + 1, ifAbsent: () => 1);
  }

  // Calculate average price
  double averagePrice = totalPrice / products.length;
  // Find the most repeated category
  String mostRepeatedCategory = categoryCount.keys
      .reduce((a, b) => categoryCount[a]! > categoryCount[b]! ? a : b);

  // Find the most repeated type
  String mostRepeatedType =
      typeCount.keys.reduce((a, b) => typeCount[a]! > typeCount[b]! ? a : b);

  // Find the most repeated color
  String mostRepeatedColor =
      colorCount.keys.reduce((a, b) => colorCount[a]! > colorCount[b]! ? a : b);
  // Print the results
  print("Color Count: $colorCount");
  print("Average Price: $averagePrice");

  print("Category Count: $categoryCount");
  print("Type Count: $typeCount");

  print("Categry: $mostRepeatedCategory");

  print("type: $mostRepeatedType");
  print("color: $mostRepeatedColor");

  // Assign numbers to category, type, and color
  Map<String, int> categoryNumberMap = {
    'Men': 1,
    'Women': 2,
    'Kid': 3,
  };

  Map<String, int> typeNumberMap = {
    'T-Shirts': 1,
    'Dress Shirt': 2,
    'Casual Shirts': 3,
    'Dress Pants': 4,
    'Jeans': 5,
    'Shorts': 6,
    'Suits': 7,
  };

  Map<String, int> colorNumberMap = {
    'Blue': 1,
    'Black': 2,
    'Brown': 3,
    'Green': 4,
    'White': 5,
    'Yellow': 6,
    'Orange': 7,
    'Sky': 8,
    'Pink': 9,
    'Purple': 10,
    'Grey': 11,
  };

  int categoryNumber = categoryNumberMap[mostRepeatedCategory] ?? 0;
  int colorNumber = colorNumberMap[mostRepeatedColor] ?? 0;
  int typeNumber = typeNumberMap[mostRepeatedType] ?? 0;

  List<double> customerInterestVector = [
    averagePrice,
    categoryNumber.toDouble(),
    colorNumber.toDouble(),
    typeNumber.toDouble()
  ];

  // Print the vector
  print("Vector: $customerInterestVector");

  // Fetch products data from collection "products2"
  CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products2');
  QuerySnapshot productsSnapshot = await productsCollection.get();

  // Create a list to store product recommendations
  List<Map<String, dynamic>> productRecommendations = [];

  // Loop through each product
  for (QueryDocumentSnapshot productDoc in productsSnapshot.docs) {
    Map<String, dynamic> productData =
        productDoc.data() as Map<String, dynamic>;

    // Create a product feature vector
    double productPrice = productData['price'] as double;
    String productCategory = productData['category'] as String;
    String productType = productData['type'] as String;
    String productColor = productData['color'] as String? ?? "";

    int productCategoryNumber = categoryNumberMap[productCategory] ?? 0;
    int productColorNumber = colorNumberMap[productColor] ?? 0;
    int productTypeNumber = typeNumberMap[productType] ?? 0;

    List<double> productFeatureVector = [
      productPrice,
      productCategoryNumber.toDouble(),
      productColorNumber.toDouble(),
      productTypeNumber.toDouble()
    ];

    // Calculate cosine similarity between customer interest vector and product feature vector
    double cosineSimilarity =
        calculateCosineSimilarity(customerInterestVector, productFeatureVector);

    // Save product ID and similarity score
    productRecommendations.add({
      'productId': productData[
          'id'], // Change 'id' to the actual attribute name in the product data
      'similarityScore': cosineSimilarity,
    });
  }

  // Sort product recommendations by similarity score in descending order
  productRecommendations
      .sort((a, b) => b['similarityScore'].compareTo(a['similarityScore']));

  // Get top 10 product IDs with highest similarity scores
  List<int> topProductIds = productRecommendations
      .take(10)
      .map((product) => product['productId'] as int)
      .toList();

  print(productRecommendations.toString());
  // Print the top recommended product IDs
  print("Top Recommended Product IDs: $topProductIds");

  // Fetch product details for top recommended products
  List<Map<String, dynamic>> recommendedProducts = [];
  for (int productId in topProductIds) {
    Map<String, dynamic>? productDetails = await getProductDetails(productId);
    if (productDetails != null) {
      recommendedProducts.add(productDetails);
    }
  }
  CollectionReference recommendedCollection;
  // Clear existing recommended products in Firestore
  if(user == null){
    recommendedCollection = FirebaseFirestore.instance
      .collection('GuestUsers')
      .doc(model)
      .collection('data');} else {
  recommendedCollection = FirebaseFirestore.instance
      .collection('Recommended')
      .doc('data')
      .collection(userEmail!);
      }
  QuerySnapshot existingProductsSnapshot = await recommendedCollection.get();
  for (QueryDocumentSnapshot docSnapshot in existingProductsSnapshot.docs) {
    await docSnapshot.reference.delete();
  }

  // Save recommended products in Firestore
  for (Map<String, dynamic> product in recommendedProducts) {
    recommendedCollection.add(product);
  }

  // Print the recommended products
  print("Recommended Products: $recommendedProducts");
}

double calculateCosineSimilarity(List<double> vector1, List<double> vector2) {
  double dotProduct = 0.0;
  double norm1 = 0.0;
  double norm2 = 0.0;

  for (int i = 0; i < vector1.length; i++) {
    dotProduct += vector1[i] * vector2[i];
    norm1 += vector1[i] * vector1[i];
    norm2 += vector2[i] * vector2[i];
  }

  if (norm1 == 0.0 || norm2 == 0.0) {
    return 0.0; // Handle division by zero
  }

  return dotProduct / (sqrt(norm1) * sqrt(norm2));
}

Future<Map<String, dynamic>?> getProductDetails(int productId) async {
  QuerySnapshot<Map<String, dynamic>> productsSnapshot = await FirebaseFirestore
      .instance
      .collection('products2')
      .where('id', isEqualTo: productId)
      .get();

  if (productsSnapshot.docs.isNotEmpty) {
    return productsSnapshot.docs.first.data();
  }

  return null;
}
