import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_push/domain/entities/push_message.dart';
import 'package:flutter_push/presentation/blocs/notification_bloc/notifications_bloc.dart';

class DetailsScreen extends StatelessWidget {
  final String pushMessageId;
  const DetailsScreen({super.key, required this.pushMessageId});

  @override
  Widget build(BuildContext context) {
    final PushMessage? pushMessage =
        context.read<NotificationsBloc>().getMessageById(pushMessageId);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Details Push Message'),
        ),
        body: pushMessage != null
            ? _DetailsView(
                pushMessage: pushMessage,
              )
            : const Center(
                child: Text('No message found'),
              ));
  }
}

class _DetailsView extends StatelessWidget {
  final PushMessage pushMessage;

  const _DetailsView({required this.pushMessage});
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: Column(
        children: [
          if (pushMessage.imageUrl != null)
            Image.network(pushMessage.imageUrl!),
          const SizedBox(
            height: 30,
          ),
          Text(
            pushMessage.title,
            style: textStyle.titleMedium,
          ),
          Text(pushMessage.body),
          const Divider(),
          Text(
            pushMessage.data.toString(),
          ),
        ],
      ),
    );
  }
}
