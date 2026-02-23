import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Discipline App",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),

          _buildItem(context, icon: Icons.home, title: "Home", route: '/home'),

          _buildItem(
            context,
            icon: Icons.add,
            title: "Create",
            route: '/create',
          ),

          _buildItem(
            context,
            icon: Icons.list,
            title: "View All",
            route: '/viewall',
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final bool isActive = currentRoute == route;

    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blue : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.blue : Colors.black,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);

        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
