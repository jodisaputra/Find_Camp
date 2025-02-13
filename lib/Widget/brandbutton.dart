import 'package:flutter/material.dart';

class BrandButton extends StatelessWidget {
  final String label;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Widget brandIcon;
  final VoidCallback? onPressed;

  const BrandButton({
    required this.brandIcon,
    required this.label,
    required this.onPressed,
    this.height = 48, // Default height of the button
    this.backgroundColor = Colors.white, // Set default background to white
    this.textColor = Colors.black, // Set default text color to black
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, // Button height
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
          side: WidgetStateProperty.all<BorderSide>(
            BorderSide(color: Colors.black, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Adjust the size of the icon to fit the button height
            brandIcon is Image
                ? SizedBox(
              height: height * 0.5,
              child: brandIcon,
            )
                : brandIcon,
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 17,
                height: 1.41,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
