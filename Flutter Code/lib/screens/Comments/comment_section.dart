// ignore_for_file: prefer_const_declarations, unused_local_variable, deprecated_member_use, avoid_print

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  final String productName;
  const CommentSection({super.key, required this.productName});
  get getProductName => productName;

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
 
  bool isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkUserLoggedIn().then((isLoggedIn) {
      setState(() {
        isUserLoggedIn = isLoggedIn;
      });
    });
    String productName = widget.getProductName;
  }

  Future<bool> checkUserLoggedIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    String productName = widget.getProductName;
    return Scaffold(
      appBar: _buildAppBar(context, isUserLoggedIn),
      body: Stack(
        children:[ 
           Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/account_background1.jpg'),
                fit: BoxFit.cover, // Adjust the fit as needed
              ),
            ),
          ),
          Column(
            
          children: [
            const SizedBox(height: 10,), 
            Expanded(
              child: _buildCommentsList(productName),
            ),
            _buildCommentInput(),
          ],
        ),
     ] ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isUserLoggedIn) {
     return AppBar(
      backgroundColor: const Color.fromARGB(117, 0, 157, 255),
      centerTitle: true,
      title: const Text(
        "Comments",
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

  Widget _buildCommentsList(String productName) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('comments')
          .doc(productName)
          .collection('users')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data!.docs;
        if (comments.isEmpty) {
          // Show "No Reviews Yet" message when there are no comments
          return FadeIn(
            delay: const Duration(milliseconds: 400),
            child: const Center(
              child: Text(
                "No Reviews Yet!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        print('currentUser?.email: ${currentUser?.email}');

        return ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final commentData = comments[index].data() as Map<String, dynamic>;
            final String commenterName = commentData['commenterName'] as String;
            final String commentText = commentData['commentText'] as String;
            final String commenterImage =
                commentData['commenterImage'] as String;

            final bool isCurrentUserComment =
                currentUser?.email == commentData['commenterEmail'];

            print('isCurrentUserComment: $isCurrentUserComment');

            return FadeIn(
              delay: const Duration(milliseconds: 400),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(commenterImage),
                ),
                title: Text(commenterName),
                subtitle: Text(commentText),
                trailing: isCurrentUserComment
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteComment(
                          productName,
                          commentData['commenterEmail'],
                        ),
                      )
                    : const SizedBox(
                        width: 0,
                        height: 0,
                      ), // Placeholder container for non-current user comments
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FadeIn(
        delay: const Duration(milliseconds: 800),
        child: Center(
          child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // Background color
            minimumSize: const Size(100, 50), // Button size
          ),
          child: const Text(
            'Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
                ),
              ),
            );
  }

 

  void _deleteComment(String productName, String userEmail) {
    FirebaseFirestore.instance
        .collection('comments')
        .doc(productName)
        .collection('users')
        .doc(userEmail)
        .delete();
  }
}
