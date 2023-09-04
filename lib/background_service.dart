
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future <void> initializeService()async{
  final service = FlutterBackgroundService();

  await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ), androidConfiguration: AndroidConfiguration(
      onStart: onStart, isForegroundMode: true,autoStart: true));
}


@pragma('vm:entry-point')
Future<bool> onIosBackground (ServiceInstance service)async{
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service){
  DartPluginRegistrant.ensureInitialized();
if(service is AndroidServiceInstance){
  service.on('setAsForeground').listen((event) {
    service.setAsForegroundService();
  });
  service.on('setAsBackground').listen((event) {
    service.setAsBackgroundService();
  });
}
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

var lat =0.0;
  var lng =0.0;

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );
  StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
            lat = position!.latitude;
            lng = position.longitude;

        print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
      });

Timer.periodic(Duration(seconds: 3), (timer) async{
  var lat = 0.0;
  if(service is AndroidServiceInstance){
    if(await service.isForegroundService()){
      service.setForegroundNotificationInfo(title: "Routes", content: "sub my routes channel $lat");
    }

  }
  /// some operation on background which in not noticeable to the used everytime

  var headers = {
    'Authorization': 'key=AAAAqCqoA78:APA91bFgCJxNccnm3JkRmDF98gelx28ligsfl82FuBqnlAfdOJBp8VB7CQHRuzxS7HXCfIak4lsPv3hYGXkR92Wpx4W8G2-NyoKDzF-S_Tb7N_ro8LxeIqYohiy7_2cq_1HImi_aTw0g',
    'Content-Type': 'application/json'
  };
  var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
  request.body = json.encode({
    "notification": {
      "body": "$lat",
      "title": lng
    },
    "priority": "high",
    "data": {
      "click_action": "high_importance_channel",
      "id": "1",
      "status": "done",
      "payment_id": "-MpLiSK2K04R_ZjfXrpe"
    },
    "to": "fEOV8bCWT2WwdBk3h4xcyE:APA91bGO86MXy4BJg84-b45TD3eKXBPaj5LPFnAvn904KYKvH8Qt-hahEoKIblROHFpVAQUJmpmMjVtESdrjxgepiiujUBXylmlJ0Ea9CjhVkoPe7KzQb9DULUIJEOSamdTHYrubSVD9"
  });
  request.headers.addAll(headers);

  // http.StreamedResponse response = await request.send();
  //
  // if (response.statusCode == 200) {
  //   print(await response.stream.bytesToString());
  // }
  // else {
  //   print(response.reasonPhrase);
  // }



  print( "background service running...");
  service.invoke('update');

});
}