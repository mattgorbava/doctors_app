import 'package:doctors_app/admin/admin_dashboard.dart';
import 'package:doctors_app/admin/admin_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:doctors_app/splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC4K0hvjI1T5CtHBH6Psx22Qpq4p_nV_BA",
        authDomain: "doctors-app-fb-9a147.firebaseapp.com",
        databaseURL: "https://doctors-app-fb-9a147-default-rtdb.europe-west1.firebasedatabase.app",
        projectId: "doctors-app-fb-9a147",
        storageBucket: "doctors-app-fb-9a147.appspot.com",
        messagingSenderId: "548263883069",
        appId: "1:548263883069:web:c1133835f6ed4387ed9554",
        measurementId: "G-W19SXCMYNH"
      ),
    );
  } else {
    await Firebase.initializeApp();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); 
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', 
      'your_channel_name', 
      importance: Importance.max,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(channel);
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctors App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 5, 216, 5),
          brightness: Brightness.light,
          primary: const Color.fromARGB(255, 5, 216, 5),
          secondary: const Color.fromARGB(255, 0, 127, 0),
        ),
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        print('Navigating to: ${settings.name}');
        
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const SplashScreen());
          case '/oxdpttc0q4':
            return MaterialPageRoute(builder: (context) => const AdminLogin());
          case '/admin-dashboard':
            return MaterialPageRoute(builder: (context) => const AdminDashboard());
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Page Not Found')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('404 - Page Not Found'),
                      ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                        child: const Text('Go Home'),
                      ),
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}