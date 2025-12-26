import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Colors/colors.dart';
import '../../api/chat_api.dart';
import '../../utils/api_helpers.dart';
import 'doctor_reports_compose_screen.dart';
import 'parent_profile_details.dart';

class DoctorPrivateChatRoom extends StatefulWidget {
  final String parentId;
  final String parentName;
  final String? childName;
  final String? childId;
  final String appointmentId;
  final int durationMinutes;
  final String chatGroupId;
  const DoctorPrivateChatRoom({
    super.key,
    required this.parentId,
    required this.parentName,
    this.childName,
    this.childId,
    required this.appointmentId,
    required this.durationMinutes,
    required this.chatGroupId,
  });

  @override
  State<DoctorPrivateChatRoom> createState() => _DoctorPrivateChatRoomState();
}

class _DoctorPrivateChatRoomState extends State<DoctorPrivateChatRoom> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> messages = [];
  bool _sessionEnded = false;
  Timer? _timer;
  int _remainingSeconds = 0;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    currentUserId = await APIHelpers.getUserId();
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final token = await APIHelpers.getSessionToken();
      final result = await ChatAPI.getChatMessages(
        sessionToken: token,
        chatGroupId: widget.chatGroupId,
      );
      
      if (mounted) {
        setState(() {
          messages = result['messages'];
          
          if (result.containsKey('remaining_seconds')) {
            _remainingSeconds = result['remaining_seconds'];
            if (_timer == null) {
              _startTimer();
            }
          }
        });
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        if (mounted) setState(() => _sessionEnded = true);
      } else {
        if (mounted) setState(() => _remainingSeconds--);
      }
    });
  }

  String _formatTime(int s) {
    if (s < 0) return "00:00";
    final m = s ~/ 60;
    final sec = s % 60;
    return "${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sessionEnded) return;

    try {
      final token = await APIHelpers.getSessionToken();
      final result = await ChatAPI.sendChatMessage(
        sessionToken: token,
        chatGroupId: widget.chatGroupId,
        message: text,
      );

      if (result.containsKey('error')) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(result['error'])),
           );
           if (result['error'].toString().contains('expired')) {
              setState(() => _sessionEnded = true);
           }
         }
      } else {
        _controller.clear();
        await _loadMessages();
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Future<void> _pickImage() async {
    if (_sessionEnded) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      
    }
  }

  Widget _bubble(Map<String, dynamic> msg) {
    
    final senderId = msg["send_id"]["id"];
    final isMe = senderId == currentUserId; 
    
    final color = isMe ? AppColors.skyBlue : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    final senderName = msg["send_id"]["fullName"] ?? 
                      (msg["send_id"]["username"] != null && !msg["send_id"]["username"].toString().toLowerCase().startsWith("is") ? msg["send_id"]["username"] : null) ??
                      msg["send_id"]["mobileNumber"] ??
                      "مستخدم";

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
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              senderName + (msg["child_id"] != null && msg["child_id"]["fullName"] != null ? " (بخصوص ${msg["child_id"]["fullName"]})" : ""),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.7)),
            ),
            if (msg["message"] != null && msg["message"].toString().isNotEmpty)
              Text(msg["message"], style: TextStyle(color: textColor)),
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
    _scrollController.dispose();
    _controller.dispose();
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
                      childName: widget.childName ?? "غير محدد",
                      childId: widget.childId ?? "",
                      appointmentId: widget.appointmentId,
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
