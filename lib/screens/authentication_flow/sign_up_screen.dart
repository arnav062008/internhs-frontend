import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:internhs/constants/colors.dart';
import 'package:internhs/constants/device.dart';
import 'package:internhs/constants/text.dart';
import 'package:internhs/firebase/user.dart' as db;
import 'package:internhs/screens/initial_landing_flow/landing_agent.dart';

import '../opportunities_page.dart';
import 'login_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _authInstance = FirebaseAuth.instance;

  // Controllers
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  // Outside Build to update the state
  bool fieldFilled = false;
  bool obscure = true;
  late User currentUser;

  /// Sign in Methods

  // Google
  Future<void> _signInWithGoogle() async {
    GoogleAuthProvider authProvider = GoogleAuthProvider();

    try {
      UserCredential userCredential =
          await _authInstance.signInWithPopup(authProvider);

      // Add user details to Firestore
      User? currentUser = userCredential.user;
      if (currentUser != null) {
        db.User user = db.User(
          email: currentUser.email!,
          uid: currentUser.uid,
        );
        await user.addToFirestore().whenComplete(() {
          if (_authInstance.currentUser?.uid != null) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const OpportunitiesPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        });
      } else {
        if (kDebugMode) {
          print("No user is signed in.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Email and Password
  Future<void> _createUser(String email, String password) async {
    try {
      // Check if a user with the given email already exists
      var existingUser = await _authInstance.fetchSignInMethodsForEmail(email);
      if (existingUser.isNotEmpty) {
        if (kDebugMode) {
          print("User with email $email already exists.");
        }
        // Handle the case where the user already exists
        return;
      }

      // Create user with email and password
      UserCredential userCredential = await _authInstance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .whenComplete(() {
        // Add user details to Firestore
        db.User user = db.User(
          email: email,
          uid: _authInstance.currentUser!.uid,
        );
        user.addToFirestore();
      });

      if (kDebugMode) {
        print(
            "Sign Up Successful: User created with email $email and password $password");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      // Handle any errors that occur during the user creation process
    }
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Social Media Button
    Widget buildLoginPlatforms() {
      return GestureDetector(
        onTap: () {
          _signInWithGoogle();
        },
        child: Container(
          width: width(context) * 528 / 1250,
          height: height(context) * 70 / 840,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFF333333),
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(90),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(height(context) * 15 / 840),
                child: Image.asset("lib/assets/images/google.png"),
              ),
              Text(
                "Sign Up With Google",
                style: authTextStyle.copyWith(
                    fontSize: height(context) * 16 / 840),
              )
            ],
          ),
        ),
      );
    }

    /// Create Account Button
    Widget buildCreateAccount() {
      return Container(
        width: width(context) * 528 / 1240,
        height: height(context) * 64 / 840,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color:
              fieldFilled ? const Color(0xFF111111) : const Color(0x40111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Create an account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height(context) * 22 / 840,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                /// Background
                image: AssetImage("lib/assets/images/auth_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: width(context) * 0.56,
              height: height(context) * 0.95,
              clipBehavior: Clip.antiAlias,
              decoration: authBoxDecorations,
              child: Column(
                children: [
                  /// Build Header of Signin
                  Row(
                    children: [
                      SizedBox(
                        height: height(context) * 38 / 840,
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.all(height(context) * 8 / 840),
                        child: IconButton(
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          LandingAgent(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.close_outlined,
                              color: accentColor,
                            )),
                      )
                    ],
                  ),
                  Center(
                    child: Container(
                      width: height(context) * 48 / 840,
                      height: height(context) * 48 / 840,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFC4C4C4),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                  Text(
                    'Create an account',
                    textAlign: TextAlign.center,
                    style: authHeadingStyle.copyWith(
                        fontSize: height(context) * 32 / 840),
                  ),
                  SizedBox(height: height(context) * 2 / 840),
                  Container(
                    padding: EdgeInsets.all(height(context) * 2 / 840),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        const LoginPage(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Already have an account?  ',
                                    style: authTextStyle.copyWith(
                                        fontSize: height(context) * 16 / 840)),
                                TextSpan(
                                  text: 'Log in  ',
                                  style: authTextStyle.copyWith(
                                      decoration: TextDecoration.underline,
                                      fontSize: height(context) * 16 / 840),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height(context) * 40 / 840,
                  ),

                  /// Build Login with
                  buildLoginPlatforms(),
                  SizedBox(
                    height: height(context) * 55 / 840,
                  ),

                  /// Build Divider
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: width(context) * 224.5 / 1240,
                          child: Divider(
                            height: height(context) * 2 / 840,
                          ),
                        ),
                        SizedBox(
                          width: width(context) * 24 / 1240,
                        ),
                        Text(
                          "Or",
                          style: authTextStyle.copyWith(
                              fontSize: height(context) * 16 / 840),
                        ),
                        SizedBox(
                          width: width(context) * 24 / 1240,
                        ),
                        SizedBox(
                          width: width(context) * 224.5 / 1240,
                          child: Divider(
                            height: height(context) * 2 / 840,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height(context) * 40 / 840,
                  ),

                  /// Build Email Signup Text
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: 'Enter your credentials to ',
                            style: authTextStyle.copyWith(
                                fontSize: height(context) * 16 / 840)),
                        TextSpan(
                          text: 'create an account.',
                          style: authTextStyle.copyWith(
                              decoration: TextDecoration.underline,
                              fontSize: height(context) * 16 / 840),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: height(context) * 16 / 840,
                  ),

                  /// Build authentication fields
                  Column(
                    children: [
                      SizedBox(
                        width: width(context) * 528 / 1240,
                        child: Text(
                          "Your Email",
                          style: authTextStyle.copyWith(
                              fontSize: height(context) * 16 / 840),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(
                        height: height(context) * 6 / 840,
                      ),

                      /// Email Field
                      SizedBox(
                        width: width(context) * 528 / 1240,
                        height: height(context) * 56 / 840,
                        child: TextFormField(
                          onChanged: (_) {
                            if (_emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty) {
                              setState(() {
                                fieldFilled = true;
                              });
                            }
                            if (_emailController.text.isEmpty ||
                                _passwordController.text.isEmpty) {
                              setState(() {
                                fieldFilled = false;
                              });
                            }
                          },
                          controller: _emailController,
                          decoration: textFieldDecoration,
                        ),
                      ),
                      SizedBox(
                        height: height(context) * 16 / 840,
                      ),
                      SizedBox(
                        width: width(context) * 528 / 1240,
                        child: Text(
                          "Your Password",
                          style: authTextStyle.copyWith(
                              fontSize: height(context) * 16 / 840),
                          textAlign: TextAlign.start,
                        ),
                      ),

                      /// Password Field
                      SizedBox(
                        height: height(context) * 6 / 840,
                      ),
                      SizedBox(
                        width: width(context) * 528 / 1240,
                        height: height(context) * 56 / 840,
                        child: TextFormField(
                          onChanged: (String value) {
                            if (_emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty) {
                              setState(() {
                                fieldFilled = true;
                              });
                            }
                            if (_emailController.text.isEmpty ||
                                _passwordController.text.isEmpty) {
                              setState(() {
                                fieldFilled = false;
                              });
                            }
                          },
                          controller: _passwordController,
                          decoration: textFieldDecoration.copyWith(
                            suffixIcon: IconButton(
                              focusColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              icon: Icon(
                                obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: height(context) * 20 / 840,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscure = !obscure;
                                });
                              },
                            ),
                          ),
                          obscureText: obscure,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height(context) * 16 / 840,
                  ),
                  GestureDetector(
                      onTap: () {
                        _createUser(
                            _emailController.text, _passwordController.text);
                        if (_authInstance.currentUser?.uid != null) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  const OpportunitiesPage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                      child: buildCreateAccount()),
                ],
              ),
            ),
          )
              .animate()
              .fade(
                duration: const Duration(milliseconds: 1000),
              )
              .slideY(
                  begin: 0.25,
                  end: 0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.ease),
        ],
      ),
    );
  }
}
