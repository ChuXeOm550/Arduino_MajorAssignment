import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const ControlPage(),
    );
  }
}

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  bool ledStatus = false;
  int _brightness = 0;
  int _blinkSpeed = 500; // Tốc độ chớp mặc định là 500ms
  bool buzzerStatus = false;

  // Điều chỉnh trạng thái LED (Bật/Tắt)
  void _toggleLED(bool status) {
    setState(() {
      ledStatus = status;
    });
    _dbRef.child("led/status").set(ledStatus ? 1 : 0).then((_) {
      print("LED status updated to ${ledStatus ? 'Bật' : 'Tắt'}");
    }).catchError((error) {
      print("Failed to update LED status: $error");
    });
  }

  // Điều chỉnh độ sáng LED
  void _setBrightness(int brightness) {
    setState(() {
      _brightness = brightness;
    });
    _dbRef.child("led/brightness").set(_brightness).then((_) {
      print("Brightness set to $_brightness");
    }).catchError((error) {
      print("Failed to set brightness: $error");
    });
  }

  // Điều chỉnh tốc độ chớp LED
  void _setBlinkSpeed(int speed) {
    setState(() {
      _blinkSpeed = speed;
    });
    _dbRef.child("led/blink_speed").set(_blinkSpeed).then((_) {
      print("Blink speed set to $_blinkSpeed");
    }).catchError((error) {
      print("Failed to set blink speed: $error");
    });
  }

  // Điều chỉnh trạng thái loa (Bật/Tắt)
  void _toggleBuzzer(bool status) {
    setState(() {
      buzzerStatus = status;
    });
    _dbRef.child("buzzer/status").set(buzzerStatus ? 1 : 0).then((_) {
      print("Buzzer status updated to ${buzzerStatus ? 'Bật' : 'Tắt'}");
    }).catchError((error) {
      print("Failed to update buzzer status: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    _dbRef.child("led/status").onValue.listen((event) {
      final int status = event.snapshot.value as int? ?? 0;
      setState(() {
        ledStatus = status == 1;
      });
    });
    _dbRef.child("led/brightness").onValue.listen((event) {
      final int brightness = event.snapshot.value as int? ?? 0;
      setState(() {
        _brightness = brightness;
      });
    });
    _dbRef.child("led/blink_speed").onValue.listen((event) {
      final int speed = event.snapshot.value as int? ?? 500;
      setState(() {
        _blinkSpeed = speed;
      });
    });
    _dbRef.child("buzzer/status").onValue.listen((event) {
      final int status = event.snapshot.value as int? ?? 0;
      setState(() {
        buzzerStatus = status == 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Điều khiển LED và Loa"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card cho trạng thái LED
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Trạng thái LED",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: Text(
                        ledStatus ? "Bật" : "Tắt",
                        style: TextStyle(
                          fontSize: 16,
                          color: ledStatus ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: ledStatus,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      onChanged: _toggleLED,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card cho điều chỉnh độ sáng
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Độ sáng LED",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: _brightness.toDouble(),
                      min: 0,
                      max: 255,
                      divisions: 255,
                      label: _brightness.toString(),
                      activeColor: Colors.indigo,
                      onChanged: (double value) {
                        _setBrightness(value.toInt());
                      },
                    ),
                    Text(
                      "Độ sáng hiện tại: $_brightness",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card cho điều chỉnh tốc độ chớp LED
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Tốc độ chớp LED",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: _blinkSpeed.toDouble(),
                      min: 100,
                      max: 1000,
                      divisions: 9,
                      label: _blinkSpeed.toString(),
                      activeColor: Colors.indigo,
                      onChanged: (double value) {
                        _setBlinkSpeed(value.toInt());
                      },
                    ),
                    Text(
                      "Tốc độ chớp hiện tại: $_blinkSpeed ms",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card cho điều chỉnh loa
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Trạng thái Loa",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: Text(
                        buzzerStatus ? "Bật" : "Tắt",
                        style: TextStyle(
                          fontSize: 16,
                          color: buzzerStatus ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: buzzerStatus,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      onChanged: _toggleBuzzer,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Footer
            const Text(
              "Ứng dụng điều khiển LED và Loa qua Firebase",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
