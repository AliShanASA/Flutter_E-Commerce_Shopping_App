// ignore_for_file: deprecated_member_use, avoid_function_literals_in_foreach_calls, avoid_print, unused_import, unused_field

import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fashion_ecommerce_app/main_wrapper.dart';

import 'package:fashion_ecommerce_app/screens/LogInSignUp/login.dart';
import 'package:fashion_ecommerce_app/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../model/base_model.dart';
import '../../widget/add_to_cart.dart';
import '../LogInSignUp/user_account.dart';
import '../ProductDetail/details.dart';
import '../cart/cart.dart';
import '../search/search.dart';
import 'category.dart';

class MostPopular extends StatefulWidget {
  final bool isUserLoggedIn;
  const MostPopular({Key? key, required this.isUserLoggedIn}) : super(key: key);
  bool get getIsUserLoggedIn => isUserLoggedIn;

  @override
  State<MostPopular> createState() => _MostPopularState();
}

class _MostPopularState extends State<MostPopular>
    with SingleTickerProviderStateMixin {
  List<BaseModel> products = [];
  bool isSearchActive = false;
  final int _index = 1;
  Set<Object> usedTags = {};
  bool _isDisposed = false;
  int cartItemCount = 0;


  void getCartItemCount() async {
    // Call the getCartItemCount method in the Cart class to retrieve the item count
    int itemCount = await Cart.getCartItemCount();
    setState(() {
      cartItemCount = itemCount;
    });
  }

  @override
  void initState() {
    super.initState();
    getCartItemCount();
    fetchData().then((data) {
      if (!_isDisposed) {
        // Check if the widget is still mounted
        setState(() {
          products = data;
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    bool isUserLoggedIn = widget.getIsUserLoggedIn;
    int selectedSize = 1;
    int selectedColor = 1;
    const int x0 = 0;
    
    const bool isCameFromLogIn = false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, isUserLoggedIn),
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
          currentIndex: 0,
          onTap: (index) {
            if (index == 2) {
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
                              x: 13,
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
      body: Stack(

        children: [
           Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/account_background1.jpg'),
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
          ),
        ),
          CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.63,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  BaseModel current = products[index];
                  Object tag = ObjectKey(current.id);
                  // Ensure the tag is unique
                  if (usedTags.contains(tag)) {
                    // Generate a new unique tag if there is a conflict
                    tag = ObjectKey('${current.id}_$index');
                  } else {
                    // Add the tag to the usedTags set
                    usedTags.add(tag);
                  }
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Details(
                            data: current,
                            isCameFromMostPopularPart: true,
                            isUserLoggedIn: isUserLoggedIn,
                            isCameFromLogIn: isCameFromLogIn,
                            fromWhere: 3,
                          ),
                        ),
                      ),
                      child: Hero(
                        tag: tag,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: size.height * 0.02,
                              left: size.width * 0.01,
                              right: size.width * 0.01,
                              child: Container(
                                width: size.width * 0.5,
                                height: size.height * 0.28,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  image: DecorationImage(
                                    image: NetworkImage(current.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      offset: Offset(0, 4),
                                      blurRadius: 4,
                                      color: Color.fromARGB(61, 0, 0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: size.height * 0.04,
                              child: Text(
                                current.name,
                                style: textTheme.headline2,
                              ),
                            ),
                            Positioned(
                              bottom: size.height * 0.01,
                              child: RichText(
                                text: TextSpan(
                                  text: "\$",
                                  style: textTheme.subtitle2?.copyWith(
                                    color: primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: current.price.toString(),
                                      style: textTheme.subtitle2?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: size.height * 0.01,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: primaryColor,
                                child: IconButton(
                                  onPressed: () {
                                    if (isUserLoggedIn) {
                                      AddToCart.addToCart(
                                        current,
                                        context,
                                        selectedSize,
                                        selectedColor,
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Login Required'),
                                            content: const Text(
                                                'Please log in to add items to your cart.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      color: Colors.orange),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Login(
                                                                fromWhere: 0,
                                                                x: x0,
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
                                                      color: Colors.orange),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    LineIcons.addToShoppingCart,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: products.length,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Future<List<BaseModel>> fetchData() async {
    List<BaseModel> products = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('PopularProducts').get();

      snapshot.docs.forEach((doc) {
        BaseModel product = BaseModel.fromMap(doc.data());

        // Filter the products to only include the most popular ones

        products.add(product);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }

    return products;
  }

   AppBar _buildAppBar(BuildContext context, bool isUserLoggedIn) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Popular Products",
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
      Navigator.pop(context);
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
