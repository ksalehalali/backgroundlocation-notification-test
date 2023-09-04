import 'dart:async';
import 'package:backgroundlocationtest/background_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:background_location/background_location.dart';
import 'package:backgroundlocationtest/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
PushNotificationService pushNotificationService = PushNotificationService();

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if(value){
      Permission.notification.request();
    }
  });
  await initializeService();
  await Firebase.initializeApp();
  // BackgroundLocation.setAndroidConfiguration(1);
  // BackgroundLocation.startLocationService(distanceFilter : 1);
  // BackgroundLocation.startLocationService(forceAndroidLocationManager: true);
  // BackgroundLocation.getLocationUpdates((location) {
  //   print(location.latitude);
  // });
  // print("--------------------");
  channel =  const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
  );
  Timer(Duration(seconds: 5), () async{
    // Initialize the FlutterLocalNotificationsPlugin to display the notification
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);


    // Listen to Firebase Cloud Messaging (FCM) push notifications
    pushNotificationService.requestPermission();
    pushNotificationService.loadFCM();
    pushNotificationService.listenFCM();
    // Get device's notification token
    pushNotificationService.getToken();
    Geolocator.requestPermission();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  });

  // FlutterBackgroundService().startService().then((value) async {
  //   while (true) {
  //     // Get the current location in the background
  //     Position? position = await Geolocator.getLastKnownPosition();
  //     // Send the location data to the main isolate
  //     FlutterBackgroundService().invoke({"latitude": position!.latitude, "longitude": position.longitude});
  //     await Future.delayed(Duration(seconds: 15)); // Adjust as needed
  //   }
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }
  String text = "stop service";
@override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            ElevatedButton(onPressed: (){
              FlutterBackgroundService().invoke("setAsForeground");
            }, child: const Text("Foreground Service")),

            SizedBox(height: 20,),
            ElevatedButton(onPressed: (){
              FlutterBackgroundService().invoke("setAsBackground");
            }, child: const Text("Background Service")),

            SizedBox(height: 20,),
            ElevatedButton(onPressed: ()async{
              final service = FlutterBackgroundService();
              bool isRunning = await service.isRunning();

              if(isRunning){
                service.invoke("stopService");

              }else{
                service.startService();
              }

              if(!isRunning){
                text ="stop service";
              }else{
                text ="start service";

              }
              setState(() {

              });
            }, child:  Text(text)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
