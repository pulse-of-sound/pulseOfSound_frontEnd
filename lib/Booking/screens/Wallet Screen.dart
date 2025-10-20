import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/shared_pref_helper.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      await SharedPrefsHelper.setWalletImage(file.path);
      setState(() {
        _imageFile = file;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم رفع إيصال الدفع بنجاح")),
      );
    }
  }

  Future<void> _loadSavedImage() async {
    final path = await SharedPrefsHelper.getWalletImage();
    if (path != null && File(path).existsSync()) {
      setState(() => _imageFile = File(path));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("المحفظة",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/booking.jpg"), fit: BoxFit.cover),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("قم برفع إيصال الدفع:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _imageFile == null
                    ? const Icon(Icons.image_not_supported,
                        size: 100, color: Colors.grey)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_imageFile!,
                            height: 200, fit: BoxFit.cover),
                      ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: const Text("رفع إيصال",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
