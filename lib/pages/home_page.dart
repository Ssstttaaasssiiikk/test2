import 'package:chat_flutter_firebase/components/app_drawer.dart';
import 'package:chat_flutter_firebase/components/user_tile.dart';
import 'package:chat_flutter_firebase/pages/chat_page.dart';
import 'package:chat_flutter_firebase/services/auth/auth_service.dart';
import 'package:chat_flutter_firebase/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Чаты',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      drawer: const AppDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Ошибка'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('Загрузка'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Нет пользователей'));
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    final email =
        userData['email'] as String? ?? 'Unknown';
    final currentUserEmail = _authService.getCurrentUser();

    // ignore: unrelated_type_equality_checks
    if (email != currentUserEmail) {
      return UserTile(
        text: email,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData['email'],
                receiverID: userData['uid'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
