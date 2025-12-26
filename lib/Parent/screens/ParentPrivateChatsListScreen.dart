import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/chat_api.dart';
import '../../utils/api_helpers.dart';
import 'ParentPrivateChatRoom.dart';

class ParentPrivateChatsListScreen extends StatefulWidget {
  const ParentPrivateChatsListScreen({super.key});

  @override
  State<ParentPrivateChatsListScreen> createState() => _ParentPrivateChatsListScreenState();
}

class _ParentPrivateChatsListScreenState extends State<ParentPrivateChatsListScreen> {
  List<dynamic> chatGroups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatGroups();
  }

  Future<void> _loadChatGroups() async {
    try {
      final token = await APIHelpers.getSessionToken();
      final result = await ChatAPI.getMyChatGroups(sessionToken: token);
      
      if (mounted) {
        setState(() {
          // Filter only private chats
          chatGroups = (result['chat_groups'] as List)
              .filter((g) => g['chat_type'] == 'private')
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        print("Error loading chat groups: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("محادثاتي الخاصة", style: TextStyle(color: Colors.white)),
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
              image: AssetImage("images/chat_Background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.pink))
        : chatGroups.isEmpty 
          ? const Center(child: Text("لا توجد محادثات خاصة حالياً", style: TextStyle(color: Colors.black54, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: chatGroups.length,
              itemBuilder: (context, index) {
                final group = chatGroups[index];
                final appointment = group['appointment'];
                final provider = appointment?['provider_id'] ?? {};
                
                return Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.pink,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(provider['fullName'] ?? provider['username'] ?? "طبيب / أخصائي"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (group['child'] != null)
                          Text("بخصوص: ${group['child']['fullName'] ?? 'طفل'}", 
                               style: TextStyle(color: AppColors.pink, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(group['last_message'] ?? "بدأ المحادثة الآن...", maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: Text(
                      group['chat_status'] == 'archived' ? 'منتهية' : 'نشطة',
                      style: TextStyle(
                        color: group['chat_status'] == 'archived' ? Colors.grey : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ParentPrivateChatRoom(
                            chatGroupId: group['objectId'],
                            durationMinutes: 30, // Default or fetch from plan
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      ]),
    );
  }
}

extension ListFilter on List {
  List filter(bool Function(dynamic) test) {
    return where(test).toList();
  }
}
