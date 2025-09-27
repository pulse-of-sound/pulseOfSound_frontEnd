import 'package:flutter/material.dart';
import '../HomeScreens/AdminHomeScreen.dart';
import '../HomeScreens/DoctorHomeScreen.dart';
import '../utils/shared_pref_helper.dart';
import 'loginscreen.dart';

class LoginForAdminAndDr extends StatefulWidget {
  const LoginForAdminAndDr({super.key});

  @override
  State<LoginForAdminAndDr> createState() => _LoginForAdminAndDrState();
}

class _LoginForAdminAndDrState extends State<LoginForAdminAndDr> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username == "admin" && password == "1234") {
      await SharedPrefsHelper.setSession(true);
      await SharedPrefsHelper.setUserType("admin");
      await SharedPrefsHelper.setName("Admin");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHome()),
      );
    } else if (username == "doctor" && password == "4321") {
      await SharedPrefsHelper.setSession(true);
      await SharedPrefsHelper.setUserType("doctor");
      await SharedPrefsHelper.setName("Doctor");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Doctorhomescreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("اسم المستخدم أو كلمة المرور غير صحيحة")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("images/background.jpg", fit: BoxFit.cover),
          Container(color: Colors.white.withOpacity(0.6)),
          Positioned(
            top: 30,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color(0xFF1A237E), size: 30),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "تسجيل الدخول للأدمن / الدكتور",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Color(0xFF1A237E)),
                    labelText: "اسم المستخدم",
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF1A237E)),
                    labelText: "كلمة المرور",
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: const Color(0xFF1A237E),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("تسجيل الدخول"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
