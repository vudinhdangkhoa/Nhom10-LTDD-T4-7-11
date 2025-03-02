import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý khách thuê trọ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DashboardScreen(),
    );
  }
}

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
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.apartment),
              title: Text('Quản lý cơ sở & phòng'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Quản lý khách thuê'),
              onTap: () {},
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
      body: Center(
        child: Text(
          'Chào mừng đến với hệ thống quản lý khách thuê trọ!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
