import 'package:flutter/material.dart';
import 'package:find_camp/Style/styles.dart';

class RegionItem extends StatelessWidget {
  final String region;
  final IconData icon;

  const RegionItem({super.key, required this.region, this.icon = Icons.map});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            child: Icon(icon, color: Colors.purple),
          ),
          const SizedBox(height: 8),
          Text(region, style: Styles.regionTextStyle),
        ],
      ),
    );
  }
}
