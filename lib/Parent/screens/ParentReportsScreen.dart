import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/reports_api.dart';
import '../../utils/api_helpers.dart';

class ParentReportsScreen extends StatefulWidget {
  final String parentId;
  const ParentReportsScreen({super.key, required this.parentId});

  @override
  State<ParentReportsScreen> createState() => _ParentReportsScreenState();
}

class _ParentReportsScreenState extends State<ParentReportsScreen> {
  List<dynamic> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final token = await APIHelpers.getSessionToken();
      print(" Loading reports for parent...");
      
      
      final result = await ReportsAPI.getReportsForParent(
        sessionToken: token,
      );

      print(" API Response: $result");
      print(" Result keys: ${result.keys}");
      
     
      List<dynamic> fetchedReports = [];
      if (result.containsKey('result')) {
        print(" Has 'result' key");
        final innerResult = result['result'];
        print(" Inner result: $innerResult");
        if (innerResult is Map && innerResult.containsKey('reports')) {
          fetchedReports = innerResult['reports'] ?? [];
        } else if (innerResult is List) {
          fetchedReports = innerResult;
        }
      } else if (result.containsKey('reports')) {
        print(" Has 'reports' key directly");
        fetchedReports = result['reports'] ?? [];
      }
      
      print(" Found ${fetchedReports.length} reports");

      if (mounted) {
        setState(() {
          reports = fetchedReports;
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() => isLoading = false);
        print(" Error loading reports: $e");
        print(" Stack trace: $stackTrace");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("تقاريري الطبية", style: TextStyle(color: Colors.white)),
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
          : reports.isEmpty
            ? const Center(child: Text("لا توجد تقارير متاحة حالياً", style: TextStyle(fontSize: 18, color: Colors.black54)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  final author = report['author'] ?? {};
                  final doctorName = author['fullName'] ?? 
                                   author['username'] ?? 
                                   "طبيب / أخصائي";
                  
                  
                  String dateText = "التاريخ: ";
                  if (report['created_at'] != null) {
                    try {
                      var createdAt = report['created_at'];
                      String dateStr;
                      
                      
                      if (createdAt is Map && createdAt.containsKey('iso')) {
                        dateStr = createdAt['iso'].toString();
                      } else {
                        dateStr = createdAt.toString();
                      }
                    
                      
                      if (dateStr.length >= 10) {
                        dateText += dateStr.substring(0, 10);
                      } else {
                        dateText += dateStr;
                      }
                    } catch (e) {
                      print("Error parsing date: $e");
                      dateText += "غير محدد";
                    }
                  }
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.pink,
                        child: Icon(Icons.description, color: Colors.white),
                      ),
                      title: Text(
                        doctorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(dateText),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (report['summary'] != null && report['summary'].toString().isNotEmpty) ...[
                                const Text(
                                  "الملخص:",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(report['summary']),
                                const SizedBox(height: 16),
                              ],
                              const Text(
                                "التفاصيل:",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(report['content'] ?? "لا يوجد محتوى"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ]),
    );
  }
}
