// ignore_for_file: prefer_const_declarations, no_leading_underscores_for_local_identifiers, avoid_function_literals_in_foreach_calls, avoid_print, await_only_futures, unused_local_variable, depend_on_referenced_packages

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/screens/ReviewsAndRatings/reviews_ratings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main_wrapper.dart';
import '../../model/order_model.dart';

import '../category/category.dart';
import '../search/search.dart';

class CompletedOrders extends StatefulWidget {
  const CompletedOrders({super.key});

  @override
  State<CompletedOrders> createState() => _CompletedOrdersState();
}

class _CompletedOrdersState extends State<CompletedOrders> {
  List<RecentOrder> _recentOrders = [];

  Future<List<RecentOrder>> fetchData() async {
    final user = await FirebaseAuth.instance.currentUser;
    List<RecentOrder> products = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('CompletedOrders')
          .doc(user?.email)
          .collection("data")
          .where('isCompleted',
              isEqualTo: true) // Filter for isCompleted = false
          .get();

      snapshot.docs.forEach((doc) {
        RecentOrder product = RecentOrder.fromMap(doc.data());
        products.add(product);
      });
      print("Data Fetched Successful");
    } catch (e) {
      print('Error fetching data: $e');
    }

    return products;
  }

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        _recentOrders = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(
            109, 0, 140, 255), // Make the background transparent
        elevation: 0, // Remove the shadow
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Category'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MainWrapper(
                  isUserLoggedIn: true,
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoryScreen(
                  isUserLoggedIn: true,
                ),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Search(),
              ),
            );
          }
        },

        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        iconSize: 20,
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/account_background1.jpg'),
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text(
                    "Completed Orders",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Orders History!'),
                            content: const Text(
                                'Are you sure you want to delete all orders?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  clearOrders();
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      "Clear History",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FadeIn(
                delay: const Duration(milliseconds: 800),
                child: _recentOrders.isEmpty
                    ? const Center(
                        child: Text(
                          "No orders completed yet!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _recentOrders.length,
                        itemBuilder: (context, index) {
                          final sizeString =
                              getSizeString(_recentOrders[index].size);
                          final colorString =
                              getColorString(_recentOrders[index].color);

                          final formattedDateTime =
                              DateFormat('yyyy-MM-dd        HH:mm:ss')
                                  .format(_recentOrders[index].dateTime);

                          return Column(
                            children: [
                              ListTile(
                                leading: Image.network(
                                  _recentOrders[index].itemPic,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                    "Item Name:   ${_recentOrders[index].itemName}"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Size:               $sizeString"),
                                    Text(
                                        "Quantity:      ${_recentOrders[index].quantity}"),
                                    Text("Color:              $colorString"),
                                    Text(
                                        "Price:              \$${_recentOrders[index].totalPrice}"),
                                    Text("Placed On:    $formattedDateTime"),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ReviewsRatings(
                                              itemPic:
                                                  _recentOrders[index].itemPic,
                                              itemName:
                                                  _recentOrders[index].itemName,
                                              price: _recentOrders[index]
                                                  .totalPrice)));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 210),
                                  child: Text(
                                    "Give Reviews and Ratings",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Completed Orders",
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(
            context,
          );
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.white,
        ),
      ),
    );
  }

  String getSizeString(int size) {
    switch (size) {
      case 0:
        return "S";
      case 1:
        return "M";
      case 2:
        return "L";
      case 3:
        return "XL";
      case 4:
        return "XXL";
      default:
        return "N/A";
    }
  }

  // Function to get the human-readable color based on the integer value
  String getColorString(int color) {
    switch (color) {
      case 0:
        return "White";
      case 1:
        return "Black";
      case 2:
        return "Blue";
      case 3:
        return "Green";
      case 4:
        return "Grey";
      case 5:
        return "Blue Grey";
      case 6:
        return "Yellow";
      default:
        return "N/A";
    }
  }

  Future<void> clearOrders() async {
    final user = await FirebaseAuth.instance.currentUser;
    try {
      final CollectionReference<Map<String, dynamic>> usersCartCollection =
          FirebaseFirestore.instance.collection('CompletedOrders');
      await usersCartCollection
          .doc(user?.email)
          .collection('data')
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      print('Order deleted successfully.');

      // Fetch updated orders after clearing
      fetchData().then((data) {
        setState(() {
          _recentOrders = data;
        });
      });
    } catch (e) {
      print('Error deleting order: $e');
    }
  }
}
