// ignore_for_file: camel_case_types, library_private_types_in_public_api, use_build_context_synchronously, avoid_print, unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class Feedback_Form extends StatefulWidget {
  const Feedback_Form({Key? key}) : super(key: key);

  @override
  _Feedback_FormState createState() => _Feedback_FormState();
}

class _Feedback_FormState extends State<Feedback_Form> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  Future<void> _sendEmail(
      String subject, String body, String recipientEmail) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: [recipientEmail],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content:
                const Text('Your email has been sent to the admin successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pop(); // Navigate back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send email. Please try again.')),
      );
      print('Error sending email: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Enter Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Enter Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Enter Body',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String email = _emailController.text;
                    String subject = _subjectController.text;
                    String body = _bodyController.text;
                    _sendEmail(subject, body, 'smartecommercea@gmail.com');
                  }
                },
                style: ElevatedButton.styleFrom(primary: Colors.teal),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Feedback_Form(),
  ));
}
