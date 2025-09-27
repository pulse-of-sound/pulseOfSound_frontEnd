import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';
import 'package:pulse_of_sound/LoginScreens/loginForAdmin&Dr.dart';
import '../utils/shared_pref_helper.dart';
import 'OTPScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? completePhoneNumber;

  void _handleLogin() async {
    if (completePhoneNumber == null || completePhoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال رقم الهاتف")),
      );
      return;
    }

    // ✅ تخزين بيانات الجلسة
    await SharedPrefsHelper.setSession(true);
    await SharedPrefsHelper.setPhone(completePhoneNumber!);
    await SharedPrefsHelper.setUserType("user");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(phone: completePhoneNumber!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("images/background.jpg", fit: BoxFit.cover),
          Container(
            color: Colors.white.withOpacity(0.6),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "تسجيل الدخول برقم الهاتف",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 30),

                // إدخال رقم الهاتف
                IntlPhoneField(
                  style: const TextStyle(
                    color: Color(0xFF1A237E),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: "رقم الهاتف",
                    labelStyle: const TextStyle(
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  initialCountryCode: 'SY',
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (phone) {
                    completePhoneNumber = phone.completeNumber;
                  },
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: const Color(0xFF1A237E),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "متابعة التسجيل",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginForAdminAndDr()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1A237E), width: 2),
                    foregroundColor: const Color(0xFF1A237E),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "تسجيل الدخول بطريقة اخرى",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
