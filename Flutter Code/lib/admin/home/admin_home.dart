// ignore_for_file: deprecated_member_use, avoid_print, unused_import, unused_element

import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:fashion_ecommerce_app/admin/customers/manage_customers.dart';
import 'package:fashion_ecommerce_app/admin/orders/manage_orders.dart';
import 'package:fashion_ecommerce_app/admin/products/manage_products.dart';
import 'package:fashion_ecommerce_app/model/base_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../screens/LogInSignUp/login.dart';
import '../../utils/constants.dart';
import '../dashboard/dashboard.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
 // final int _index = 0;
  DateTime? currentBackPressTime;

  // Function to navigate to the "Person" screen
  void _navigateToPersonScreen() {
    // Add navigation logic for the "Person" screen here
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: _buildAppBar(context, ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(
              109, 0, 140, 255), // Make the background transparent
          elevation: 0, // Remove the shadow
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Admin'),
          
          ],
          currentIndex: 0,
          onTap: (index) {
            if (index == 1) {
               Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminProfile(
                          email: 'admin.smart@gmail.com',
                          username: 'Techard Ltd',
                        )));
            }
          },
    
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          iconSize: 20,
        ), 
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/account_background1.jpg'),
                  fit: BoxFit.cover, // Adjust the fit as needed
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: "Smart",
                                style: textTheme.headline1,
                                children: [
                                  TextSpan(
                                    text: " Shopping",
                                    style: textTheme.headline1?.copyWith(
                                      color: Colors.blue,
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: RichText(
                              text: const TextSpan(
                                text: "Manage the app ",
                                style: TextStyle(
                                  color: Color.fromARGB(186, 0, 0, 0),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: "freely :)",
                                  ),
                                ],
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
            Positioned.fill(
              top: size.height * 0.10, // Adjust the value as needed
              child: FadeIn(
                delay: const Duration(milliseconds: 1500),
                child: GridView.count(
                  crossAxisCount: 1,
                  padding: const EdgeInsets.all(16.0),
                  childAspectRatio: 1.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    // buildMenuButton(context, 'Dashboard', () {}),
                    buildMenuButton(context, 'Manage Products', () {
                      // Add navigation logic for Products here
                    }),
                    buildMenuButton(context, 'Manage Orders', () {
                      // Add navigation logic for Orders here
                    }),
                    // buildMenuButton(context, 'Feedbacks', () {
                    //   // Add navigation logic for Customers here
                    // }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
     
      // floatingActionButton: FadeIn(
      //   delay: const Duration(milliseconds: 2000),
      //   child: ElevatedButton(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: const Color.fromARGB(255, 255, 131, 54),
      //       padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
      //     ),
      //     onPressed: (){},
      //     child: const Text(
      //       'Log Out',
      //       style: TextStyle(
      //         fontSize: 20,
      //       ),
      //     ),
      //   ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // void _logOut() {
  //   const int x = 1;
  //   final List<BaseModel> products = [];
  //   FirebaseAuth.instance.signOut().then((_) {
  //     // Log out successful, navigate to login screen
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => Login(
  //                 fromWhere: 0,
  //                 x: x,
  //                 data: products.isNotEmpty
  //                     ? products[0]
  //                     : BaseModel(
  //                         id: 1,
  //                         imageUrl: "imageUrl",
  //                         name: "name",
  //                         category: "category",
  //                         price: 1.0,
  //                         review: 1.2,
  //                         value: 1,
  //                         selectedSize: 1,
  //                         selectedColor: 1,
  //                         type: "None",
  //                         season: 'None',
  //                         color: "None",
  //                       ),
  //               )),
  //     );
  //   }).catchError((error) {
  //     // Handle logout error if necessary
  //     print('Logout error: $error');
  //   });
  // }

  Widget buildMenuButton(
      BuildContext context, String title, void Function()? onPressed) {
    return FadeIn(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: onPressed != null
              ? () {
                  if (title == 'Manage Products') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageProducts(),
                      ),
                    );
                  } else if (title == 'Manage Orders') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageOrders(),
                      ),
                    );
                  } else {
                    print("NO data found");
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 50, 160, 238),
            padding:
                const EdgeInsets.all(10.0), // Adjust padding for smaller size
            minimumSize: const Size(80, 40), // Adjust as needed
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22.0, // Adjust font size for smaller size
              color: Colors.white,
              inherit: false, // Set the inherit property to false
            ),
          ),
        ),
      ),
    );
  }
   AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Admin Dashboard",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
    icon: const Icon(
      Icons.arrow_back, // Use the back arrow icon
      color: Colors.white,
      size: 30,
    ),
    onPressed: () {
      _onWillPop;
    },
  ),
     
    );

  }
  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Press back again to exit."),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    } else {
      // Show a confirmation dialog for exit
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Exit'),
              content:
                  const Text('Are you sure you want to exit the application?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancel the exit
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    SystemNavigator.pop();
                    // Confirm the exit
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
          ) ??
          false;
    }
  }
}
