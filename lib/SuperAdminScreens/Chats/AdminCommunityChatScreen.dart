import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/chat_api.dart';
import '../../utils/api_helpers.dart';

class AdminCommunityChatScreen extends StatefulWidget {
  const AdminCommunityChatScreen({super.key});

  @override
  State<AdminCommunityChatScreen> createState() =>
      _AdminCommunityChatScreenState();
}

class _AdminCommunityChatScreenState extends State<AdminCommunityChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> messages = [];
  String? communityGroupId;
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    currentUserId = await APIHelpers.getUserId();
    _initCommunityChat();
  }

  Future<void> _initCommunityChat() async {
    try {
      final token = await APIHelpers.getSessionToken();
    
      
      final groupsResult = await ChatAPI.getMyChatGroups(sessionToken: token);
      final groups = groupsResult['chat_groups'] as List;
      
      var communityGroup = groups.firstWhere(
        (g) => g['chat_type'] == 'community',
        orElse: () => null,
      );

      if (communityGroup == null) {
        
        final createResult = await ChatAPI.createCommunityChatGroup(
          sessionToken: token,
          name: "المجتمع العام",
        );
        communityGroupId = createResult['chat_group_id'];
      } else {
        communityGroupId = communityGroup['objectId'];
      }

      await _loadMessages();
    } catch (e) {
      print("Error initializing community chat for admin: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    if (communityGroupId == null) return;
    try {
      final token = await APIHelpers.getSessionToken();
      final result = await ChatAPI.getChatMessages(
        sessionToken: token,
        chatGroupId: communityGroupId!,
      );
      if (mounted) {
        setState(() => messages = result['messages']);
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      print("Error loading community messages: $e");
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || communityGroupId == null) return;

    try {
      final token = await APIHelpers.getSessionToken();
      await ChatAPI.sendChatMessage(
        sessionToken: token,
        chatGroupId: communityGroupId!,
        message: text,
      );
      
      _controller.clear();
      await _loadMessages();
    } catch (e) {
      print("Error sending admin message: $e");
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final senderId = msg["send_id"]["id"];
    final isMe = senderId == currentUserId; 
    
    final color = isMe
        ? Colors.blueGrey.withOpacity(0.9)
        : Colors.white.withOpacity(0.95);
    final textColor = isMe ? Colors.white : Colors.black87;

    final senderName = (msg["send_id"]["fullName"] ?? 
                      (msg["send_id"]["username"] != null && !msg["send_id"]["username"].toString().toLowerCase().startsWith("is") ? msg["send_id"]["username"] : null) ??
                      msg["send_id"]["mobileNumber"] ??
                      "مستخدم") + (msg["child_id"] != null && msg["child_id"]["fullName"] != null ? " (بخصوص ${msg["child_id"]["fullName"]})" : "");

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isMe ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            Text(msg["message"], style: TextStyle(color: textColor)),
            Text(
              msg["time"] != null
                  ? msg["time"].toString().substring(11, 16)
                  : "",
              style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11),
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
        title: const Text("رقابة المجتمع",
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
              image: AssetImage("images/Admin.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
                bottom: 12,
                left: 12,
                right: 12,
              ),
              itemCount: messages.length,
              itemBuilder: (context, index) =>
                  _buildMessageBubble(messages[index] as Map<String, dynamic>),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                      hintText: "اكتب رسالة إشرافية...", border: InputBorder.none),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueGrey),
                  onPressed: _sendMessage),
            ]),
          ),
        ]),
      ]),
    );
  }
}
