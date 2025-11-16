import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool isLoading = false;

  Future<void> signUp() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passController.text.trim();
    final confirmPassword = confirmPassController.text.trim();

    // VALIDASI
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage("Semua field harus diisi");
      return;
    }
    if (password != confirmPassword) {
      showMessage("Password tidak sama");
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. BUAT AKUN DI FIREBASE AUTH
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 2. SIMPAN DATA KE FIRESTORE
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "username": username,
        "email": email,
        "createdAt": Timestamp.now(),
      });

      showMessage("Sign Up berhasil!");
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? "Terjadi kesalahan");
    }

    setState(() => isLoading = false);
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("img/bg1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Image.asset("img/BPR1.png", width: 200),
                  const SizedBox(height: 40),

                  _buildField(
                    controller: usernameController,
                    icon: Icons.person_outline,
                    hint: "Username",
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    controller: emailController,
                    icon: Icons.email_outlined,
                    hint: "Email",
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    controller: passController,
                    icon: Icons.lock_outline,
                    hint: "Password",
                    obscure: true,
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    controller: confirmPassController,
                    icon: Icons.lock_reset_outlined,
                    hint: "Confirm Password",
                    obscure: true,
                  ),
                  const SizedBox(height: 35),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
