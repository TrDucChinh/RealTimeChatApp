import 'package:flutter/material.dart';
import 'package:chat_app_ttcs/models/user_model.dart';
import 'package:chat_app_ttcs/common/widgets/base_image.dart';

class UserTile extends StatelessWidget {
  final UserModel user;

  const UserTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: user.avatarUrl.isNotEmpty
              ? BaseCacheImage(
                  url: user.avatarUrl,
                  width: 40,
                  height: 40,
                  errorWidget: Center(
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                style: TextStyle(fontSize: 16),
              ),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}