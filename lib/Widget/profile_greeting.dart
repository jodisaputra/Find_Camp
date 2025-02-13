import 'package:flutter/material.dart';
import 'package:find_camp/Style/styles.dart';

class ProfileGreeting extends StatelessWidget {
  final String userName;

  const ProfileGreeting({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(
              'assets/profile_image.png'), // Replace with actual image asset
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hallo Fams!', style: Styles.subtitleStyle),
            Text(
              userName,
              style: Styles.headingStyle,
            ),
          ],
        ),
      ],
    );
  }
}
