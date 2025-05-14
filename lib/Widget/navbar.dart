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
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: 16,
        borderRadius: BorderRadius.circular(32),
        shadowColor: Colors.black.withOpacity(0.15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: currentIndex,
            onTap: onTap,
            selectedItemColor: purplecolor,
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
            showSelectedLabels: true,
            showUnselectedLabels: true,
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
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isSelected ? 44 : 36,
      height: isSelected ? 44 : 36,
      decoration: isSelected
          ? BoxDecoration(
              color: purplecolor.withOpacity(0.12),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: purplecolor.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Icon(
        icon,
        size: isSelected ? 28 : 24,
        color: isSelected ? purplecolor : Colors.grey[400],
      ),
    );
  }
}