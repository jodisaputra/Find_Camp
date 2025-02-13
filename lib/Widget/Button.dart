import 'package:flutter/material.dart';
import 'package:find_camp/Style/theme.dart';

class ButtonFormStyle extends StatelessWidget {
  const ButtonFormStyle({
    super.key,
    required this.textName,
    this.onPressed,
  });

  final String textName;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: purplecolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          textName,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
