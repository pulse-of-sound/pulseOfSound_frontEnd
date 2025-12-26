import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/reports_api.dart';
import '../../utils/api_helpers.dart';

class DoctorReportsListScreen extends StatefulWidget {
  const DoctorReportsListScreen({super.key});

  @override
  State<DoctorReportsListScreen> createState() =>
      _DoctorReportsListScreenState();
}

class _DoctorReportsListScreenState extends State<DoctorReportsListScreen> {
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
      print(" Loading reports for doctor...");

      final result = await ReportsAPI.getReportsForDoctor(
        sessionToken: token,
      );

      print(" API Response: $result");

      // Parse response
      List<dynamic> fetchedReports = [];
      if (result.containsKey('result')) {
        final innerResult = result['result'];
        if (innerResult is Map && innerResult.containsKey('reports')) {
          fetchedReports = innerResult['reports'] ?? [];
        } else if (innerResult is List) {
          fetchedReports = innerResult;
        }
      } else if (result.containsKey('reports')) {
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
          title: const Text(
            "تقاريري الطبية",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/doctorsBackground.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : reports.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description_outlined,
                                  size: 64, color: AppColors.skyBlue),
                              SizedBox(height: 16),
                              Text(
                                "لا توجد تقارير متاحة حالياً",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "ستظهر هنا جميع التقارير التي قمت بإرسالها",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          final parent = report['parent'] ?? {};
                          final parentName = parent['fullName'] ??
                              parent['mobileNumber'] ??
                              parent['username'] ??
                              "ولي أمر";

                          final child = report['child'];
                          final childName = child != null
                              ? (child['fullName'] ?? "غير محدد")
                              : "غير محدد";

                          final appointment = report['appointment'];
                          final planTitle = appointment != null
                              ? (appointment['plan_title'] ?? "استشارة")
                              : "استشارة";

                          // Format date
                          String dateText = "";
                          if (report['created_at'] != null) {
                            try {
                              var createdAt = report['created_at'];
                              String dateStr;

                              // Handle Parse Date object
                              if (createdAt is Map &&
                                  createdAt.containsKey('iso')) {
                                dateStr = createdAt['iso'].toString();
                              } else {
                                dateStr = createdAt.toString();
                              }

                              
                              if (dateStr.length >= 10) {
                                dateText = dateStr.substring(0, 10);
                              } else {
                                dateText = dateStr;
                              }
                            } catch (e) {
                              dateText = "غير محدد";
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Colors.white.withOpacity(0.95),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.2),
                            child: ExpansionTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.skyBlue,
                                child: Icon(Icons.description,
                                    color: Colors.white),
                              ),
                              title: Text(
                                parentName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.child_care,
                                          size: 16, color: AppColors.pink),
                                      const SizedBox(width: 4),
                                      Text("الطفل: $childName",
                                          style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 16, color: AppColors.skyBlue),
                                      const SizedBox(width: 4),
                                      Text(dateText,
                                          style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.medical_services,
                                          size: 16, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          planTitle,
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (report['summary'] != null &&
                                          report['summary']
                                              .toString()
                                              .isNotEmpty) ...[
                                        const Row(
                                          children: [
                                            Icon(Icons.summarize,
                                                color: AppColors.skyBlue,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              "الملخص:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppColors.skyBlue),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          report['summary'],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(),
                                      ],
                                      const Row(
                                        children: [
                                          Icon(Icons.description,
                                              color: AppColors.skyBlue,
                                              size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            "التفاصيل:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.skyBlue),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        report['content'] ?? "لا يوجد محتوى",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ));
  }
}
