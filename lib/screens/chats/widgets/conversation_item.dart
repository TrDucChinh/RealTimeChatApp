import 'package:flutter/material.dart';

class ConversationItem extends StatelessWidget {
  const ConversationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage('https://example.com/user.jpg'),
        ),
        title: Text(
          'User Name',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Last message preview...',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          '12:00 PM',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
