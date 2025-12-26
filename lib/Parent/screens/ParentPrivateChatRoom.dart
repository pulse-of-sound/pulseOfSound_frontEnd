import 'dart:async';
import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/chat_api.dart';
import '../../utils/api_helpers.dart';

class ParentPrivateChatRoom extends StatefulWidget {
  final String chatGroupId;
  final int durationMinutes;

  const ParentPrivateChatRoom({
    super.key,
    required this.chatGroupId,
    required this.durationMinutes,
  });

  @override
  State<ParentPrivateChatRoom> createState() => _ParentPrivateChatRoomState();
}

class _ParentPrivateChatRoomState extends State<ParentPrivateChatRoom> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> messages = [];
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _sessionEnded = false;
  bool isLoading = true;
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
          isLoading = false;
          
          if (result.containsKey('remaining_seconds')) {
            _remainingSeconds = result['remaining_seconds'];
            if (_timer == null) {
              _startSessionTimer();
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
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _startSessionTimer() {
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

  String _formatTime(int seconds) {
    if (seconds < 0) return "00:00";
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
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

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    // Correct me detection 
    final senderId = msg["send_id"]["id"];
    final isMe = senderId == currentUserId; 
    
    final color = isMe ? AppColors.pink.withOpacity(0.9) : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    final senderName = msg["send_id"]["fullName"] ?? 
                      (msg["send_id"]["username"] != null && !msg["send_id"]["username"].toString().toLowerCase().startsWith("is") ? msg["send_id"]["username"] : null) ??
                      msg["send_id"]["mobileNumber"] ??
                      "مستخدم";

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
            Text(
              senderName + (msg["child_id"] != null && msg["child_id"]["fullName"] != null ? " (بخصوص ${msg["child_id"]["fullName"]})" : ""),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.7)),
            ),
            if (msg["message"] != null && msg["message"].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(msg["message"], style: TextStyle(color: textColor)),
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
          isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.pink))
          : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 100, bottom: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(messages[index] as Map<String, dynamic>),
                ),
              ),
              if (!_sessionEnded)
                Container(
                  color: Colors.white.withOpacity(0.95),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(children: [
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
                  width: double.infinity,
                  child: const Text(
                    "انتهت الجلسة، لا يمكن إرسال رسائل جديدة.",
                    textAlign: TextAlign.center,
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
