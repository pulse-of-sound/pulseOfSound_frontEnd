import 'package:flutter/material.dart';
import 'package:pulse_of_sound/api/user_api.dart';
import 'package:pulse_of_sound/utils/shared_pref_helper.dart';

class SuperAdminPermissionsTest extends StatefulWidget {
  const SuperAdminPermissionsTest({super.key});

  @override
  State<SuperAdminPermissionsTest> createState() => _SuperAdminPermissionsTestState();
}

class _SuperAdminPermissionsTestState extends State<SuperAdminPermissionsTest> {
  final TextEditingController usernameController = TextEditingController(text: 'yaradiab');
  final TextEditingController passwordController = TextEditingController(text: 'password_here');
  
  String testLog = '';
  bool isLoading = false;

  void addLog(String message) {
    setState(() {
      testLog += '\n${DateTime.now().toString().split('.')[0]} | $message';
    });
    print(' TEST: $message');
  }

  void clearLog() {
    setState(() {
      testLog = '';
    });
  }

  Future<void> testSuperAdminLogin() async {
    setState(() => isLoading = true);
    clearLog();
    
    addLog('═══════════════════════════════════════');
    addLog('🚀 SuperAdmin Login Test');
    addLog('═══════════════════════════════════════');
    
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    
    if (username.isEmpty || password.isEmpty) {
      addLog('❌ ERROR: Username and password are required');
      setState(() => isLoading = false);
      return;
    }
    
    try {
      addLog('📝 Attempting login with: $username');
      
      final result = await UserAPI.loginUser(username, password);
      
      if (result.containsKey('error')) {
        addLog('❌ LOGIN FAILED: ${result['error']}');
        setState(() => isLoading = false);
        return;
      }
      
      addLog('✅ Login successful!');
      addLog('📊 Login Response:');
      result.forEach((key, value) {
        if (key != 'role' && key != 'sessionToken') {
          addLog('   - $key: $value');
        }
      });
      
      final sessionToken = result['sessionToken'] ?? '';
      final role = result['role'] ?? 'Unknown';
      final userId = result['id'] ?? result['objectId'] ?? '';
      
      addLog('');
      addLog('🔐 Session Token: ${sessionToken.isNotEmpty ? '✅ Present (${sessionToken.length} chars)' : '❌ MISSING'}');
      addLog('👤 Role: $role');
      addLog('🆔 User ID: $userId');
      
      // Verify stored preferences
      addLog('');
      addLog('💾 Checking SharedPreferences:');
      final storedRole = SharedPrefsHelper.getUserType();
      final storedToken = SharedPrefsHelper.getToken();
      final isSuperAdmin = SharedPrefsHelper.isSuperAdmin();
      final isAdmin = SharedPrefsHelper.isAdmin();
      
      addLog('   - Stored Role: $storedRole');
      addLog('   - Stored Token: ${storedToken?.isNotEmpty == true ? '✅ Present (${storedToken?.length} chars)' : '❌ MISSING'}');
      addLog('   - isSuperAdmin(): ${isSuperAdmin ? '✅ TRUE' : '❌ FALSE'}');
      addLog('   - isAdmin(): ${isAdmin ? '✅ TRUE' : '❌ FALSE'}');
      
      // Test permissions
      if (sessionToken.isEmpty) {
        addLog('');
        addLog('⚠️  WARNING: sessionToken is empty - some endpoints may fail');
      } else {
        await testSuperAdminPermissions(sessionToken, userId);
      }
      
    } catch (e) {
      addLog('❌ EXCEPTION: $e');
    }
    
    setState(() => isLoading = false);
  }

  Future<void> testSuperAdminPermissions(String sessionToken, String userId) async {
    addLog('');
    addLog('═══════════════════════════════════════');
    addLog('🔐 Testing SuperAdmin Permissions');
    addLog('═══════════════════════════════════════');
    
    // Test 1: Get All Admins (SUPER_ADMIN only)
    addLog('');
    addLog('✨ Test 1: getAllAdmins (SUPER_ADMIN only)');
    try {
      final admins = await UserAPI.getAllAdmins(sessionToken);
      if (admins.isNotEmpty) {
        addLog('✅ SUCCESS: Found ${admins.length} admin(s)');
        for (int i = 0; i < admins.length && i < 3; i++) {
          final admin = admins[i];
          addLog('   - ${admin['username'] ?? 'N/A'} (${admin['fullName'] ?? 'N/A'})');
        }
      } else {
        addLog('⚠️  WARNING: No admins found (might be normal if none exist)');
      }
    } catch (e) {
      addLog('❌ FAILED: $e');
    }
    
    // Test 2: Get All Doctors (Admin+)
    addLog('');
    addLog('✨ Test 2: getAllDoctors (Admin+)');
    try {
      final doctors = await UserAPI.getAllDoctors(sessionToken);
      if (doctors.isNotEmpty) {
        addLog('✅ SUCCESS: Found ${doctors.length} doctor(s)');
        for (int i = 0; i < doctors.length && i < 3; i++) {
          final doctor = doctors[i];
          addLog('   - ${doctor['username'] ?? 'N/A'} (${doctor['fullName'] ?? 'N/A'})');
        }
      } else {
        addLog('⚠️  WARNING: No doctors found');
      }
    } catch (e) {
      addLog('❌ FAILED: $e');
    }
    
    // Test 3: Get All Specialists (Admin+)
    addLog('');
    addLog('✨ Test 3: getAllSpecialists (Admin+)');
    try {
      final specialists = await UserAPI.getAllSpecialists(sessionToken);
      if (specialists.isNotEmpty) {
        addLog('✅ SUCCESS: Found ${specialists.length} specialist(s)');
        for (int i = 0; i < specialists.length && i < 3; i++) {
          final specialist = specialists[i];
          addLog('   - ${specialist['username'] ?? 'N/A'} (${specialist['fullName'] ?? 'N/A'})');
        }
      } else {
        addLog('⚠️  WARNING: No specialists found');
      }
    } catch (e) {
      addLog('❌ FAILED: $e');
    }
    
    addLog('');
    addLog('═══════════════════════════════════════');
    addLog('✅ SuperAdmin Permissions Test Complete');
    addLog('═══════════════════════════════════════');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SuperAdmin Permissions Test'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Login Input Fields
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SuperAdmin Login Credentials',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : testSuperAdminLogin,
                        icon: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(isLoading ? 'Testing...' : 'Test Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Test Results
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Test Results',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (testLog.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: clearLog,
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(minHeight: 300),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: testLog.isEmpty
                            ? const Center(
                                child: Text(
                                  'Test results will appear here...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : Text(
                                testLog,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Instructions
              Card(
                elevation: 2,
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Checklist:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCheckItem('✅ Login successful with sessionToken'),
                      _buildCheckItem('✅ Role is SUPER_ADMIN'),
                      _buildCheckItem('✅ Token stored in SharedPreferences'),
                      _buildCheckItem('✅ isSuperAdmin() returns true'),
                      _buildCheckItem('✅ getAllAdmins() works'),
                      _buildCheckItem('✅ getAllDoctors() works'),
                      _buildCheckItem('✅ getAllSpecialists() works'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
