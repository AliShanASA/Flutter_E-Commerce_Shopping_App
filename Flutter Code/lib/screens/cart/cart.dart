// ignore_for_file: deprecated_member_use, prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fashion_ecommerce_app/screens/LogInSignUp/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:http/http.dart' as http;

import '../../widget/reuseable_row_for_cart.dart';
import '../../model/base_model.dart';
import '../../utils/constants.dart';
import '../../widget/reuseable_button.dart';

class Cart extends StatefulWidget {
  final bool isUserLoggedIn;
  final bool isCameFromUser;

  const Cart(
      {Key? key, required this.isUserLoggedIn, required this.isCameFromUser})
      : super(key: key);
  bool get getIsUserLoggedIn => isUserLoggedIn;
  bool get getIsCameFromUser => isCameFromUser;

  static Future<int> getCartItemCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference<Map<String, dynamic>> cartItemsCollection =
          FirebaseFirestore.instance
              .collection('UsersCartData')
              .doc(user.email)
              .collection('cartItems');

      var snapshot = await cartItemsCollection.get();
      int itemCount = snapshot.docs.length;

      return itemCount;
    } else {
      return 0; // Return 0 if user is not logged in
    }
  }

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  Map<String, dynamic>? paymentIntent;
  late User? user;
  CollectionReference<Map<String, dynamic>>? _cartItemsCollection;
  List<BaseModel> itemsOnCart = [];
  bool deleting = false;

  @override
  void initState() {
    super.initState();
    print(widget.getIsCameFromUser.toString());
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _cartItemsCollection = FirebaseFirestore.instance
          .collection('UsersCartData')
          .doc(user!.email)
          .collection('cartItems');
    }
    loadCartItems();
  }

  Future<void> loadCartItems() async {
    if (_cartItemsCollection != null) {
      var snapshot = await _cartItemsCollection?.get();
      if (snapshot != null && snapshot.docs.isNotEmpty) {
        setState(() {
          itemsOnCart = snapshot.docs
              .map((doc) => BaseModel.fromMap(doc.data()))
              .toList();
        });
      }
    }
  }

  /// delete function for cart
  Future<void> onDelete(BaseModel data) async {
    setState(() {
      if (itemsOnCart.length == 1) {
        itemsOnCart.clear();
      } else {
        itemsOnCart.removeWhere((element) => element.name == data.name);
      }
    });

    if (_cartItemsCollection != null) {
      await _cartItemsCollection!
          .where('name', isEqualTo: data.name)
          .get()
          .then((snapshot) {
        if (snapshot.size > 0) {
          snapshot.docs.first.reference.delete();
        }
      });
    }
  }

  /// Calculate Shipping
  double calculateShipping() {
    double shipping = 0.0;
    if (itemsOnCart.isEmpty) {
      shipping = 0.0;
      return shipping;
    } else if (itemsOnCart.length <= 4) {
      shipping = 0;
      return shipping;
    } else {
      shipping = 0.0;
      return shipping;
    }
  }

  /// Calculate the Total Price
  double calculateTotalPrice() {
    double total = 0.0;
    for (BaseModel data in itemsOnCart) {
      total += data.price * data.value;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  //Stripe

  void makePayment() async {
    double totalPrice = calculateTotalPrice();
    if (totalPrice == 0.0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Item'),
            content: const Text('Please add items to the cart for checkout.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  ); // Close the dialog
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          );
        },
      );
    } else {
      try {
        paymentIntent = await createPaymentIntent(totalPrice);
        var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: 'US',
          currencyCode: 'USD',
          testEnv: true,
        );
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!["client_secret"],
            style: ThemeMode.light,
            merchantDisplayName: "Ali Shan",
            googlePay: gpay,
          ),
        );
        displayPaymentSheet();
      } catch (e) {
        print("e.toString()");
      }
    }
  }

  String generateOrderNumber() {
    final int randomNumber = DateTime.now().microsecondsSinceEpoch % 10000;
    return randomNumber.toString().padLeft(6, '0');
  }

  void displayPaymentSheet() async {
    try {
      // Present the payment sheet using Stripe SDK
      await Stripe.instance.presentPaymentSheet();
      print("Payment Done");
      // Fetch the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No authenticated user found");
        return;
      }

      // Get the user's cart data from "UsersCartData" collection
      final cartDataSnapshot = await FirebaseFirestore.instance
          .collection("UsersCartData")
          .doc(user.email)
          .get();

      // Get the cart items from the "cartItems" collection
      final cartItemsSnapshot =
          await cartDataSnapshot.reference.collection("cartItems").get();
      final cartItems = cartItemsSnapshot.docs;

      // Save the cart items as orders in the "orders" collection
      final batch = FirebaseFirestore.instance.batch();
      final ordersCollectionRef =
          FirebaseFirestore.instance.collection("orders");
      final completedOrderCollectionRef =
          FirebaseFirestore.instance.collection("CompletedOrders");
      final shippingAddressSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final shippingAddress = shippingAddressSnapshot.data();
      final ordersCollectionRefForAdmin =
          FirebaseFirestore.instance.collection("OrdersForAdmin");
      final orderNumber = generateOrderNumber();
      final currentTime = FieldValue.serverTimestamp();
      bool isCompleted = false;
      for (final item in cartItems) {
        final productData = item.data();
        final productName = productData["name"];
        final orderData = {
          "productName": productName,
          "orderNo": orderNumber,
          "imageUrl": productData["imageUrl"],
          "price": productData["price"],
          "selectedSize": productData["selectedSize"],
          "selectedColor": productData["selectedColor"],
          "value": productData["value"],
          "timestamp": currentTime,
          "isCompleted": isCompleted,
        };

        // Create a new document with a unique ID for each order in the "data" collection
        final newOrderDocRef =
            ordersCollectionRef.doc(user.email).collection("data").doc();
        batch.set(newOrderDocRef, orderData);
        //saving data for completed orders
        final newOrderDocRefCompleted = completedOrderCollectionRef
            .doc(user.email)
            .collection("data")
            .doc();
        batch.set(newOrderDocRefCompleted, orderData);

        final orderDataForAdmin = {
          "orderNo": orderNumber,
          "imageUrl": productData["imageUrl"],
          "price": productData["price"],
          "selectedSize": productData["selectedSize"],
          "selectedColor": productData["selectedColor"],
          "value": productData["value"],
          "shippingAddress": shippingAddress![
              "shippingAddress"], // Include the user's shipping address data
          "userName": user.displayName,
          "userEmail": user.email,
          "productName": productData["name"],
          "timestamp": currentTime,
          "isCompleted": isCompleted,
        };

        // Create a new document with a unique ID for each order in the "data" collection
        final newOrderDocRefA = ordersCollectionRefForAdmin.doc();
        batch.set(newOrderDocRefA, orderDataForAdmin);
      }

      await batch.commit();
      print("Orders saved successfully");

      final CollectionReference<Map<String, dynamic>> usersCartCollection =
          FirebaseFirestore.instance.collection('UsersCartData');

// Clear the cart items in the "UsersCartData" collection for the current user
       usersCartCollection
          .doc(user.email)
          .collection('cartItems')
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Successful'),
            content: const Text('Order Completed!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Payment Failed: $e");
    }
  }

  createPaymentIntent(double totalPrice) async {
    try {
      Map<String, dynamic> body = {
        "amount": (totalPrice * 100).toInt().toString(), // Amount in cents
        "currency": "USD"
      };
      http.Response response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization":
                "Bearer sk_test_51NSDXeFhFNOnKMY7VKy6VBColXafNrOta24M93kAGjmTU0QsvCP5mNFpRJ3DJ0eImOEggglXeBDxYUrzUWDmm0HO00rfOr48aR",
            "Content-Type": "application/x-www-form-urlencoded",
          });
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    bool isUserLoggedIn = widget.getIsUserLoggedIn;
    const int x = 2;
    final List<BaseModel> products = [];

    return Scaffold(
      appBar: _buildAppBar(context, isUserLoggedIn),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/account_background1.jpg'),
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
          ),
        ),
        SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              SizedBox(
                width: size.width,
                height: size.height * 0.6,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _cartItemsCollection?.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var documents = snapshot.data?.docs;
                      itemsOnCart = documents
                              ?.map((doc) => BaseModel.fromMap(doc.data()))
                              .toList() ??
                          [];

                      return itemsOnCart.isEmpty
                          ? Column(
                              children: [
                                SizedBox(height: size.height * 0.02),
                                FadeInUp(
                                  delay: const Duration(milliseconds: 200),
                                  child: const Image(
                                    image:
                                        AssetImage("assets/images/empty.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                FadeInUp(
                                  delay: const Duration(milliseconds: 250),
                                  child: const Text(
                                    "Your cart is empty right now :(",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: itemsOnCart.length,
                              itemBuilder: (context, index) {
                                var current = itemsOnCart[index];
                                return FadeInUp(
                                  delay:
                                      Duration(milliseconds: 100 * index + 80),
                                  child: Container(
                                    margin: const EdgeInsets.all(5.0),
                                    width: size.width,
                                    height: size.height * 0.25,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                offset: Offset(0, 4),
                                                blurRadius: 4,
                                                color:
                                                    Color.fromARGB(61, 0, 0, 0),
                                              )
                                            ],
                                            color: Colors.pink,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    current.imageUrl),
                                                fit: BoxFit.cover),
                                          ),
                                          width: size.width * 0.4,
                                        ),
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: size.width * 0.52,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          current.name,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          onDelete(current);
                                                        },
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    text: "\$",
                                                    style: textTheme.subtitle2
                                                        ?.copyWith(
                                                      fontSize: 22,
                                                      color: primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: current.price
                                                            .toString(),
                                                        style: textTheme
                                                            .subtitle2
                                                            ?.copyWith(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.02,
                                                ),
                                                Text(
                                                  "Size = ${sizes[current.selectedSize]}",
                                                  style: textTheme.subtitle2
                                                      ?.copyWith(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  "Color = ${colors2[current.selectedColor]}",
                                                  style: textTheme.subtitle2
                                                      ?.copyWith(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.001,
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    top: size.height * 0.04,
                                                  ),
                                                  width: size.width * 0.4,
                                                  height: size.height * 0.04,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(4.0),
                                                        width:
                                                            size.width * 0.065,
                                                        height:
                                                            size.height * 0.045,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              if (current
                                                                      .value >
                                                                  1) {
                                                                current.value--;
                                                              } else {
                                                                onDelete(
                                                                    current);
                                                                current.value =
                                                                    1;
                                                              }
                                                            });
                                                            updateCartItemValue(
                                                                current);
                                                          },
                                                          child: const Icon(
                                                            Icons.remove,
                                                            size: 16,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              size.width * 0.02,
                                                        ),
                                                        child: Text(
                                                          current.value
                                                              .toString(),
                                                          style: textTheme
                                                              .subtitle2
                                                              ?.copyWith(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(4.0),
                                                        width:
                                                            size.width * 0.065,
                                                        height:
                                                            size.height * 0.045,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              current.value++;
                                                              debugPrint(current
                                                                  .value
                                                                  .toString());
                                                            });
                                                            updateCartItemValue(
                                                                current);
                                                          },
                                                          child: const Icon(
                                                            Icons.add,
                                                            size: 16,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                    } else {
                      return Column(
                        children: [
                          SizedBox(height: size.height * 0.02),
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: const Image(
                              image: AssetImage("assets/images/empty.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          FadeInUp(
                            delay: const Duration(milliseconds: 250),
                            child: const Text(
                              "Your cart is empty right now :(\nPlease Log in to add items to your cart.",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),

              /// Bottom Card
              Positioned(
                bottom: 0,
                child: SizedBox(
                  width: size.width,
                  height: size.height * 0.3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 12.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          FadeInUp(
                            delay: const Duration(milliseconds: 350),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Payment Details",
                                  style: textTheme.headline3
                                      ?.copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          FadeInUp(
                            delay: const Duration(milliseconds: 450),
                            child: ReuseableRowForCart(
                              price: calculateShipping(),
                              text: 'Shipping',
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Divider(),
                          ),
                          FadeInUp(
                            delay: const Duration(milliseconds: 500),
                            child: ReuseableRowForCart(
                              price: calculateTotalPrice(),
                              text: 'Total',
                            ),
                          ),
                          FadeInUp(
                            delay: const Duration(milliseconds: 550),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: ReuseableButton(
                                text: "Checkout",
                                onTap: () async {
                                  if (isUserLoggedIn) {
                                    makePayment();
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Login Required'),
                                          content: const Text(
                                              'Please log In to complete Check out process.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Login(
                                                              x: x,
                                                              fromWhere: 0,
                                                              data: products
                                                                      .isNotEmpty
                                                                  ? products[0]
                                                                  : BaseModel(
                                                                      id: 1,
                                                                      imageUrl:
                                                                          "imageUrl",
                                                                      name:
                                                                          "name",
                                                                      category:
                                                                          "category",
                                                                      price:
                                                                          1.0,
                                                                      review:
                                                                          1.2,
                                                                      value: 1,
                                                                      selectedSize:
                                                                          1,
                                                                      selectedColor:
                                                                          1,
                                                                      type: "",
                                                                      color:
                                                                          "None",
                                                                      season: 'None'
                                                                    ),
                                                            ))); // Close the dialog
                                              },
                                              child: const Text(
                                                'Log In',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isUserLoggedIn) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "My Cart",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          
            Navigator.pop(context);
         
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> updateCartItemValue(BaseModel current) async {
    if (_cartItemsCollection != null) {
      await _cartItemsCollection!
          .where('name', isEqualTo: current.name)
          .get()
          .then((snapshot) {
        if (snapshot.size > 0) {
          snapshot.docs.first.reference.update({'value': current.value});
        }
      });
    }
  }
}
