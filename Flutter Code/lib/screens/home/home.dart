// ignore_for_file: deprecated_member_use, avoid_function_literals_in_foreach_calls, avoid_print

import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fashion_ecommerce_app/screens/category/category.dart';
import 'package:fashion_ecommerce_app/screens/category/most_popular.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../data/app_data.dart';
import '../../widget/add_to_cart.dart';
import '../LogInSignUp/login.dart';
import '../ProductDetail/details.dart';

import '../../utils/constants.dart';
import '../../model/base_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<BaseModel> products = [];
  List<BaseModel> reProducts = [];
  List<BaseModel> toUse = [];
  List<BaseModel> popularProducts = [];

  late PageController _pageController;
  final int _currentIndex = 2;
  bool isUserLoggedIn = false;
  Set<Object> usedTags = {};

  List<String> carouselImages = [
   


    'assets/image2.png',
    'assets/image1.png',
   'assets/image3.jpeg',
    'assets/image4.jpg',

  ];

  @override
  void initState() {
    _pageController =
        PageController(initialPage: _currentIndex, viewportFraction: 0.7);
    checkUserLoggedIn().then((isLoggedIn) {
      setState(() {
        isUserLoggedIn = isLoggedIn;
      });
    });

    fetchData().then((data) {
      setState(() {
        products = data; // Move the call here
      });
    });

    fetchProducts().then((data) {
      setState(() {
        reProducts = data;
      });
    });

    fetchPopularProducts().then((data) {
      setState(() {
        popularProducts = data;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  Future<bool> checkUserLoggedIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    const bool isCameFromLogIn = false;
    int selectedSize = 1;
    int selectedColor = 1;

    return Scaffold(
      backgroundColor: Colors.white,
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
              SliverToBoxAdapter(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Text
                    const SizedBox(
                      height: 10,
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Smart",
                              style: textTheme.headline1,
                              children: [
                                TextSpan(
                                  text: " Shopping",
                                  style: textTheme.headline1?.copyWith(
                                    color: Colors.blueAccent,
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              //=====================================Carousal slider=============================
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    FadeInUp(
                      duration: const Duration(milliseconds: 900),
                      child: Stack(children: [
                        CarouselSlider.builder(
                          itemCount: carouselImages.length,
                          itemBuilder: (context, index, realIndex) {
                            final imagePath = carouselImages[index];
                            return GestureDetector(
                              onTap: () {
                                // Handle onTap as needed
                              },
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                          options: CarouselOptions(
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 1.0,
                          ),
                        ),
                      ]),
                    )
                    // Other Positioned widgets...
                  ],
                ),
              ),

              //========================================End of carousal slider

              SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 450),
                  child: Container(
                    margin: const EdgeInsets.only(top: 7, left: 20),
                    width: size.width,
                    height: size.height * 0.14,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Center(
                        child: Wrap(
                          spacing: 30.0, // Adjust spacing between categories
                          alignment: WrapAlignment.center,
                          children: categories.map((current) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryScreen(
                                      isUserLoggedIn: isUserLoggedIn,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundImage:
                                        AssetImage(current.imageUrl),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.008,
                                  ),
                                  Text(
                                    current.title,
                                    style: textTheme.subtitle1,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              //Recommended Text
              SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 650),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Recommended For You", style: textTheme.headline3),
                        // Text("See all", style: textTheme.headline4),
                      ],
                    ),
                  ),
                ),
              ),

              /// Body Slider Recommended
              SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 550),
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                 width: size.width,
                    height: size.height * 0.45,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: getRecommendedProductCount(),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                       
                          toUse = reProducts;
                          if (reProducts.length < 6) {
                            toUse = reProducts + products;
                          }
                       
                        if (index >= toUse.length) return null;
                        final product = toUse[index];
                        final recommendedProductIndex = toUse.indexOf(product);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Details(
                                  data: product,
                                  isCameFromMostPopularPart: false,
                                  isUserLoggedIn: isUserLoggedIn,
                                  isCameFromLogIn: isCameFromLogIn,
                                  fromWhere: 0,
                                ),
                              ),
                            );
                          },
                          child: view(recommendedProductIndex, textTheme, size),
                        );
                      },
                    ),
                  ),
                ),
              ),

              /// Most Popular Text
              SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 650),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Most Popular", style: textTheme.headline3),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MostPopular(
                                        isUserLoggedIn: isUserLoggedIn)));
                          },
                          child: Text("See all",
                              style: textTheme.headline4!
                                  .copyWith(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Most Popular Content
              SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 750),
                  child: Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: size.width,
                    height: size.height * 0.35,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // Scroll horizontally
                      physics: const BouncingScrollPhysics(),
                      itemCount: popularProducts.length,
                      itemBuilder: (context, index) {
                        final current = popularProducts[index];
                        final heroTag =
                            '${current.imageUrl}_$index'; // Unique tag for each Hero

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                return Details(
                                  data: current,
                                  isCameFromMostPopularPart: true,
                                  isUserLoggedIn: isUserLoggedIn,
                                  isCameFromLogIn: isCameFromLogIn,
                                  fromWhere: 0,
                                );
                              },
                            ),
                          ),
                          child: Hero(
                            tag: heroTag,
                            child: Column(
                              children: [
                                Container(
                                  width: size.width * 0.5,
                                  height: size.height * 0.25,
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
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    current.name,
                                    style: textTheme.headline2,
                                  ),
                                ),
                                RichText(
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              //More TO love Text
              SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("More To Love", style: textTheme.headline3),
                        // Text("See all", style: textTheme.headline4),
                      ],
                    ),
                  ),
                ),
              ),
              SliverGrid(
                gridDelegate: getGridDelegate(),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    BaseModel current = products[index];
                    Object tag = ObjectKey(current.id);
                    // Ensure the tag is unique
                    if (usedTags.contains(tag)) {
                      // Generate a new unique tag if there is a conflict
                      tag = ObjectKey('${current.id}_$index');
                    } else {
                      // Add the tag to the usedTags list
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
                              isCameFromMostPopularPart: false,
                              isUserLoggedIn: isUserLoggedIn,
                              isCameFromLogIn: isCameFromLogIn,
                              fromWhere: 2,
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
                                        AddToCart.addToCart(current, context,
                                            selectedColor, selectedSize);
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Login Required'),
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
                                                        color: Colors.black),
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
                                                                  x: 0,
                                                                  data: products
                                                                          .isNotEmpty
                                                                      ? products[
                                                                          0]
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
                                                                          value:
                                                                              1,
                                                                          selectedSize:
                                                                              1,
                                                                          selectedColor:
                                                                              1,
                                                                          type:
                                                                              "",
                                                                          color:
                                                                              "None",
                                                                              season: 'None'
                                                                        ),
                                                                ))); // Close the dialog
                                                  },
                                                  child: const Text(
                                                    'Log In',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.blueAccent),
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
        ],
      ),
    );
  }

  /// Page View
  Widget view(int index, TextTheme theme, Size size) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0.0;
        if (_pageController.position.haveDimensions) {
          value = index.toDouble() - (_pageController.page ?? 0);
          value = (value * 0.04).clamp(-1, 1);
        }
        return Transform.rotate(
          angle: 1 * value,
          child: card(toUse[index], theme, size, index), // Pass unique index
        );
      },
    );
  }

  /// Page view Cards
  Widget card(BaseModel data, TextTheme theme, Size size, int index) {
    String heroTag = 'card_${data.id}_$index'; // Unique identifier for Hero tag

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        children: [
          Hero(
            tag: heroTag,
            child: Container(
               width: size.width * 0.6,
              height: size.height * 0.33,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                image: DecorationImage(
                  image: NetworkImage(data.imageUrl),
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
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              data.name,
              style: theme.headline2,
            ),
          ),
          RichText(
            text: TextSpan(
              text: "\$ ",
              style: theme.subtitle2?.copyWith(
                color: primaryColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: data.price.toString(),
                  style: theme.subtitle2?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<BaseModel>> fetchProducts() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    List<BaseModel> products = [];

    if (user != null) {
      String userEmail = user.email ?? '';

      try {
        String collectionName =
            "Recommended"; // Name of the Firestore collection

        // Create a reference to the document with the user's email
        DocumentReference<Map<String, dynamic>> docRef =
            FirebaseFirestore.instance.collection(collectionName).doc('data');

        // Get the products subcollection for the user's email
        CollectionReference<Map<String, dynamic>> productsSubcollection =
            docRef.collection(userEmail);

        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await productsSubcollection.get();

        querySnapshot.docs.forEach((doc) {
          BaseModel product = BaseModel.fromMap(doc.data());
          products.add(product);
        });
      } catch (e) {
        print('Error fetching products data: $e');
      }
    } else {
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

       try {
        String collectionName =
            "GuestUsers"; // Name of the Firestore collection

        // Create a reference to the document with the user's email
        DocumentReference<Map<String, dynamic>> docRef =
            FirebaseFirestore.instance.collection(collectionName).doc(model);

        // Get the products subcollection for the user's email
        CollectionReference<Map<String, dynamic>> productsSubcollection =
            docRef.collection('data');

        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await productsSubcollection.get();

        querySnapshot.docs.forEach((doc) {
          BaseModel product = BaseModel.fromMap(doc.data());
          products.add(product);
        });

        print(products);
        print('ProductsFetced');
      } catch (e) {
        print('Error fetching products data: $e');
      }
      
    }
    return products;
  }

  // Function to get the count of recommended products to show
  int getRecommendedProductCount() {
    return 10;
  }

  Future<List<BaseModel>> fetchData() async {
    List<BaseModel> products = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('products2').get();

      snapshot.docs.forEach((doc) {
        BaseModel product = BaseModel.fromMap(doc.data());
        products.add(product);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }

    return products;
  }

  Future<List<BaseModel>> fetchPopularProducts() async {
    List<BaseModel> products = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('PopularProducts').get();

      snapshot.docs.forEach((doc) {
        BaseModel product = BaseModel.fromMap(doc.data());
        products.add(product);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }

    return products;
  }

  SliverGridDelegate getGridDelegate() {
    // Return the grid delegate based on the selected category

    return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.63,
    );
  }
}
