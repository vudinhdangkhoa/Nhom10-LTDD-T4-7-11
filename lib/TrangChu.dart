import 'TroChuyen.dart';
import 'package:flutter/material.dart';
import 'QuanLyPhongVaCoSo.dart';
import 'QuanLyKhach.dart';
import 'ThongKe.dart';
import 'dashboard.dart';
import 'QuanLyHoaDon.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    TrangDashboard(),
    TrangDashboard(),
    TrangChat(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý khách thuê trọ')),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text(
                'Hi Khoa',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              accountEmail: Text(
                '2001222099@hufi.edu.vn',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: Image.asset('assets/images/avatar.jpg').image,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Dashboard'),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => TrangDashboard()),
                // );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.apartment),
              title: Text('Quản lý cơ sở & phòng'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DSCoSoVaPhong()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Quản lý khách thuê'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QLKhachHang()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Quản lý hóa đơn'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QLHoaDon()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('thống kê'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Thongke()),
                );
              },
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Cơ sở & Phòng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'trò chuyện',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: TextStyle(color: Colors.grey),
      ),
    );
  }
}
