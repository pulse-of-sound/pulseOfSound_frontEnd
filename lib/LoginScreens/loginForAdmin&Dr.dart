import 'package:flutter/material.dart';
import '../HomeScreens/AdminHomeScreen.dart';
import '../HomeScreens/DoctorHomeScreen.dart';
import '../api/user_api.dart';
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

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء ملء جميع الحقول")),
      );
      return;
    }

    final result = await UserAPI.loginUser(username, password);

    if (result.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result["error"]), backgroundColor: Colors.redAccent),
      );
      return;
    }

    String role = result["role"] ?? "User";
    print(" DEBUG loginForAdmin&Dr: result role = '$role'");
    print(" DEBUG loginForAdmin&Dr: result contains sessionToken? ${result.containsKey('sessionToken')}");
    print(" DEBUG loginForAdmin&Dr: sessionToken value = '${result['sessionToken']}'");
    print(" DEBUG loginForAdmin&Dr: full result keys = ${result.keys.toList()}");
    
    // تطبيع الـ role
    if (role.toUpperCase() == "SUPER_ADMIN" || role == "SuperAdmin") {
      role = "SUPER_ADMIN";
    } else if (role == "Admin") {
      role = "Admin";
    }
    
    await SharedPrefsHelper.setSession(true);
    await SharedPrefsHelper.setUserType(role);
    await SharedPrefsHelper.setName(result["fullName"] ?? result["username"] ?? "User");
    await SharedPrefsHelper.setToken(result["sessionToken"]);
    
    final storedToken = SharedPrefsHelper.getToken();
    final storedRole = SharedPrefsHelper.getUserType();
    print(" DEBUG loginForAdmin&Dr: token after storing = '$storedToken'");
    print(" DEBUG loginForAdmin&Dr: stored token length = ${storedToken?.length}");
    print(" DEBUG loginForAdmin&Dr: stored role = '$storedRole'");

    // دعم SuperAdmin و Admin
    if (role == "Admin" || role == "SuperAdmin" || role == "SUPER_ADMIN") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHome()),
      );
    } else if (role == "Doctor") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorDashboard()),
      );
    } else if (role == "Specialist") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("دور المستخدم غير مدعوم: $role")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/login.jpg", fit: BoxFit.cover),
          Container(color: Colors.white.withOpacity(0.25)),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.pinkAccent, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: width * 0.8,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "تسجيل الدخول للأدمن / الدكتور",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildTextField("اسم المستخدم", Icons.person,
                          controller: _usernameController),
                      const SizedBox(height: 15),
                      _buildTextField("كلمة المرور", Icons.lock,
                          controller: _passwordController, obscure: true),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: width * 0.6,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text("تسجيل الدخول",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon,
      {bool obscure = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.pinkAccent),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }
}
