import 'dart:convert';
import 'dart:io';

import 'package:buoi03/view/DangNhapDangKyChu/dangnhap.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  Map<String, dynamic> TTchu = {};
  int _selectedIndex = 0;
  bool _isLoading = true;
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
  void initState() {
    super.initState();
    getThongTinChu();
  }

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> getThongTinChu() async {
    try {
      final response = await http.get(
        Uri.parse('${getUrl()}/api/TrangChu/GetThongTinChu/${widget.idChu}'),
        headers: {"Content-Type": "application/json"},
      );
      await Future.delayed(Duration(seconds: 2));
      print('TTChu code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('a');
        print(response.body);
        Map<String, dynamic> data = jsonDecode(response.body);
        print('TTChu data: $data');

        // Xử lý dữ liệu ở đây
        setState(() {
          TTchu = data;
          _isLoading = false;
          print(_isLoading);
        });
      } else {
        // Xử lý lỗi
        print('Lỗi: ${response.statusCode}');
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý khách thuê trọ')),
      drawer: Drawer(
        child:
            _isLoading == true
                ? Center(child: CircularProgressIndicator())
                : ListView(
                  children: [
                    UserAccountsDrawerHeader(
                      decoration: BoxDecoration(color: Colors.blue),
                      accountName: Text(
                        'Hi' + ' ' + TTchu['ten'],
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      accountEmail: Text(
                        TTchu['taiKhoan'],
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage:
                            TTchu['avatar'] == 'khonghinh'
                                ? Image.asset('assets/images/avatar.jpg').image
                                : NetworkImage(
                                  '${getUrl()}/images/Avatar/${TTchu[2]['avatar']}',
                                ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Hồ Sơ'),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => TrangDashboard()),
                        // );
                        Navigator.pop(context);
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
