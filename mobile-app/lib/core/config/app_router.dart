import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import '../../presentation/pages/auth/splash_page.dart';
import '../../presentation/pages/auth/onboarding_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/auth/verify_phone_page.dart';
import '../../presentation/pages/auth/two_factor_page.dart';
import '../../presentation/pages/stream/home_page.dart';
import '../../presentation/pages/stream/live_stream_page.dart';
import '../../presentation/pages/stream/watch_stream_page.dart';
import '../../presentation/pages/stream/stream_settings_page.dart';
import '../../presentation/pages/stream/stream_replay_page.dart';
import '../../presentation/pages/stream/schedule_stream_page.dart';
import '../../presentation/pages/discover/discover_page.dart';
import '../../presentation/pages/discover/search_page.dart';
import '../../presentation/pages/discover/category_page.dart';
import '../../presentation/pages/chat/chat_list_page.dart';
import '../../presentation/pages/chat/direct_message_page.dart';
import '../../presentation/pages/gift/gift_store_page.dart';
import '../../presentation/pages/gift/gift_history_page.dart';
import '../../presentation/pages/wallet/wallet_page.dart';
import '../../presentation/pages/wallet/purchase_coins_page.dart';
import '../../presentation/pages/wallet/withdraw_page.dart';
import '../../presentation/pages/wallet/transaction_history_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/profile/edit_profile_page.dart';
import '../../presentation/pages/profile/followers_page.dart';
import '../../presentation/pages/profile/following_page.dart';
import '../../presentation/pages/profile/settings_page.dart';
import '../../presentation/pages/profile/privacy_settings_page.dart';
import '../../presentation/pages/profile/notification_settings_page.dart';
import '../../presentation/pages/analytics/streamer_analytics_page.dart';
import '../../presentation/pages/room/voice_room_page.dart';
import '../../presentation/pages/room/party_room_page.dart';
import '../../presentation/pages/room/room_list_page.dart';
import '../../presentation/pages/event/events_page.dart';
import '../../presentation/pages/event/event_detail_page.dart';
import '../../presentation/pages/admin/admin_dashboard_page.dart';
import '../../presentation/widgets/main_scaffold.dart';
import '../../services/auth_service.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-phone',
        builder: (context, state) => VerifyPhonePage(
          phone: state.uri.queryParameters['phone'] ?? '',
        ),
      ),
      GoRoute(
        path: '/two-factor',
        builder: (context, state) => const TwoFactorPage(),
      ),
      GoRoute(
        path: '/live',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LiveStreamPage(),
      ),
      GoRoute(
        path: '/watch/:streamId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => WatchStreamPage(
          streamId: state.pathParameters['streamId']!,
        ),
      ),
      GoRoute(
        path: '/stream-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StreamSettingsPage(),
      ),
      GoRoute(
        path: '/replay/:streamId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => StreamReplayPage(
          streamId: state.pathParameters['streamId']!,
        ),
      ),
      GoRoute(
        path: '/schedule-stream',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ScheduleStreamPage(),
      ),
      GoRoute(
        path: '/room/voice/:roomId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => VoiceRoomPage(
          roomId: state.pathParameters['roomId']!,
        ),
      ),
      GoRoute(
        path: '/room/party/:roomId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PartyRoomPage(
          roomId: state.pathParameters['roomId']!,
        ),
      ),
      GoRoute(
        path: '/dm/:userId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => DirectMessagePage(
          userId: state.pathParameters['userId']!,
        ),
      ),
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminDashboardPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/discover',
            builder: (context, state) => const DiscoverPage(),
            routes: [
              GoRoute(
                path: 'search',
                builder: (context, state) => const SearchPage(),
              ),
              GoRoute(
                path: 'category/:categoryId',
                builder: (context, state) => CategoryPage(
                  categoryId: state.pathParameters['categoryId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/chats',
            builder: (context, state) => const ChatListPage(),
          ),
          GoRoute(
            path: '/gifts',
            builder: (context, state) => const GiftStorePage(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => const GiftHistoryPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletPage(),
            routes: [
              GoRoute(
                path: 'purchase',
                builder: (context, state) => const PurchaseCoinsPage(),
              ),
              GoRoute(
                path: 'withdraw',
                builder: (context, state) => const WithdrawPage(),
              ),
              GoRoute(
                path: 'transactions',
                builder: (context, state) => const TransactionHistoryPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfilePage(),
              ),
              GoRoute(
                path: 'followers',
                builder: (context, state) => const FollowersPage(),
              ),
              GoRoute(
                path: 'following',
                builder: (context, state) => const FollowingPage(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'privacy',
                    builder: (context, state) => const PrivacySettingsPage(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationSettingsPage(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/user/:userId',
            builder: (context, state) => ProfilePage(
              userId: state.pathParameters['userId'],
            ),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const StreamerAnalyticsPage(),
          ),
          GoRoute(
            path: '/rooms',
            builder: (context, state) => const RoomListPage(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsPage(),
            routes: [
              GoRoute(
                path: ':eventId',
                builder: (context, state) => EventDetailPage(
                  eventId: state.pathParameters['eventId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authService = Get.find<AuthService>();
    final isLoggedIn = authService.isLoggedIn;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/splash' ||
        state.matchedLocation == '/onboarding';

    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    if (isLoggedIn && isAuthRoute && state.matchedLocation != '/splash') {
      return '/home';
    }

    return null;
  }
}
