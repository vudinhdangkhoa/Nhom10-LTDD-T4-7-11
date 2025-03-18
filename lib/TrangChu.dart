import 'package:flutter/material.dart';
import 'QuanLyPhongVaCoSo.dart';
import 'QuanLyKhach.dart';
import 'dashboard.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý khách thuê trọ')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.apartment),
              title: Text('Quản lý cơ sở & phòng'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Quản lý khách thuê'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TenantManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Quản lý hóa đơn'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Trò chuyện với khách thuê'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: DashboardPage(),
    );
  }
}
