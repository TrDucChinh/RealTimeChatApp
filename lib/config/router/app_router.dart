import 'package:chat_app_ttcs/screens/chats/pages/chat_screen.dart';
import 'package:chat_app_ttcs/screens/friends/pages/add_friend_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/custom_bottom_navbar.dart';
import '../../sample_token.dart';
import '../../screens/chats_conversation/pages/chat_conversation_screen.dart';
import '../../models/conversation_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/chats',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          // Check if the current route should show bottom navigation
          final shouldShowBottomNav =
              state.matchedLocation.startsWith('/chats') ||
                  state.matchedLocation.startsWith('/groups') ||
                  state.matchedLocation.startsWith('/profile') ||
                  state.matchedLocation.startsWith('/menu');
          return Scaffold(
            body: child,
            bottomNavigationBar:
                shouldShowBottomNav ? const CustomBottomNavBar() : null,
          );
        },
        routes: [
          GoRoute(
            path: '/chats',
            name: 'chats',
            builder: (context, state) => ChatsScreen(
              token: token,
            ),
          ),
          GoRoute(
            path: '/groups',
            name: 'groups',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text('Groups Page'),
              ),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text('Profile Page'),
              ),
            ),
          ),
          GoRoute(
            path: '/menu',
            name: 'menu',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text('Menu Page'),
              ),
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/add-friend',
        name: 'addFriend',
        builder: (context, state) {
          return const AddFriendScreen();
        },
      ),

      GoRoute(
        path: '/chatConversation/:id',
        name: 'chatConversation',
        builder: (BuildContext context, GoRouterState state) {
          final String chatId = state.pathParameters['id'] ?? '';
          final conversation = state.extra as ConversationModel;
          return ChatConversationScreen(
            conversationId: chatId,
            conversation: conversation,
          );
        },
      ),

      // GoRoute(
      //   path: '/chat/:id',
      //   name: 'chatDetail',
      //   builder: (context, state) {
      //     final chatId = state.pathParameters['id'] ?? '';
      //     return Scaffold(
      //       appBar: AppBar(
      //         title: Text('Chat $chatId'),
      //       ),
      //       body: Center(
      //         child: Text('Chat Detail Screen - ID: $chatId'),
      //       ),
      //     );
      //   },
      // ),
    ],
  );
}
