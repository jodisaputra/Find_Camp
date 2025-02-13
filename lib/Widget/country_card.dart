import 'package:flutter/material.dart';
import 'package:find_camp/Style/styles.dart';

class CountryCard extends StatelessWidget {
  final String name;
  final String region;
  final String flagAsset;
  final VoidCallback onFavoritePressed;

  const CountryCard({super.key, 
    required this.name,
    required this.region,
    required this.flagAsset,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Image.asset(
              flagAsset,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Styles.headingStyle.copyWith(fontSize: 16),
                  ),
                  Text(
                    region,
                    style: Styles.subtitleStyle,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: onFavoritePressed,
            ),
          ],
        ),
      ),
    );
  }
}
