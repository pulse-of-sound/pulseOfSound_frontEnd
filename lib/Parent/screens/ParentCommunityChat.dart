import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Colors/colors.dart';
import '../../api/chat_api.dart';
import '../../utils/api_helpers.dart';

class ParentCommunityChat extends StatefulWidget {
  const ParentCommunityChat({super.key});

  @override
  State<ParentCommunityChat> createState() => _ParentCommunityChatState();
}

class _ParentCommunityChatState extends State<ParentCommunityChat> {
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
      print("Error initializing community chat: $e");
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
      print("Error loading messages: $e");
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
      print("Error sending message: $e");
    }
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    // Correct me detection 
    final senderId = msg["send_id"]["id"];
    final isMe = senderId == currentUserId; 
    
    final color = isMe ? AppColors.pink : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    
    
    final senderName = (msg["send_id"]["fullName"] ?? 
                      msg["send_id"]["mobileNumber"] ??
                      (msg["send_id"]["username"] != null && 
                       !msg["send_id"]["username"].toString().toLowerCase().startsWith("is") &&
                       msg["send_id"]["username"].toString().length < 20
                        ? msg["send_id"]["username"] 
                        : null) ??
                      "مستخدم") + (msg["child_id"] != null && msg["child_id"]["fullName"] != null ? " (بخصوص ${msg["child_id"]["fullName"]})" : "");

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            Text(msg["message"], style: TextStyle(color: textColor)),
            Text(
              msg["time"] != null ? msg["time"].toString().substring(11, 16) : "",
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
        title: const Text("مجتمع النبض", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(children: [
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
                  itemBuilder: (context, i) => _buildBubble(messages[i] as Map<String, dynamic>),
                ),
              ),
              Container(
                color: Colors.white.withOpacity(0.95),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: "اكتب رسالة...", border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.pink),
                    onPressed: _sendMessage,
                  ),
                ]),
              ),
            ]),
      ]),
    );
  }
}
