import 'package:chat_with_me/widgets/user_pick_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogIn = true;
  String email = '';
  String password = '';
  File? image;
  bool isLoading = false;
  String username = '';

  final _formKey = GlobalKey<FormState>();
  void onSelectingImage(File f) {
    image = f;
  }

  void _submit() async {
    final bool isValid = _formKey.currentState!.validate();
    print(image);
    if (!isValid || (!_isLogIn && image == null)) {
      return;
    }
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState!.save();

      try {
        if (_isLogIn) {
          final UserCredential = await _firebase.signInWithEmailAndPassword(
              email: email, password: password);
          setState(() {
            isLoading = false;
          });
          print(UserCredential);
        } else {
          final UserCredential = await _firebase.createUserWithEmailAndPassword(
              email: email, password: password);
          setState(() {
            isLoading = false;
          });

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('userimages')
              .child('${UserCredential.user!.uid}.jpg');
          await storageRef.putFile(image!);
          final url = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(UserCredential.user!.uid)
              .set(
            {
              'userName': username,
              'email': email,
              'imageUrl': url,
            },
          );
        }
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ?? 'Authentication Failed',
            ),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 10,
                  right: 10,
                ),
                width: 200,
                child: Image.asset('./lib/assets/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogIn)
                          UserImagePicker(onPickImage: onSelectingImage),
                        if (!_isLogIn)
                          TextFormField(
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length < 4 ||
                                  value.isEmpty) {
                                return 'enter a valid username and of length atleast 4';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'username',
                            ),
                            enableSuggestions: false,
                            onSaved: (value) {
                              username = value!;
                            },
                          ),
                        TextFormField(
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return "Invalid email address";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'email address',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          onSaved: (value) {
                            email = value!;
                          },
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null ||
                                value.trim().length < 6 ||
                                value.contains(' ')) {
                              return "Invalid password";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            password = value!;
                          },
                          decoration: const InputDecoration(
                            labelText: 'password',
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        if (isLoading) const CircularProgressIndicator(),
                        if (!isLoading)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(!_isLogIn ? 'SignUp' : 'Login'),
                          ),
                        if (!isLoading)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogIn = !_isLogIn;
                              });
                            },
                            child: Text(
                              _isLogIn
                                  ? 'Create an Account'
                                  : 'I already have an account',
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
