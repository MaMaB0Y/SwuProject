import "dart:convert";
import 'package:flutter/material.dart';
import "Backend/system.dart" as system;
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:logger/logger.dart";
import "package:permission_handler/permission_handler.dart";
import "package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart";

final log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    printEmojis: true,
  )
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await system.NotificationService().init();
  runApp(const DaiBuddyApp());
}

class DaiBuddyApp extends StatelessWidget {
  const DaiBuddyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DAIBUDDY',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: 'Kanit',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget
{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
{
  @override
  void initState()
  {
    super.initState();
    system.NotificationService().startClockLogger();
    _checkRegister();
  }
  Future<void> _checkRegister() async //We also request phone call here
  {
    await [Permission.phone,Permission.notification].request();
    const storage = FlutterSecureStorage();
    await Future.delayed(const Duration(seconds: 2));
    String? password = await storage.read(key: "Name");
    if (!mounted) return;

    if (password != null && password.isNotEmpty)
    {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
    else
    {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
    }
  }
  @override
  Widget build(BuildContext context) 
  {
    return const Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("DAIBUDDY", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green)),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          )
        ],
      )
      )
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>{
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'DAIBUDDY',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: Text('กรอกข้อมูลเพื่อเริ่มต้นใช้งาน', style: TextStyle(fontSize: 16, color: Colors.grey))),
              const SizedBox(height: 32),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'ชื่อ', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'นามสกุล', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์ผู้ดูแล', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'รหัสผ่านหลัก', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  String firstname = _firstNameController.text.trim();
                  String surname = _lastNameController.text.trim();
                  String phone = _phoneController.text.trim();
                  String password = _passwordController.text.trim();
                  if (firstname.isEmpty ||
                  surname.isEmpty||
                  phone.isEmpty||
                  password.isEmpty)
                  {
                    showDialog(context: context, barrierDismissible:false, builder: (BuildContext context){return AlertDialog
                    (
                      title: const Text("แจ้งเตือน",style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text("กรุณากรอกข้อมูลให้ครบทุกช่อง!"),
                      actions: [TextButton(
                        onPressed: () 
                        {
                          Navigator.of(context).pop();
                        },
                        child: const Text("ตกลง", style: TextStyle(fontWeight: FontWeight.bold)))],
                    );
                    });
                    return;
                  }
                  await system.write(
                    name: firstname,
                    surname: surname,
                    phone: phone,
                    password: password);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('สมัครสมาชิกสำเร็จ!')));
                  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const MainScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('สมัครใช้งาน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen>{
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'DAIBUDDY',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: Text('กรุณากรอกรหัสผ่านที่เคยสมัครไว้', style: TextStyle(fontSize: 16, color: Colors.grey))),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'รหัสผ่าน', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  String password = _passwordController.text.trim();
                  if (password.isEmpty)
                  {
                    showDialog(context: context, barrierDismissible:false, builder: (BuildContext context){return AlertDialog
                    (
                      title: const Text("แจ้งเตือน",style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text("กรุณากรอกรหัสผ่าน!"),
                      actions: [TextButton(
                        onPressed: () 
                        {
                          Navigator.of(context).pop();
                        },
                        child: const Text("ตกลง", style: TextStyle(fontWeight: FontWeight.bold)))],
                    );
                    });
                    return;
                  }
                  bool check = await system.readcompare(password: password);
                  if (!context.mounted) return;
                  if (!check)
                  {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('รหัสผิด!')));
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เข้าสู่ระบบสำเร็จ!')));
                  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const MainScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _name = "Fallback Value";
  bool _isloading = true;
  final storage = const FlutterSecureStorage();
  @override
  void initState()
  {
    super.initState();
    
    _logfetch();
  }
  Future<void> _logfetch() async //To Fetch Value and log stuff
  {
    Map<String, String> allValue = await storage.readAll();
    log.i("*****STORAGE INSPECTOR*****");
    allValue.forEach((key, value)
    {
      log.d("Key: $key | Value: $value");
    });
    if(!mounted) return;
    setState(() {
      _name = "${allValue['Name']} ${allValue['Surname']}";
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isloading)
    {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green))
      );
    }
    final List<Widget> pages = [
      HomeScreen(
        userName: _name, 
        onRecordsUpdated: () {
          setState(() {});
        },
      ),
      ProfileScreen(userName: _name),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'หน้าหลัก'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'ข้อมูลส่วนตัว'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userName;
  final VoidCallback onRecordsUpdated;
  final storage = const FlutterSecureStorage();
  const HomeScreen({
    super.key, 
    required this.userName,
    required this.onRecordsUpdated,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<system.MedicationJSON>> _medHistory;
  int currentDayIndex = 0;
  double currentSugar = 0;
  final _sugarInputController = TextEditingController();
  String _selectedDay = 'จ.';
  final List<String> _daysOfWeek = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];
  @override
  void initState()
  {
    super.initState();
    _refreshsugar();
    _medHistory = _readHistory();
  }
  Future<void> _updateSugarLevel(double value) async //Check and Update Sugar Level/Emergency
  {
    await widget.storage.write(key: currentDayIndex.toString(), value: value.toString());
    await _refreshsugar();
    if (!mounted) return;
    widget.onRecordsUpdated();
    if (value >= 250) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EmergencyAlertScreen()),
      );
    }
  }
  Future<void> _refreshsugar() async //Refresh the currentSugar and currentDayIndex
  {
    currentDayIndex = _daysOfWeek.indexOf(_selectedDay);
    currentSugar = double.tryParse(await widget.storage.read(key: currentDayIndex.toString()) ?? "0.0") ?? 0.0; //Read data and parse it to Double. two ?? in case data missing(not exist) or corruption
    if (!mounted) return;
    setState(() {
      _medHistory = _readHistory();
    });
  }
  Future<List<system.MedicationJSON>> _readHistory() async
  {
    try
    {
      String? rawJson = await widget.storage.read(key: "med_list");
      if (rawJson == null) return [];
      List<dynamic> decodedList = jsonDecode(rawJson);
      return decodedList.map((item) => system.MedicationJSON.fromJson(item)).toList();
    }
    catch(e, stackTrace)
    {
      log.d('Crash inside _readMed(): $e');
      log.d('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {

    Color statusColor = Colors.green;
    String statusText = '• ระดับสีเขียว ปกติ';
    if (currentSugar >= 250) {
      statusColor = Colors.red;
      statusText = '• ระดับสีแดง อันตรายวิกฤต';
    } else if (currentSugar > 140) {
      statusColor = Colors.orange;
      statusText = '• ระดับสีเหลือง เสี่ยงสูง';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('DAIBUDDY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('สวัสดีคุณ ${widget.userName}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Card(
              color: statusColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: statusColor, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.bloodtype, color: statusColor, size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ระดับน้ำตาลวัน ($_selectedDay)', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                          Text('${currentSugar.toStringAsFixed(0)} mg/dL', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: statusColor)),
                          Text(statusText, style: TextStyle(fontSize: 14, color: statusColor, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('บันทึกระดับน้ำตาลประจำวัน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedDay,
                      items: _daysOfWeek.map((String day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Text(day, style: const TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        if (newValue != null) {
                            setState(() {
                              _selectedDay = newValue;
                            });
                            await _refreshsugar();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _sugarInputController,
                        decoration: const InputDecoration(
                          labelText: 'ค่าน้ำตาล (mg/dL)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        double? enteredValue = double.tryParse(_sugarInputController.text);
                        if (enteredValue != null) {
                          await _updateSugarLevel(enteredValue);
                          if (!context.mounted) return;
                          _sugarInputController.clear();
                          FocusScope.of(context).unfocus();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      child: const Text('บันทึก'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('รายการยาที่ต้องทานวันนี้', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<List<system.MedicationJSON>>( //List For today's medication
              future: _medHistory,
              builder: (context, snapshot)
              {
                if (snapshot.connectionState == ConnectionState.waiting)
                {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError)
                {
                  log.i("***Snapshot Error***");
                  log.d(snapshot.data);
                  return Center(child: Text("Error Loading History: ${snapshot.error}"));
                }
                var meds = (snapshot.data ?? []).where((val) {
                  var unpackeddate = val.date.split("/");
                  DateTime date = DateTime(int.parse(unpackeddate[2]),int.parse(unpackeddate[1]),int.parse(unpackeddate[0]));
                  return currentDayIndex == (date.weekday-1);
                }).toList(); //Check each data, containing it in val, split and pack val into ISO (yyyy-mm-dd) and then return the choosing day and the List it.
                if (meds.isEmpty)
                {
                  return const Center(
                    child: Text("ไม่มียาที่ต้องทานในวันนี้", 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey))
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meds.length,
                  itemBuilder: (context, index)
                  {
                    final med = meds[index];
                    return Card(
                      child: ListTile(
                        title: Text("${med.name} (${med.dosage}mg)", 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("วันที่ ${med.date} - ${med.time}\nหมายเหตุ: ${med.notes.isEmpty ? "-" : med.notes}"),
                        isThreeLine: true,
                        ),
                    );
                  }
                );
              }
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  List<Future<String?>> readFutures = List.generate(_daysOfWeek.length, (i) => widget.storage.read(key:i.toString())); //Generate List using _daysOfWeek length and read through each one (kinda like list comprehension for loop)
                  List<String?> rawResults = await Future.wait(readFutures); //Wait for them all to finish
                  List<double> weeklySugarData = rawResults.map((val) => double.tryParse(val ?? "0.0") ?? 0.0).toList(); //Loop through rawResult using map and then List them.

                  if (!context.mounted) return;
                  bool hasData = weeklySugarData.any((val) => val > 0);
                  if (!hasData)
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("ยังไม่มีข้อมูลบันทึกน้ำตาลในสัปดาห์นี้"),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2)),
                    );
                    return;
                  }
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => SummaryGraphScreen(sugarRecords: weeklySugarData,)),
                  );
                },
                icon: const Icon(Icons.bar_chart_rounded),
                label: const Text('ค่าน้ำตาลรอบ 7 วันล่าสุด / สรุปผล'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyAlertScreen extends StatelessWidget {
  const EmergencyAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
            const SizedBox(height: 24),
            const Text(
              'เตือน!\nค่าน้ำตาลพุ่งสูงเกินไป',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '> 250 mg/dL',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.yellow),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'กรุณาติดต่อผู้ดูแลหรือกดปุ่มโทรด่วนด้านล่างทันที',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async 
              {
                const number = "1669";
                await FlutterPhoneDirectCaller.callNumber(number);
              },
              icon: const Icon(Icons.phone_in_talk, size: 28),
              label: const Text('โทรด่วนโรงพยาบาล (1669)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE / ปิดหน้าต่างเตือน', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryGraphScreen extends StatelessWidget {
  final List<double> sugarRecords;
  const SummaryGraphScreen({super.key, required this.sugarRecords});

  @override
  Widget build(BuildContext context) {
    List<double> validRecords = sugarRecords.where((sugar) => sugar > 0).toList();
    double sum = validRecords.reduce((a, b) => a + b);
    double average = sum / validRecords.length;
    double maxSugar = validRecords.reduce((a, b) => a > b ? a : b);
    double minSugar = validRecords.reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('สรุปผลและค่าน้ำตาล'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ค่าน้ำตาลรอบ 7 วันล่าสุด', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildGraphBar('จ.', sugarRecords[0]),
                  _buildGraphBar('อ.', sugarRecords[1]),
                  _buildGraphBar('พ.', sugarRecords[2]),
                  _buildGraphBar('พฤ.', sugarRecords[3]),
                  _buildGraphBar('ศ.', sugarRecords[4]),
                  _buildGraphBar('ส.', sugarRecords[5]),
                  _buildGraphBar('อา.', sugarRecords[6]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('ผลสรุปและค่าสถิติคำนวณ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatRow('ค่าเฉลี่ยระดับน้ำตาล', '${average.toStringAsFixed(1)} mg/dL', Colors.black),
                    const Divider(),
                    _buildStatRow('ค่าสูงสุดที่บันทึก', '${maxSugar.toStringAsFixed(0)} mg/dL', Colors.red),
                    const Divider(),
                    _buildStatRow('ค่าต่ำสุดที่บันทึก', '${minSugar.toStringAsFixed(0)} mg/dL', Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphBar(String day, double value) {
    double heightRatio = (value / 300) * 140; 
    if (heightRatio > 140) heightRatio = 140; 
    
    Color barColor = Colors.green;
    if (value >= 250) {
      barColor = Colors.red;
    } else if (value > 140) {
      barColor = Colors.orange;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Container(width: 22, height: heightRatio, decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatRow(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final String userName;
  const ProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('การตั้งค่าบุคคล'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(radius: 46, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 54, color: Colors.white)),
                const SizedBox(height: 12),
                Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('ผู้ดูแลระบบ/ผู้ป่วยหลัก', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.badge_outlined, color: Colors.green),
            title: const Text('ข้อมูลส่วนตัว'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined, color: Colors.orange),
            title: const Text('จัดการตารางยา'),
            subtitle: const Text('ลงทะเบียนและประวัติบันทึกข้อมูลยาใหม่'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicationManagementScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined, color: Colors.red),
            title: const Text('การแจ้งเตือน'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class MedicationManagementScreen extends StatelessWidget {
  const MedicationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('จัดการตารางยา'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.history), text: 'ประวัติการทานยา'),
              Tab(icon: Icon(Icons.add_box), text: 'บันทึกข้อมูลยาใหม่'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MedicationHistoryTab(),
            AddMedicationFormTab(),
          ],
        ),
      ),
    );
  }
}

class MedicationHistoryTab extends StatefulWidget
{
  final storage = const FlutterSecureStorage();
  const MedicationHistoryTab({super.key});

  @override
  State<MedicationHistoryTab> createState() => _MedicationHistoryTab();
}

class _MedicationHistoryTab extends State<MedicationHistoryTab> {
  
  Future<List<system.MedicationJSON>> _readMed() async
  {
    try
    {
      String? rawJson = await widget.storage.read(key: "med_list");
      if (rawJson == null) return [];
      List<dynamic> decodedList = jsonDecode(rawJson);
      return decodedList.map((item) => system.MedicationJSON.fromJson(item)).toList();
    }
    catch(e, stackTrace)
    {
      log.d('Crash inside _readMed(): $e');
      log.d('StackTrace: $stackTrace');
      rethrow;
    }
  }



  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder<List<system.MedicationJSON>>(
      future: _readMed(),
      builder: (context, snapshot)
      {
        if (snapshot.connectionState == ConnectionState.waiting)
        {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError)
        {
          log.i("***Snapshot Error***");
          log.d(snapshot.data);
          return Center(child: Text("Error Loading History: ${snapshot.error}"));
        }
        final meds = snapshot.data ?? [];

        if (meds.isEmpty)
        {
          return const Center(
            child: Text("ไม่มีประวัติการทานยา", 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey))
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: meds.length,
          itemBuilder: (context, index)
          {
            final med = meds[index];
            return Card(
              child: ListTile(
                title: Text("${med.name} (${med.dosage}mg)", 
                style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("วันที่ ${med.date} - ${med.time}\nหมายเหตุ: ${med.notes.isEmpty ? "-" : med.notes}"),
                isThreeLine: true,
                ),
            );
          }
        );
      }
    );
  }
}

class AddMedicationFormTab extends StatefulWidget {
  const AddMedicationFormTab({super.key});
  final storage = const FlutterSecureStorage();
  @override
  State<AddMedicationFormTab> createState() => _AddMedicationFormTab();
}

class _AddMedicationFormTab extends State<AddMedicationFormTab> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  Future<void> _pickDate(BuildContext context) async
  {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2200));
    if (picked != null)
    {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }
  Future<void> _pickTime(BuildContext context) async
  {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now());
    if (picked != null)
    {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }
  void _clearForm()
  {
    _nameController.clear();
    _dateController.clear();
    _timeController.clear();
    _dosageController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Medication Name (ชื่อยา)',
            border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(
            controller:_dateController,
            readOnly: true,
            onTap: () => _pickDate(context),
            decoration: const InputDecoration(labelText: 'Date Taken (วันที่ระบุ)',
            suffixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder()),),
          const SizedBox(height: 16),
          TextField(
            controller: _timeController,
            readOnly: true,
            onTap: () => _pickTime(context),
            decoration: const InputDecoration(labelText: 'Select Time (เลือกเวลาทาน)',
            suffixIcon: Icon(Icons.access_time),
            border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(
            controller: _dosageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Dosage (ขนาดบรรจุ mg)',border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Write your notes (หมายเหตุเพิ่มเติม)', border: OutlineInputBorder()), maxLines: 3),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {

              if (_nameController.text.trim().isEmpty||
              _dateController.text.trim().isEmpty||
              _timeController.text.trim().isEmpty||
              _dosageController.text.trim().isEmpty)
              {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("กรุณากรอกวันเวลาและปริมาณยาให้ครบ")));
                return;
              }
              final newMed = system.MedicationJSON(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: _nameController.text.trim(),
                date: _dateController.text,
                time: _timeController.text,
                dosage: double.tryParse(_dosageController.text) ?? 0.0,
                notes: _notesController.text.trim(),);
              String? existingData = await widget.storage.read(key: "med_list"); //Read Json Data from stroage
              List<system.MedicationJSON> currentList = [];
              if (existingData != null)
              {
                List<dynamic> decodedJson = jsonDecode(existingData); //Decode Existing Data
                currentList = decodedJson.map((item) => system.MedicationJSON.fromJson(item)).toList();
              }
              currentList.add(newMed);
              String updatedJson = jsonEncode(currentList.map((m) => m.toJson()).toList());
              await widget.storage.write(key:"med_list", value: updatedJson);
              try
              {
                await system.NotificationService().scheduleMedNotification(newMed);
                //await system.NotificationService().showInstantNotification(); This is for debug notifs
              }
              catch(e, stack)
              {
                log.i("Error on notification!");
                log.e("Error : $e");
                log.e("Stacktrace: $stack");
                rethrow;
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลตารางยาใหม่สำเร็จ เพื่อแจ้งเตือนในวันถัดไป')));
              _clearForm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('SUBMIT LOG / บันทึกข้อมูล', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
