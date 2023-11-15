import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'push_notification_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

class NotificationService extends StatefulWidget {
  const NotificationService({super.key, required this.child});

  static String? androidIcon;
  static Function(BuildContext, RemoteMessage)? notificationClickedRouteHandler;

  final Widget child;

  static Future<void> initNotificationService(
      {String? androidIcon,
      Function(BuildContext, RemoteMessage)?
          notificationClickedRouteHandler}) async {
    NotificationService.androidIcon = androidIcon;
    NotificationService.notificationClickedRouteHandler =
        notificationClickedRouteHandler;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<String?> requestPermissionWithTokenOrNull() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      final fcmToken = await messaging.getToken();
      debugPrint(fcmToken);
      return fcmToken;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
      final fcmToken = await messaging.getToken();
      debugPrint(fcmToken);
      return fcmToken;
    } else {
      debugPrint('User declined or has not accepted permission');
      return null;
    }
  }

  @override
  State<NotificationService> createState() => _NotificationServiceState();
}

class _NotificationServiceState extends State<NotificationService> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("onMessage: $message");
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.white,
                playSound: true,
                icon: NotificationService.androidIcon ?? '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      debugPrint('DETAILS: ${message.data}');

      if (message.notification != null) {
        //"route" will be your root parameter you sending from firebase
        if (message.data.isNotEmpty) {
          NotificationService.notificationClickedRouteHandler
              ?.call(context, message);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
