// ignore_for_file: deprecated_member_use, avoid_function_literals_in_foreach_calls, avoid_print, unused_local_variable

import 'package:animate_do/animate_do.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/data/app_data.dart';
import 'package:fashion_ecommerce_app/main_wrapper.dart';
import 'package:fashion_ecommerce_app/model/categories_model.dart';
import 'package:fashion_ecommerce_app/screens/LogInSignUp/login.dart';
import 'package:fashion_ecommerce_app/screens/search/search.dart';
import 'package:fashion_ecommerce_app/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../model/base_model.dart';
import '../../widget/add_to_cart.dart';
import '../LogInSignUp/user_account.dart';
import '../ProductDetail/details.dart';
import '../cart/cart.dart';

class CategoryScreen extends StatefulWidget {
  final bool isUserLoggedIn;
  const CategoryScreen({Key? key, required this.isUserLoggedIn})
      : super(key: key);
  bool get getIsUserLoggedIn => isUserLoggedIn;
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  String selectedCategory = 'All';
  List<BaseModel> allProducts = []; // List to store all products
  List<BaseModel> kidsProducts = []; // List to store kids products
  List<BaseModel> menProducts = []; // List to store men products
  List<BaseModel> womenProducts = []; // List to store women products
  List<BaseModel> products = [];
  bool isSearchActive = false;
  final int _index = 2;
  Set<Object> usedTags = {};
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
    getCartItemCount();
    fetchData().then((data) {
      setState(() {
        products = data;
        updateCategoryProducts();
      });
    });
    super.initState();
  }

  void updateCategoryProducts() {
    allProducts = getProductsByCategory('all');
    kidsProducts = getProductsByCategory('kid');
    menProducts = getProductsByCategory('men');
    womenProducts = getProductsByCategory('women');
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      updateCategoryProducts();
    });
  }

  List<BaseModel> getProductsByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      return products;
    } else {
      return products
          .where((product) =>
              product.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
  }
  void handleApplyButton() {
    double minPrice = double.tryParse(minController.text) ?? 0.0;
    double maxPrice = double.tryParse(maxController.text) ?? double.infinity;

    if (minPrice > maxPrice) {
      // Swap min and max values if min is greater than max
      double temp = minPrice;
      minPrice = maxPrice;
      maxPrice = temp;
    }

    List<BaseModel> filteredProducts =
        getProductsByCategoryAndRange(selectedCategory, minPrice, maxPrice);

    // Clear the input fields
    minController.clear();
    maxController.clear();
   if (selectedCategory.toLowerCase() == 'all') {
      allProducts = filteredProducts;
   } else if(selectedCategory.toLowerCase() == 'men'){
    menProducts = filteredProducts;

   } else if(selectedCategory.toLowerCase() == 'women'){
    womenProducts = filteredProducts;
    
   } else if(selectedCategory.toLowerCase() == 'kid'){
    kidsProducts = filteredProducts;
    
   }
    
  }

  List<BaseModel> getProductsByCategoryAndRange(
      String category, double min, double max) {
    if (category.toLowerCase() == 'all') {
      return products
          .where((product) => product.price >= min && product.price <= max)
          .toList();
    } else {
      return products
          .where((product) =>
              product.category.toLowerCase() == category.toLowerCase() &&
              product.price >= min &&
              product.price <= max)
          .toList();
    }
  }

  List<BaseModel> getCurrentProducts() {
    // Return the products based on the selected category
    if (selectedCategory.toLowerCase() == 'kid') {
      return kidsProducts;
    } else if (selectedCategory.toLowerCase() == 'men') {
      return menProducts;
    } else if (selectedCategory.toLowerCase() == 'women') {
      return womenProducts;
    }
    return allProducts;
  }

  SliverGridDelegate getGridDelegate() {
    // Return the grid delegate based on the selected category
    final products = getCurrentProducts();
    final itemCount = products.length;
    return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.63,
    );
  }

TextEditingController minController = TextEditingController();
TextEditingController maxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    bool isUserLoggedIn = widget.getIsUserLoggedIn;
    int selectedSize = 1;
    int selectedColor = 1;
    const x0 = 1;
    const x1 = 1;
    const isCameFromLogIn = false;

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
        currentIndex: _index,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MainWrapper(isUserLoggedIn: isUserLoggedIn),
                ));
          } else if (index == 3 && isUserLoggedIn) {
            FirebaseAuth auth = FirebaseAuth.instance;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserAccount(
                        email: auth.currentUser!.email ?? '',
                        username: auth.currentUser!.displayName ?? '')));
          } else if (index == 3 && !isUserLoggedIn) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Login(
                          x: x1,
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
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Search(),
                ));
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
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 7),
                width: size.width,
                height: size.height * 0.14,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (ctx, index) {
                    CategoriesModel current = categories[index];
                    bool isSelected = selectedCategory == current.title;
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          onCategorySelected(current.title);
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: isSelected
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundImage: AssetImage(current.imageUrl),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.008,
                              ),
                              Text(
                                current.title,
                                style: isSelected
                                    ? textTheme.subtitle1
                                        ?.copyWith(color: Colors.blueAccent)
                                    : textTheme.subtitle1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            //==================================================Filters
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Price Range',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: handleApplyButton, 
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Min',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: minController, // Assign minController here
                        // Add validation logic if needed
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Max',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: maxController, // Assign maxController here
                        // Add validation logic if needed
                      ),
                    ),
                  ],
                ),
              ),

                ],
              ),
            ),
            //====================================2nd filter=========================
          
            SliverGrid(
              gridDelegate: getGridDelegate(),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  BaseModel current = getCurrentProducts()[index];
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
                                                                        season:
                                                                            'None'),
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
                childCount: getCurrentProducts().length,
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

  AppBar _buildAppBar(BuildContext context, bool isUserLoggedIn) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Categories",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Search()));
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.white,
        ),
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
  }
}
