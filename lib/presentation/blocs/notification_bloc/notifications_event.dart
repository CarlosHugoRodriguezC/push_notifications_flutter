part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class NotificationStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;

  const NotificationStatusChanged(this.status);
  
}

// TODO: notification received event : PushMessage, 


class NotificationReceived extends NotificationsEvent {
  final PushMessage notification;

  const NotificationReceived(this.notification);
}