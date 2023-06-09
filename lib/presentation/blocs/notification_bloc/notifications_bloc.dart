import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_push/config/local_notifications/local_notifications.dart';
import 'package:flutter_push/domain/entities/push_message.dart';

import '../../../firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final Future<void> Function()? requestLocalNotificationPermission;
  final void Function({
    required int id,
    String? body,
    String? data,
    String? title,
  })? showLocalNotification;

  NotificationsBloc(
      {this.requestLocalNotificationPermission, this.showLocalNotification})
      : super(const NotificationsState()) {
    // on<NotificationsEvent>((event, emit) {

    // });
    on<NotificationStatusChanged>(_notificationStatusChanged);
    on<NotificationReceived>(_onPushMessageReceived);

    // verify permission
    _initialStatusCheck();
    // handle foreground messages
    _onForegroundMessage();
  }

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationStatusChanged(
    NotificationStatusChanged event,
    Emitter<NotificationsState> emit,
  ) {
    emit(
      state.copyWith(status: event.status),
    );

    _getFCMToken();
  }

  void _onPushMessageReceived(
    NotificationReceived event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(
      notifications: [
        event.notification,
        ...state.notifications,
      ],
    ));
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));
    _getFCMToken();
  }

  void _getFCMToken() async {
    // final settings = await messaging.getNotificationSettings();
    if (state.status != AuthorizationStatus.authorized) return;

    final token = await messaging.getToken();
    print('FCM Token: $token');
  }

  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;

    final notification = PushMessage(
      messageId:
          message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
          ? message.notification!.android?.imageUrl
          : message.notification!.apple?.imageUrl,
    );
    // print(notification);
    if (showLocalNotification != null) {
      showLocalNotification!(
        id: notification.hashCode,
        body: notification.body,
        data: notification.messageId,
        title: notification.title,
      );
    }
    add(NotificationReceived(notification));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    // request permission to local notifications
    if (requestLocalNotificationPermission != null) {
      await requestLocalNotificationPermission!();
    }
    // await LocalNotifications.requestPermissionLocalNotification();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  PushMessage? getMessageById(String id) {
    final bool exists = state.notifications.any(
      (element) => element.messageId == id,
    );

    if (!exists) return null;

    return state.notifications.firstWhere(
      (element) => element.messageId == id,
    );
  }
}
