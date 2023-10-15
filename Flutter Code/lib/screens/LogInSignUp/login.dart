// ignore_for_file: use_build_context_synchronously, avoid_function_literals_in_foreach_calls, avoid_print, sort_child_properties_last, unused_field, unused_import

import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/admin/home/admin_home.dart';
import 'package:fashion_ecommerce_app/main_wrapper.dart';
import 'package:fashion_ecommerce_app/screens/LogInSignUp/signup.dart';
import 'package:fashion_ecommerce_app/screens/ProductDetail/details.dart';
import 'package:fashion_ecommerce_app/screens/cart/cart.dart';
import 'package:fashion_ecommerce_app/screens/category/category.dart';
import 'package:fashion_ecommerce_app/screens/LogInSignUp/user_account.dart';
import 'package:fashion_ecommerce_app/screens/search/search.dart';
import 'package:fashion_ecommerce_app/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../model/base_model.dart';
import 'Fade_animation.dart';

class Login extends StatefulWidget {
  final int x;
  final BaseModel data;
  final int fromWhere;

  const Login(
      {Key? key, 
      required this.x, 
      required this.data, 
      required this.fromWhere})
      : super(key: key);
  int? get getFromWhere => fromWhere;
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int _index = 3;
  int xValue = 0;
  List<BaseModel> products = [];
  int fromWhere = 0;

  bool isCustomerChecked = false;
  bool isAlumniChecked = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordFieldFocused = false;
  bool _isLoading = false;
  bool isUserLoggedIn = false;
  bool _isPasswordVisible = false;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        final User? user = userCredential.user;
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserAccount(
                email: user.email!,
                username: user.displayName!,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFieldFocused = _passwordFocusNode.hasFocus;
      });
    });
    xValue = widget.x;
    fetchData().then((data) {
      setState(() {
        products = data;
      });
    });
  }
