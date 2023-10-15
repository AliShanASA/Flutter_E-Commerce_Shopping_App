// ignore_for_file: unused_element, use_build_context_synchronously

import 'package:fashion_ecommerce_app/screens/LogInSignUp/user_account.dart';
import 'package:fashion_ecommerce_app/screens/category/category.dart';
import 'package:fashion_ecommerce_app/screens/LogInSignUp/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';

import 'model/base_model.dart';
import 'screens/cart/cart.dart';
import 'screens/home/home.dart';
import 'screens/search/search.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget/video_tutorial.dart';

class MainWrapper extends StatefulWidget {
  final bool isUserLoggedIn;

  const MainWrapper({Key? key, required this.isUserLoggedIn}) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final int _index = 0;
  bool isSearchActive = false;
  int cartItemCount = 0; // Track the number of items in the cart

  List<Widget> screens = [
    const Home(),
    const Search(),
  ];
DateTime? currentBackPressTime;
  @override
  void initState() {
    super.initState();
    getCartItemCount();
    _checkFirstTimeUser();
      
  }

  void getCartItemCount() async {
    
    int itemCount = await Cart.getCartItemCount();
    setState(() {
      cartItemCount = itemCount;
    });
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

  //========================================Shared preferences check user login is first time or not

  Future<void> _checkFirstTimeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;

    if (isFirstTimeUser) {
      // Show the tutorial dialog
      showDialog(
        context: context,
        builder: (_) => const TutorialDialog(),
      );

      // Mark the user as not a first-time user after they've seen the tutorial
      prefs.setBool('isFirstTimeUser', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUserLoggedIn = widget.isUserLoggedIn;
    List<BaseModel> products = [];

    const int x = 1;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(context, isUserLoggedIn),
        body: isSearchActive ? const Search() : const Home(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(
              109, 0, 140, 255), // Make the background transparent
          elevation: 0, // Remove the shadow
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            
            BottomNavigationBarItem(
                icon: Icon(Icons.category), label: 'Category'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Person'),
          ],
          currentIndex: _index,
          onTap: (index) {
            if (index == 3) {
              if (isUserLoggedIn) {
                FirebaseAuth auth = FirebaseAuth.instance;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserAccount(
                              email: auth.currentUser!.email ?? '',
                              username: auth.currentUser!.displayName ?? '',
                            )));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Login(
                              x: x,
                              fromWhere: 0,
                              data: products.isNotEmpty
                                  ? products[0]
                                  : BaseModel(
                                      id: 1,
                                      imageUrl: "imageUrl",
                                      name: "name",
                                      category: "category",
                                      price: 1.0,
                                      review: 1.2,
                                      value: 1,
                                      selectedSize: 1,
                                      selectedColor: 1,
                                      type: "",
                                      color: "None",
                                      season: 'None'
                                    ),
                            )));
              }
            } else if (index == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CategoryScreen(isUserLoggedIn: isUserLoggedIn)));
            } else if (index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Search()));
            } 
          },
    
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          iconSize: 20,
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isUserLoggedIn) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Home",
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  LineIcons.shoppingCart,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cart(
                        isUserLoggedIn: isUserLoggedIn,
                        isCameFromUser: false,
                      ),
                    ),
                  );
                },
              ),
              if (cartItemCount >= 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartItemCount.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    //===================================
  }
}
