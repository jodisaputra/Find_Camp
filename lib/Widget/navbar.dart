import 'package:find_camp/Style/theme.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: purplecolor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: purplecolor, // Color when selected
        unselectedItemColor: Colors.grey, // Color when unselected
        showSelectedLabels: true, // Always show labels for selected items
        showUnselectedLabels: true, // Always show labels for unselected items
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home, currentIndex == 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.calendar_today, currentIndex == 1),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.chat, currentIndex == 2),
            label: 'Consult',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.person, currentIndex == 3),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: isSelected
          ? BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      )
          : null,
      child: Icon(icon, size: 28),
    );
  }
}