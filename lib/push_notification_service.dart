import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' as GETX;



final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
late AndroidNotificationChannel channel;
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('message :: $message');
  print('Handling a background message ${message.messageId}');
  RemoteNotification? notification = message.notification;
  AndroidNotification? androidNotification = message.notification?.android;

  flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher')));
}


class PushNotificationService {

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) => print(token));
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    // ignore: todo
                    // TODO add a proper drawable resource to android (now using one that already exists)
                    icon: '@mipmap/ic_launcher')));
      }

      if(message.notification!.title !="Notification"){
      if( message.notification!.title !.contains("Account Approved")){
        }

      }


    });

    // init from termination
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('from init msg ,terminated state---= ${message.notification!.title}');
        print(message.notification!.body);

        onDidReceiveLocalNotification(id:0,title: message.notification!.title,body: message.notification!.body,payload: 'p',eventData:message.data);

      }
    });

    //in onMessageOpenedApp
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message)async {
      if(message.notification!.title !="Notification"){
        if( message.notification!.title !.contains("Account Approved")){
        }
      }
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;
      if (notification != null) {
        print("data from message on open : ${message.data}");

      }
      if (notification != null && androidNotification != null && Platform.isAndroid) {

      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {


      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }






  //request permitions
  requestPermssion() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  ///on backGround
  /// To verify things are working, check out the native platform logs.


  /// initial message from terminate
  Future<void> initialMessage(BuildContext context) async {
    await requestPermssion();
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message!.notification != null) {
        print(
            'from init msg ,terminated state---= ${message.notification!.title}');
        print(message.notification!.body);

        onDidReceiveLocalNotification(id:0,title: message.notification!.title,body: message.notification!.body,payload: 'p',eventData:message.data);

      }
    });

    ///in forground
    FirebaseMessaging.onMessage.listen((event) {
      if (event.notification != null) {
        print('msg on forground ------');
        print(event.notification!.title);
        print(event.notification!.body);

        print("event data ---------- :: ${event.notification!.body}");
        onDidReceiveLocalNotification(id:0,title: event.notification!.title,body: event.notification!.body,payload: 'p',eventData:event.data);
      }
    });



    ///
    //in onMessageOpenedApp
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;
      if (notification != null) {
        print("data from message on open : ${message.data}");

        onDidReceiveLocalNotification(id:0,title: message.notification!.title,body: message.notification!.body,payload: 'p',eventData:message.data);

      }


      if (notification != null && androidNotification != null && Platform.isAndroid) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("from terminate ${notification.body!}"),
                    ],
                  ),
                ),
              );
            });
      }
    });
  }
//
  void onDidReceiveLocalNotification({int? id, String? title, String? body, String? payload,  eventData}) async {






    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon',);
    DarwinInitializationSettings initializationSettingsIOS = const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', 'High Importance Notifications',
        description: 'this channel desc', importance: Importance.max);
    flutterLocalNotificationsPlugin.show(0, title, body, NotificationDetails(
        android: AndroidNotificationDetails(channel.id,channel.name,channelDescription: channel.description),
        iOS:const DarwinNotificationDetails()
    ));


  }

}