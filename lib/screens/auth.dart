import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _formKey = GlobalKey<FormState>();
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_isLogIn) {
        try {
          final user = await _firebase.signInWithEmailAndPassword(
              email: email, password: password);
        } on FirebaseAuthException catch (error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.message ?? 'Authentication Failed',
              ),
            ),
          );
        }
      } else {
        try {
          final user = await _firebase.createUserWithEmailAndPassword(
              email: email, password: password);
        } on FirebaseAuthException catch (error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.message ?? 'Authentication Failed',
              ),
            ),
          );
        }
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
                          onSaved: (email) {
                            email = email;
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
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Text(!_isLogIn ? 'SignUp' : 'Login'),
                        ),
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