//===================================forgot password========================================================

  // Function to handle forgot password
  final TextEditingController _emailResetController = TextEditingController();

  Future<void> _handleForgotPassword() async {
    final email = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to reset your password:'),
            const SizedBox(height: 10),
            TextField(
              controller: _emailResetController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey[400])),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_emailResetController.text);
            },
            child: const Text('Reset Password',
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (email != null && email.isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Password reset Email has been sent. Check your inbox!'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

//====================================================================================
  Future<void> _signInWithEmailAndPassword() async {
    fromWhere = widget.fromWhere;
    setState(() {
      _isLoading = true; // Show the progress bar
    });

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      FirebaseAuth auth = FirebaseAuth.instance;
      // Handle successful login and navigate to the necessary page
      if (userCredential.user != null) {
        if (isCustomerChecked) {
          // Verify if the user is not an admin
          if (_emailController.text.trim() != 'admin.smart@gmail.com' ||
              _passwordController.text.trim() != 'admin1234') {
            if (xValue == 1  && auth.currentUser!.emailVerified) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserAccount(
                    email: _emailController.text.trim(),
                    username: userCredential.user!.displayName ?? '',
                  ),
                ),
              );
            } else if (xValue == 0 && auth.currentUser!.emailVerified) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Details(
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
                          isCameFromMostPopularPart: false,
                          isUserLoggedIn: true,
                          isCameFromLogIn: true,
                          fromWhere: fromWhere)));
            } else if (xValue == 2  && auth.currentUser!.emailVerified) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Cart(
                            isUserLoggedIn: true,
                            isCameFromUser: false,
                          )));
            } else {
              showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Account Verification'),
              content: const Text(
                  'Your Email is Not verified please verify you email first.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    auth.signOut();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
            }
          } else {
            // Show error dialog for admin attempting to access customer screen
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Access Denied'),
                  content: const Text(
                      'You are not authorized to access the customer screen.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (isAlumniChecked) {
          // Verify admin credentials
          if (_emailController.text.trim() == 'admin.smart@gmail.com' &&
              _passwordController.text.trim() == 'admin1234') {
            // Navigate to the admin home screen for admins
            // Replace 'AdminHomeScreen' with the appropriate admin screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminHome(),
              ),
            );
          } else {
            // Show error dialog for incorrect admin credentials
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Admin Login Error'),
                  content:
                      const Text('Invalid email or password for admin login.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } catch (e) {
      // Handle login errorspass
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide the progress bar
      });
    }
  }

  ColorFilter colorFilter = ColorFilter.mode(
    Colors.blue.withOpacity(0.5), // Change the color and opacity as needed
    BlendMode.srcATop,
  );
  final w = Get.width;
  final h = Get.height;
  @override
  void dispose() {
    _controller.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, isUserLoggedIn, xValue),
      bottomNavigationBar: _bootomAppBar(context),

      //=============================================Body==============================
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/account_background1.jpg'),
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeIn(
                  child: Column(
                children: [
                  Image.asset(
                    "assets/logo.png",
                  )
                ],
              )),
              // const SizedBox(height: 10),
              SingleChildScrollView(
                child: FadeIn(
                  delay: const Duration(milliseconds: 500),
                  child: SizedBox(
                    height: 50,
                    width: 350,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey, // Shadow color
                            blurRadius: 5.0, // Spread radius
                            offset: Offset(0, 2), // Shadow position
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue, // Background color
                      ),
                      child: TextFormField(
                        cursorColor: Colors.blue,
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        style: const TextStyle(
                          color: Colors.blue, // Input text color
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'RobotoMono',
                            fontSize: 16,
                          ),
                          filled: true, // Fill the background with color
                          fillColor: Colors.white, // Background color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide.none, // Remove the border color
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide.none, // Remove the border color
                          ),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.blue, // Icon color
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              FadeIn(
                delay: const Duration(milliseconds: 700),
                child: SizedBox(
                  height: 50,
                  width: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey, // Shadow color
                          blurRadius: 5.0, // Spread radius
                          offset: Offset(0, 2), // Shadow position
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue, // Background color
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(
                        color: Colors.blue, // Input text color
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'RobotoMono',
                          fontSize: 16,
                        ),
                        filled: true, // Fill the background with color
                        fillColor: Colors.white, // Background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                          // Remove the border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide.none, // Remove the border color
                        ),
                        prefixIcon: const Icon(
                          Icons.key,
                          color: Colors.blue, // Icon color
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      ),
                    ),
                  ),
                ),
              ),

              //=======================Forgot password==========================================
              const SizedBox(height: 16),

              FadeIn(
                delay: const Duration(milliseconds: 1300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 165,
                    ),
                    GestureDetector(
                      onTap: _handleForgotPassword,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                            fontSize: 16,
                            fontFamily: 'RobotoMono'),
                      ),
                    ),
                  ],
                ),
              ),
              //================================================================
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 900),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Theme(
                      data: ThemeData(unselectedWidgetColor: Colors.blue),
                      child: Checkbox(
                        value: isCustomerChecked,
                        onChanged: (value) {
                          setState(() {
                            isCustomerChecked = value ?? false;
                            if (isCustomerChecked) {
                              isAlumniChecked = false;
                            }
                          });
                        },
                      ),
                    ),
                    const Text(
                      'Customer',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Theme(
                      data: ThemeData(unselectedWidgetColor: Colors.blue),
                      child: Checkbox(
                        value: isAlumniChecked,
                        onChanged: (value) {
                          setState(() {
                            isAlumniChecked = value ?? false;
                            if (isAlumniChecked) {
                              isCustomerChecked = false;
                            }
                          });
                        },
                      ),
                    ),
                    const Text(
                      'Admin',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading) // Show the progress bar if loading is in progress
                const CircularProgressIndicator(
                  color: Colors.blue,
                ),
              const SizedBox(height: 16),
              //=============================================================Login and Signup button
              FadeIn(
                delay: const Duration(milliseconds: 1100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _signInWithEmailAndPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent, // Make the button transparent
                        elevation: 0, // Remove the button elevation
                      ),
                      child: Container(
                        height: 50,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color.fromARGB(
                                255, 122, 185, 235), // White border color
                            width: 1.0, // Border width
                          ),
                          gradient: const LinearGradient(colors: [
                            Colors.white,
                            Colors.white,
                          ]),
                        ),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'RobotoMono',
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUp(key: null)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent, // Make the button transparent
                        elevation: 0, // Remove the button elevation
                      ),
                      child: Container(
                        height: 50,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color.fromARGB(
                                255, 122, 185, 235), // White border color
                            width: 1.0, // Border width
                          ),
                          gradient: const LinearGradient(colors: [
                            Colors.white,
                            Colors.white,
                          ]),
                        ),
                        child: const Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'RobotoMono',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //=====================================End of login and Signup Buttons
              const SizedBox(height: 9),
              FadeIn(
                delay: const Duration(milliseconds: 1500),
                child: const SizedBox(
                  height: 18,
                ),
              ),
              const SizedBox(height: 5),
              FadeIn(
                delay: const Duration(milliseconds: 1700),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: ElevatedButton(
                    onPressed: () {
                      signInWithGoogle();
                    },
                    child: const SizedBox(
                      height: 50,
                      width: 240,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(FontAwesomeIcons.google, color: Colors.blue),
                            SizedBox(width: 20),
                            Text(
                              'Sign in with Google',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(
                          color: Colors.blue, // Set the border color to blue
                          width: 1, // Set the border width
                        ),
                      ),
                    ),
                  ),
                ),
              )

              //================================================Login with Google
            ],
          ),
        ),
      ]),
    );
    //=====================================End of Body UI==============================
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

  AppBar _buildAppBar(BuildContext context, bool isUserLoggedIn, int xValue) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Log In",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          if (xValue == 0 || xValue == 2) {
            Navigator.pop(context);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CategoryScreen(isUserLoggedIn: isUserLoggedIn)));
          }
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.white,
        ),
      ),
    );
  }

  BottomNavigationBar _bootomAppBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(
          109, 0, 140, 255), // Make the background transparent
      elevation: 0, // Remove the shadow
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Category'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Person'),
      ],
      currentIndex: _index,
      onTap: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainWrapper(
                isUserLoggedIn: isUserLoggedIn,
              ),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(
                isUserLoggedIn: isUserLoggedIn,
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
    );
  }
}
