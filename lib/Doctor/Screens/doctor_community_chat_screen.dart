import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Colors/colors.dart';
import '../utils/doctor_chat_prefs.dart';

class DoctorCommunityChatScreen extends StatefulWidget {
  const DoctorCommunityChatScreen({super.key});

  @override
  State<DoctorCommunityChatScreen> createState() =>
      _DoctorCommunityChatScreenState();
}

class _DoctorCommunityChatScreenState extends State<DoctorCommunityChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final data = await DoctorChatService.loadCommunity();
    setState(() => messages = data);
    // بعد تحميل الرسائل، انزلي تلقائياً لآخر رسالة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage({String? imagePath}) async {
    final text = _controller.text.trim();
    if (text.isEmpty && imagePath == null) return;

    await DoctorChatService.addCommunity("طبيب", text, imagePath: imagePath);
    _controller.clear();
    await _loadMessages();
    // بعد تحميل الرسائل، انزلي تلقائياً لآخر رسالة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await _sendMessage(imagePath: picked.path);
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg["sender"] == "طبيب";
    final color = isMe
        ? AppColors.skyBlue.withOpacity(0.9)
        : Colors.white.withOpacity(0.95);
    final textColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg["sender"] != null)
              Text(
                msg["sender"],
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.8)),
              ),
            const SizedBox(
              height: 4,
            ),
            if (msg["image"] != null && msg["image"] != "")
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb
                    ? Image.network(msg["image"], height: 150)
                    : Image.file(File(msg["image"]),
                        height: 150, fit: BoxFit.cover),
              ),
            if (msg["text"] != null && msg["text"].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(msg["text"], style: TextStyle(color: textColor)),
              ),
            Text(
              msg["time"] != null
                  ? msg["time"].toString().substring(11, 16)
                  : "",
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("مجتمع الأهالي",
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/doctorsBackground.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: topPadding, bottom: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) =>
                  _buildMessageBubble(messages[index]),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(children: [
              IconButton(
                  icon: const Icon(Icons.image, color: AppColors.skyBlue),
                  onPressed: _pickImage),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                      hintText: "اكتب رسالة...", border: InputBorder.none),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.send, color: AppColors.skyBlue),
                  onPressed: _sendMessage),
            ]),
          ),
        ]),
      ]),
    );
  }
}
