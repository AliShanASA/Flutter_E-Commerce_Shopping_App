// ignore_for_file: library_private_types_in_public_api, unused_local_variable, avoid_print, use_build_context_synchronously, deprecated_member_use, unused_import
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../../main_wrapper.dart';
import '../../utils/constants.dart';
import '../category/category.dart';
import '../search/search.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final int _index = 3;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool isUserLoggedIn = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccountWithEmailAndPassword() async {
  final String username = _usernameController.text.trim();
  final String email = _emailController.text.trim();
  final String password = _passwordController.text;

  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true; // Show the progress indicator
    });

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);
      bool isVerified = auth.currentUser!.emailVerified;
      // Send email verification
      User? user = userCredential.user;
      if (user != null) {
        try{
        await user.sendEmailVerification();
        } catch(e){
          print('Email Verification Error: $e');
        }
        auth.signOut();
        // Display a success message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Account Verification'),
              content: const Text(
                  'Please check your email for a verification link.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        // Clear all fields
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      // Handle sign-up error
      print('Sign-up error: $e');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign Up Error!'),
              content:  Text('$e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      
    } finally {
      setState(() {
        _isLoading = false; // Hide the progress indicator
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Image.asset(
                        'assets/logo.png', // Replace 'logo.png' with your image asset path
                        width: 250, // Set the width of the image
                        height: 230,
                        fit: BoxFit.contain, // Adjust the fit as needed
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeIn(
                  delay: const Duration(milliseconds: 500),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
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
                          color: Colors.white, // Background color
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(
                            color: Colors.blue, // Text color (blue)
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter User Name',
                            hintStyle: const TextStyle(
                              color: Colors.blue, // Text color (blue)
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide.none, // Remove the border color
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.blue, // Icon color (blue)
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 5),
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Background color (white)
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeIn(
                  delay: const Duration(milliseconds: 700),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
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
                          color: Colors.white, // Background color
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          style: const TextStyle(
                            color: Colors.blue, // Text color (blue)
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter Your Email',
                            hintStyle: const TextStyle(
                              color: Colors.blue, // Text color (blue)
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide.none, // Remove the border color
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.blue, // Icon color (blue)
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 5),
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Background color (white)
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeIn(
                  delay: const Duration(milliseconds: 900),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
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
                          color: Colors.white, // Background color
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(
                            color: Colors.blue, // Text color (blue)
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter New Password',
                            hintStyle: const TextStyle(
                              color: Colors.blue, // Text color (blue)
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide.none, // Remove the border color
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.blue, // Icon color (blue)
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
                                color: Colors.blue, // Eye icon color (blue)
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 5),
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Background color (white)
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeIn(
                  delay: const Duration(milliseconds: 1100),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
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
                          color: Colors.white, // Background color
                        ),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: const TextStyle(
                            color: Colors.blue, // Text color (blue)
                          ),
                          decoration: InputDecoration(
                            hintText: 'Confirm Your Password',
                            hintStyle: const TextStyle(
                              color: Colors.blue, // Text color (blue)
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide.none, // Remove the border color
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.blue, // Icon color (blue)
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blue, // Eye icon color (blue)
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 5),
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Background color (white)
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  const CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                const SizedBox(height: 30),
                FadeIn(
                  delay: const Duration(milliseconds: 1300),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 107, 155, 238),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 10),
                      ),
                      onPressed: _createAccountWithEmailAndPassword,
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ]),
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
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Create Your Account",
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

    //===================================
  }
}
