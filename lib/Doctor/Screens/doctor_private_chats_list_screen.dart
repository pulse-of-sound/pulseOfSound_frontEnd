import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/chat_api.dart';
import '../../utils/api_helpers.dart';
import 'doctor_chat_room.dart';

class DoctorPrivateChatsListScreen extends StatefulWidget {
  const DoctorPrivateChatsListScreen({super.key});

  @override
  State<DoctorPrivateChatsListScreen> createState() => _DoctorPrivateChatsListScreenState();
}

class _DoctorPrivateChatsListScreenState extends State<DoctorPrivateChatsListScreen> {
  List<dynamic> chatGroups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final token = await APIHelpers.getSessionToken();
      final result = await ChatAPI.getMyChatGroups(sessionToken: token);
      
      if (mounted) {
        setState(() {
          // Filter only private chats  don't filter by child presence
          chatGroups = (result['chat_groups'] as List)
              .where((g) => g['chat_type'] == 'private')
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading doctor chats: $e");
      if (mounted) setState(() => isLoading = false);
    }
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
        title: const Text(
          "المحادثات الخاصة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/doctorsBackground.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : chatGroups.isEmpty
                  ? const Center(
                      child: Text(
                        "لا توجد محادثات خاصة حالياً",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
                      itemCount: chatGroups.length,
                      itemBuilder: (context, index) {
                        final group = chatGroups[index];
                        final appointment = group['appointment'];
                        final parent = appointment != null ? appointment['user_id'] : null;
                        final child = group['child'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          color: Colors.white.withOpacity(0.95),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.skyBlue,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              parent != null 
                                ? (parent['fullName'] ?? 
                                   parent['mobileNumber'] ??
                                   (parent['username'] != null && 
                                    !parent['username'].toString().toLowerCase().startsWith("is") &&
                                    parent['username'].toString().length < 20
                                     ? parent['username'] 
                                     : "ولي أمر"))
                                : "مجهول",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (child != null)
                                  Text(
                                    "الطفل: ${child['fullName'] ?? 'غير محدد'}",
                                    style: const TextStyle(color: AppColors.skyBlue, fontWeight: FontWeight.w600),
                                  ),
                                Text(
                                  group['last_message'] ?? "بدأ المحادثة الآن...",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  group['chat_status'] == 'archived' ? Icons.archive : Icons.chat_bubble_outline,
                                  size: 18,
                                  color: group['chat_status'] == 'archived' ? Colors.grey : AppColors.skyBlue,
                                ),
                                Text(
                                  group['chat_status'] == 'archived' ? 'منتهية' : 'نشطة',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: group['chat_status'] == 'archived' ? Colors.grey : AppColors.skyBlue,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              final pName = parent != null 
                                  ? (parent['fullName'] ?? 
                                     parent['mobileNumber'] ??
                                     (parent['username'] != null && 
                                      !parent['username'].toString().toLowerCase().startsWith("is") &&
                                      parent['username'].toString().length < 20
                                       ? parent['username'] 
                                       : "ولي أمر"))
                                  : "مجهول";
                              
                              final childName = child != null ? (child['fullName'] ?? "غير محدد") : "غير محدد";
                              final childObjectId = child != null ? (child['objectId'] ?? "") : "";
                              
                              print("Chat Group ${group['objectId']}: child = $child");
                              print("  childName: $childName, childObjectId: $childObjectId");
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DoctorPrivateChatRoom(
                                    parentId: parent != null ? parent['id'] : '',
                                    parentName: pName,
                                    childName: childName,
                                    childId: childObjectId,
                                    appointmentId: appointment != null ? appointment['objectId'] : '',
                                    durationMinutes: 30,
                                    chatGroupId: group['objectId'],
                                  ),
                                ),
                              ).then((_) => _loadChats());
                            },
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
