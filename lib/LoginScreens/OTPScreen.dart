import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pulse_of_sound/OnBoarding/onBoarding.dart';

import '../utils/shared_pref_helper.dart';
import 'loginscreen.dart';

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
        setState(() {
          _seconds--;
        });
      } else {
        setState(() {
          canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    String code = _controllers.map((c) => c.text).join();

    if (code == "123456") {
      await SharedPrefsHelper.setSession(true);
      await SharedPrefsHelper.setPhone(widget.phone);
      await SharedPrefsHelper.setUserType("user");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnBoardingScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الكود غير صحيح"),
          backgroundColor: Colors.tealAccent,
        ),
      );
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A237E),
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
        onChanged: (value) {
          if (value.isNotEmpty && index < _controllers.length - 1) {
            FocusScope.of(context).nextFocus();
          }
        },
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
                  "أدخل رمز التحقق",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildOtpBox(index)),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: const Color(0xFF1A237E),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("تأكيد الكود",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ),
                const SizedBox(height: 20),
                canResend
                    ? TextButton(
                        onPressed: _startTimer,
                        child: const Text("إعادة إرسال الرمز"),
                      )
                    : Text("يمكنك إعادة الإرسال خلال $_seconds ثانية"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
