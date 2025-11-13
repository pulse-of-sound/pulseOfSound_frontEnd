import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Colors/colors.dart';
import '../utils/doctor_chat_prefs.dart';

import 'doctor_reports_compose_screen.dart';
import 'parent_profile_details.dart';

class DoctorPrivateChatRoom extends StatefulWidget {
  final String parentId;
  final String parentName;
  final int durationMinutes;
  const DoctorPrivateChatRoom({
    super.key,
    required this.parentId,
    required this.parentName,
    required this.durationMinutes,
  });

  @override
  State<DoctorPrivateChatRoom> createState() => _DoctorPrivateChatRoomState();
}

class _DoctorPrivateChatRoomState extends State<DoctorPrivateChatRoom> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool _sessionEnded = false;
  Timer? _timer;
  int _remainingSeconds = 0;
  late String chatId;

  @override
  void initState() {
    super.initState();
    chatId = "chat_${widget.parentId}";
    _initChat();
  }

  Future<void> _initChat() async {
    final existingChat = await DoctorChatService.loadChatInfo(chatId);
    if (existingChat == null) {
      await DoctorChatService.createPrivateChat(
        chatId: chatId,
        doctorId: "doctor_1",
        parentId: widget.parentId,
        parentName: widget.parentName,
        durationMinutes: widget.durationMinutes,
      );
    }
    _loadMessages();
    _startTimer();
  }

  Future<void> _loadMessages() async {
    final msgs = await DoctorChatService.loadChatMessages(chatId);
    final closed = await DoctorChatService.isChatClosed(chatId);
    setState(() {
      messages = msgs;
      _sessionEnded = closed;
    });
  }

  void _startTimer() {
    _remainingSeconds = widget.durationMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() => _sessionEnded = true);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return "${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _sessionEnded) return;
    await DoctorChatService.addPrivateMessage(
        chatId, "doctor", _controller.text.trim());
    _controller.clear();
    _loadMessages();
  }

  Future<void> _pickImage() async {
    if (_sessionEnded) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await DoctorChatService.addPrivateMessage(chatId, "doctor", "",
          imagePath: picked.path);
      _loadMessages();
    }
  }

  Widget _bubble(Map<String, dynamic> msg) {
    final isMe = msg["sender"] == "doctor";
    final color = isMe ? AppColors.skyBlue : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg["image"] != null && msg["image"] != "")
              Image.file(File(msg["image"]), height: 150, fit: BoxFit.cover),
            if (msg["text"] != null && msg["text"].toString().isNotEmpty)
              Text(msg["text"], style: TextStyle(color: textColor)),
            Text(
              msg["time"] != null
                  ? msg["time"].toString().substring(11, 16)
                  : "",
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 10),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _sessionEnded
              ? "انتهت الجلسة"
              : "الوقت المتبقي: ${_formatTime(_remainingSeconds)}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 👤 أيقونة البروفايل — جديدة
          IconButton(
            icon:
                const Icon(Icons.account_circle, color: Colors.white, size: 26),
            tooltip: "عرض بروفايل وليّ الأمر",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParentProfileDetailsScreen(
                    parentId: widget.parentId,
                  ),
                ),
              );
            },
          ),

          // 🩺 الأيقونة القديمة لكتابة التقرير
          if (_sessionEnded)
            IconButton(
              icon: const Icon(Icons.note_alt_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorReportsComposeScreen(
                      parentId: widget.parentId,
                      parentName: widget.parentName,
                    ),
                  ),
                );
              },
            ),
        ],
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
              padding: const EdgeInsets.only(top: 100),
              itemCount: messages.length,
              itemBuilder: (context, i) => _bubble(messages[i]),
            ),
          ),
          if (!_sessionEnded)
            Container(
              color: Colors.white.withOpacity(0.95),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
