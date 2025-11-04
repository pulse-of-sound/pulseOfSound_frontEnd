import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Colors/colors.dart';
import '../../Doctor/utils/doctor_chat_prefs.dart';

class ParentPrivateChatRoom extends StatefulWidget {
  final String chatId;
  final int durationMinutes;

  const ParentPrivateChatRoom({
    super.key,
    required this.chatId,
    required this.durationMinutes,
  });

  @override
  State<ParentPrivateChatRoom> createState() => _ParentPrivateChatRoomState();
}

class _ParentPrivateChatRoomState extends State<ParentPrivateChatRoom> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _sessionEnded = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startSessionTimer();
  }

  Future<void> _loadMessages() async {
    final data = await DoctorChatService.loadChatInfo(widget.chatId);
    final msgs = await DoctorChatService.loadChatMessages(widget.chatId);
    setState(() {
      messages = msgs.reversed.toList(); // حتى الأحدث يكون بالأسفل
      _sessionEnded = data?['isClosed'] == true;
    });
  }

  void _startSessionTimer() {
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

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _sessionEnded) return;
    final text = _controller.text.trim();
    await DoctorChatService.addPrivateMessage(widget.chatId, "parent", text);
    _controller.clear();

    setState(() {
      messages.add({
        "sender": "parent",
        "text": text,
        "image": "",
        "time": DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> _sendImage() async {
    if (_sessionEnded) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    await DoctorChatService.addPrivateMessage(
      widget.chatId,
      "parent",
      "",
      imagePath: picked.path,
    );

    setState(() {
      messages.add({
        "sender": "parent",
        "text": "",
        "image": picked.path,
        "time": DateTime.now().toIso8601String(),
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg["sender"] == "parent";
    final color = isMe ? AppColors.pink.withOpacity(0.9) : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 270),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: isMe ? const Radius.circular(14) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(14),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg["image"] != null && msg["image"] != "")
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb
                    ? Image.network(msg["image"], height: 150)
                    : Image.file(File(msg["image"]), height: 150),
              ),
            if (msg["text"] != null && msg["text"].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(msg["text"], style: TextStyle(color: textColor)),
              ),
            const SizedBox(height: 3),
            Text(
              msg["time"] != null
                  ? msg["time"].toString().substring(11, 16)
                  : "",
              style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _sessionEnded
              ? "انتهت الجلسة"
              : "الوقت المتبقي: ${_formatTime(_remainingSeconds)}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/chat_Background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 100, bottom: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(messages[index]),
                ),
              ),
              if (!_sessionEnded)
                Container(
                  color: Colors.white.withOpacity(0.95),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(children: [
                    IconButton(
                        icon: const Icon(Icons.image, color: AppColors.pink),
                        onPressed: _sendImage),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                            hintText: "اكتب رسالة...",
                            border: InputBorder.none),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.send, color: AppColors.pink),
                        onPressed: _sendMessage),
                  ]),
                )
              else
                Container(
                  color: Colors.black.withOpacity(0.4),
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    "انتهت الجلسة، لا يمكن إرسال رسائل جديدة.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
