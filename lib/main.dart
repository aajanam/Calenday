import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jadwalku/helper/notification_helper.dart';
import 'package:jadwalku/pages/landing_page.dart';
import 'package:jadwalku/provider/discussion_provider.dart';
import 'package:jadwalku/provider/events_provider.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:onesignal_flutter/onesignal_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.shared.init(
      "6bc984f5-33ee-469f-b1f4-10ce18d3116b",
      iOSSettings: null
  );

  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  tz.initializeTimeZones();
  Admob.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => DiscussionProvider()),
        ChangeNotifierProvider(
            create: (context) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => EventProvider(),
        ),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        Provider<AuthBase>(
          create: (context) => Auth(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Calgenda',
        theme: ThemeData(
          iconTheme: IconThemeData(color: Colors.white),
          fontFamily: 'OpenSans',
          primaryColor: Colors.cyan.shade600,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LandingPage(),
      ),
    );
  }
}
