import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitbpr/home_page.dart';
import 'package:visitbpr/reset_page.dart';
import 'package:visitbpr/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false; 

  @override
  void initState() {
    super.initState();
    _checkRememberMe(); 
  }

  // Remember Me
  Future<void> _checkRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberedEmail = prefs.getString('remembered_email');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && rememberedEmail != null && rememberedEmail.isNotEmpty) {
      setState(() {
        _emailCtrl.text = rememberedEmail;
        _rememberMe = true;
      });

      _autoLogin(rememberedEmail);
    }
  }

  // Auto login 
  Future<void> _autoLogin(String email) async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email == email) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        }
      }
    } catch (e) {
      debugPrint("Auto login gagal: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      // Simpan Remember Me
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('remembered_email', _emailCtrl.text.trim());
        await prefs.setBool('remember_me', true);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('remembered_email');
        await prefs.remove('remember_me');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String pesan = "Login gagal!";
      if (e.code == 'user-not-found') pesan = "Email tidak terdaftar!";
      else if (e.code == 'wrong-password') pesan = "Password salah!";
      else if (e.code == 'invalid-email') pesan = "Format email salah!";
      else if (e.code == 'too-many-requests') pesan = "Terlalu banyak percobaan!";
      else if (e.code == 'network-request-failed') pesan = "Tidak ada koneksi internet!";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("img/bg1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // LOGO
                    Image.asset("img/BPR1.png", width: 220),
                    const SizedBox(height: 50),

                    // EMAIL FIELD
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                      decoration: const InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.person_outline, color: Colors.white),
                        border: InputBorder.none,
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                      ),
                      validator: (v) => v!.isEmpty ? "Email wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),

                    // PASSWORD FIELD
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: InputBorder.none,
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                      ),
                      validator: (v) => v!.isEmpty ? "Password wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),

                    // REMEMBER ME + FORGOT PASSWORD
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: Colors.white,
                              checkColor: Colors.black,
                              side: const BorderSide(color: Colors.white),
                              onChanged: (val) => setState(() => _rememberMe = val!),
                            ),
                            const Text("Remember Me", style: TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordPage())),
                          child: const Text("Lupa Password?", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // TOMBOL LOGIN
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 8,
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black87)
                            : const Text("Login", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SIGN UP
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                      child: const Text("Belum punya akun? Daftar di sini", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
