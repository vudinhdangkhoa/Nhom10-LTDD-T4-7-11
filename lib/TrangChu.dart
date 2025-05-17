import 'package:buoi03/view/DangNhapDangKyChu/dangnhap.dart';

import 'TroChuyen.dart';
import 'package:flutter/material.dart';
import 'view/QuanLy/QuanLyCoSo.dart';
import 'view/QuanLy/QuanLyKhach.dart';
import 'view/ThongKe/ThongKe.dart';
import 'dashboard.dart';
import 'view/QuanLy/QuanLyHoaDon.dart';

class DashboardScreen extends StatefulWidget {
  final int idChu;
  DashboardScreen({required this.idChu});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions = <Widget>[
    TrangDashboard(idChu: widget.idChu),
    TrangDashboard(idChu: widget.idChu),
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
                'Hi',
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
                  MaterialPageRoute(
                    builder: (context) => DSCoSoVaPhong(idChu: widget.idChu),
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
                    builder: (context) => QLKhachHang(idChu: widget.idChu),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => Thongke(idChuu: widget.idChu),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Đăng xuất'),
              onTap: () {
                // Xử lý đăng xuất ở đây
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false, // Xóa tất cả các route trước đó
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
