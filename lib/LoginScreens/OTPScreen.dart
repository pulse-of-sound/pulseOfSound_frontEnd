import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pulse_of_sound/LoginScreens/loginscreen.dart';
import 'package:pulse_of_sound/OnBoarding/onBoarding.dart';
import '../api/auth_api.dart';
import '../utils/shared_pref_helper.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  int _seconds = 30;
  Timer? _timer;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _seconds = 30;
      canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        setState(() => canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    String code = _controllers.map((c) => c.text).join();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال رمز صحيح")),
      );
      return;
    }

    // أولاً: تحقق من صحة الـ OTP
    final verify = await AuthAPI.verifyOTP(widget.phone, code);

    if (verify["verified"] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الكود غير صحيح")),
      );
      return;
    }

    // ثانياً: تسجيل الدخول
    final login = await AuthAPI.loginWithMobile(widget.phone, code);

    if (login.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(login["error"]),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // حفظ البيانات
    await SharedPrefsHelper.setSession(true);
    await SharedPrefsHelper.setUserType("child");
    await SharedPrefsHelper.setPhone(login["mobileNumber"] ?? widget.phone);
    await SharedPrefsHelper.setName(login["username"] ?? "Child User");
    
    // الـ sessionToken قد يكون موجود أو نستخدم الـ ID
    final token = login["sessionToken"] ?? login["id"] ?? "";
    await SharedPrefsHelper.setToken(token);

    // الانتقال للصفحة التالية
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnBoardingScreen()),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pinkAccent,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < _controllers.length - 1) {
            FocusScope.of(context).nextFocus();
          }
        },
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

          // زر الرجوع
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

          // المحتوى داخل الإطار
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
                        "أدخل رمز التحقق",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // مربعات الكود
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:
                            List.generate(6, (index) => _buildOtpBox(index)),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: width * 0.6,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text("تأكيد الكود",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      canResend
                          ? TextButton(
                              onPressed: _startTimer,
                              child: const Text("إعادة إرسال الرمز",
                                  style: TextStyle(color: Colors.pinkAccent)),
                            )
                          : Text(
                              "يمكنك إعادة الإرسال خلال $_seconds ثانية",
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 14),
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
}
