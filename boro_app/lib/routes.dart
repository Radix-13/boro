import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/negotiation_screen.dart';
import 'screens/my_rentals_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/post_item_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reviews_screen.dart';
import 'widgets/main_scaffold.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/rentals', builder: (_, __) => const MyRentalsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/item/:id',
        builder: (_, state) => ItemDetailScreen(itemId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/negotiation/:offerId',
        builder: (_, state) => NegotiationScreen(offerId: int.parse(state.pathParameters['offerId']!)),
      ),
      GoRoute(path: '/post-item', builder: (_, __) => const PostItemScreen()),
      GoRoute(
        path: '/reviews/:userId',
        builder: (_, state) => ReviewsScreen(userId: int.parse(state.pathParameters['userId']!)),
      ),
    ],
  );
}
