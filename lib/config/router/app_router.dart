import 'package:chat_app_ttcs/screens/auth/pages/confirm_reset.dart';
import 'package:chat_app_ttcs/screens/auth/pages/forgot_password_screen.dart';
import 'package:chat_app_ttcs/screens/auth/pages/register_screen.dart';
import 'package:chat_app_ttcs/screens/auth/pages/user_info.dart';
import 'package:chat_app_ttcs/screens/chats/pages/chat_screen.dart';
import 'package:chat_app_ttcs/screens/create_group/page/create_group_screen.dart';
import 'package:chat_app_ttcs/screens/create_group/page/add_member_screen.dart';
import 'package:chat_app_ttcs/screens/friends/pages/add_friend_screen.dart';
import 'package:chat_app_ttcs/screens/splash/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/custom_bottom_navbar.dart';
import '../../sample_token.dart';
import '../../screens/auth/pages/login_screen.dart';
import '../../screens/chats_conversation/pages/chat_conversation_screen.dart';
import '../../screens/auth/bloc/auth_bloc.dart';
import '../../services/network_service.dart';
import '../../screens/friends/bloc/add_friend_bloc.dart';
import '../../screens/create_group/bloc/create_group_bloc.dart';
import '../../services/storage_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          // Check if the current route should show bottom navigation
          final shouldShowBottomNav =
              state.matchedLocation.startsWith('/chats') ||
                  state.matchedLocation.startsWith('/groups') ||
                  state.matchedLocation.startsWith('/profile') ||
                  state.matchedLocation.startsWith('/menu');

          // Get token from state
          final token = state.extra as String?;
          
          return Scaffold(
            body: child,
            bottomNavigationBar: shouldShowBottomNav 
              ? CustomBottomNavBar(token: token ?? '') 
              : null,
          );
        },
        routes: [
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => BlocProvider(
              create: (context) => AuthBloc(
                NetworkService(
                  baseUrl: baseUrl2,
                  token: '',
                ),
              ),
              child: const LoginScreen(),
            ),
          ),
          GoRoute(
            path: '/forgotPassword',
            name: 'forgotPassword',
            builder: (context, state) => BlocProvider(
              create: (context) => AuthBloc(
                NetworkService(
                  baseUrl: baseUrl2,
                  token: '',
                ),
              ),
              child: const ForgotPasswordScreen(),
            ),
          ),
          GoRoute(
            path: '/confirm',
            name: 'confirm',
            builder: (context, state) {
              final email = state.extra as String? ?? '';
              return BlocProvider(
                create: (context) => AuthBloc(
                  NetworkService(
                    baseUrl: baseUrl2,
                    token: '',
                  ),
                ),
                child: ConfirmReset(email: email),
              );
            },
          ),
          GoRoute(
            path: '/register',
            name: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/user-info',
            name: 'userInfo',
            builder: (context, state) => const UserInfo(),
          ),
          GoRoute(
            path: '/chats',
            name: 'chats',
            builder: (context, state) {
              final token = state.extra as String?;
              if (token == null || token.isEmpty) {
                return BlocProvider(
                  create: (context) => AuthBloc(
                    NetworkService(
                      baseUrl: baseUrl2,
                      token: '',
                    ),
                  ),
                  child: const LoginScreen(),
                );
              }
              return ChatsScreen(token: token);
            },
          ),
          GoRoute(
            path: '/groups',
            name: 'groups',
            builder: (context, state) {
              final token = state.extra as String?;
              if (token == null || token.isEmpty) {
                return BlocProvider(
                  create: (context) => AuthBloc(
                    NetworkService(
                      baseUrl: baseUrl2,
                      token: '',
                    ),
                  ),
                  child: const LoginScreen(),
                );
              }
              return Scaffold(
                body: Center(
                  child: Text('Groups Page'),
                ),
              );
            },
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) {
              final token = state.extra as String?;
              if (token == null || token.isEmpty) {
                return BlocProvider(
                  create: (context) => AuthBloc(
                    NetworkService(
                      baseUrl: baseUrl2,
                      token: '',
                    ),
                  ),
                  child: const LoginScreen(),
                );
              }
              return Scaffold(
                body: Center(
                  child: Text('Profile Page'),
                ),
              );
            },
          ),
          GoRoute(
            path: '/menu',
            name: 'menu',
            builder: (context, state) {
              final token = state.extra as String?;
              if (token == null || token.isEmpty) {
                return BlocProvider(
                  create: (context) => AuthBloc(
                    NetworkService(
                      baseUrl: baseUrl2,
                      token: '',
                    ),
                  ),
                  child: const LoginScreen(),
                );
              }
              return Scaffold(
                body: Center(
                  child: Text('Menu Page'),
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/add-friend',
        name: 'addFriend',
        builder: (context, state) {
          final token = state.extra as String?;
          if (token == null || token.isEmpty) {
            return BlocProvider(
              create: (context) => AuthBloc(
                NetworkService(
                  baseUrl: baseUrl2,
                  token: '',
                ),
              ),
              child: const LoginScreen(),
            );
          }
          return BlocProvider(
            create: (context) => AddFriendBloc(token: token),
            child: AddFriendScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: '/chatConversation/:id',
        name: 'chatConversation',
        builder: (context, state) {
          final String chatId = state.pathParameters['id'] ?? '';
          final params = state.extra as ChatConversationParams;
          return ChatConversationScreen(
            conversationId: chatId,
            conversation: params.conversation,
            token: params.token,
          );
        },
      ),
      GoRoute(
        path: '/create_group',
        name: 'createGroup',
        builder: (context, state) {
          final token = state.extra as String?;
          if (token == null || token.isEmpty) {
            return BlocProvider(
              create: (context) => AuthBloc(
                NetworkService(
                  baseUrl: baseUrl2,
                  token: '',
                ),
              ),
              child: const LoginScreen(),
            );
          }
          return BlocProvider(
            create: (context) => CreateGroupBloc(token: token),
            child: CreateGroupScreen(),
          );
        },
      ),
      GoRoute(
        path: '/add_members',
        name: 'addMembers',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => CreateGroupBloc(token: params['token']),
            child: AddMembersScreen(
              selectedMembers: params['selectedMembers'],
              onMembersSelected: params['onMembersSelected'],
            ),
          );
        },
      ),
    ],
  );
}
