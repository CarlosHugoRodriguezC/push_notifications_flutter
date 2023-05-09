import 'package:flutter_push/presentation/screens/details_screen.dart';
import 'package:flutter_push/presentation/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: '/detail/:pushMessageId',
    builder: (context, state) => DetailsScreen(
        pushMessageId: state.pathParameters['pushMessageId'] ?? ''),
  )
]);
