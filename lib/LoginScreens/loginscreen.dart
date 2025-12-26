import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';
import 'package:pulse_of_sound/LoginScreens/loginForAdmin&Dr.dart';
import '../api/auth_api.dart';
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

    String normalizedPhone = completePhoneNumber!.replaceAll(" ", "");
    
    
    if (normalizedPhone.startsWith("+9630")) {
      normalizedPhone = "+963${normalizedPhone.substring(5)}";
    } else if (normalizedPhone.startsWith("0")) {
      normalizedPhone = "+963${normalizedPhone.substring(1)}";
    } else if (!normalizedPhone.startsWith("+963")) {
      normalizedPhone = "+963$normalizedPhone";
    }

    print("NORMALIZED = $normalizedPhone");

    final result = await AuthAPI.generateOTP(normalizedPhone);

    print("OTP_RESPONSE = $result");

    if (result.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result["error"]), backgroundColor: Colors.redAccent),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(phone: normalizedPhone),
      ),
    );
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

          // المحتوى
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: Container(
                    width: width * 0.8, 
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "تسجيل الدخول برقم الهاتف",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // حقل رقم الهاتف
                        IntlPhoneField(
                          decoration: InputDecoration(
                            labelText: "رقم الهاتف",
                            labelStyle: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.85),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                          ),
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                          initialCountryCode: 'SY',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (phone) {
                            completePhoneNumber = phone.completeNumber;
                          },
                        ),
                        const SizedBox(height: 20),

                        // زر المتابعة
                        SizedBox(
                          width: width * 0.6,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                            child: const Text("متابعة التسجيل",
                                style: TextStyle(fontSize: 15)),
                          ),
                        ),
                        const SizedBox(height: 15),

                    
                        SizedBox(
                          width: width * 0.6,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginForAdminAndDr()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.pinkAccent, width: 2),
                              foregroundColor: Colors.pinkAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                            child: const Text("تسجيل الدخول بطريقة أخرى",
                                style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
