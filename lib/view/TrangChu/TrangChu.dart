import 'dart:convert';
import 'dart:io';

import 'package:buoi03/view/DangNhapDangKyChu/dangnhap.dart';
import 'package:buoi03/view/TrangChu/DoiMK.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'TroChuyen.dart';
import 'package:flutter/material.dart';
import '../QuanLy/QuanLyCoSo.dart';
import '../QuanLy/QuanLyKhach.dart';
import '../ThongKe/ThongKe.dart';
import 'dashboard.dart';
import '../QuanLy/QuanLyHoaDon.dart';
import 'HoSo.dart';

class DashboardScreen extends StatefulWidget {
  final int idChu;
  final bool showHoSo;
  DashboardScreen({required this.idChu, this.showHoSo = false});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic> TTchu = {};
  int _selectedIndex = 0;
  bool _isLoading = true;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  late List<Widget> _widgetOptions = <Widget>[
    TrangDashboard(idChu: widget.idChu),
    TrangDashboard(idChu: widget.idChu),
    TrangChat(),
  ];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
    getThongTinChu();
    if (widget.showHoSo == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HoSo(idChu: widget.idChu)),
        );
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        print(response.body);
        Map<String, dynamic> data = jsonDecode(response.body);
        print('TTChu data: $data');

        setState(() {
          TTchu = data;
          _isLoading = false;
          print(_isLoading);
        });
        _slideController.forward();
      } else {
        print('Lỗi: ${response.statusCode}');
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý khách thuê trọ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2D3436),
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Color(0xFFE8E8E8), height: 1.0),
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu, color: Color(0xFF6C63FF), size: 20),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: Drawer(
        child:
            _isLoading == true
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF6C63FF),
                        ),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải thông tin...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
                : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF8F9FA), Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: UserAccountsDrawerHeader(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            accountName: Text(
                              'Xin chào, ${TTchu['ten'] ?? 'User'}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            accountEmail: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                TTchu['taiKhoan'] ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            currentAccountPicture: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    TTchu['avatar'] == 'khonghinh'
                                        ? Image.asset(
                                          'assets/images/avatar.jpg',
                                        ).image
                                        : NetworkImage(
                                          '${getUrl()}/images/Avatar/${TTchu['avatar']}',
                                        ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildDrawerItem(
                          icon: Icons.person_outline,
                          title: 'Hồ Sơ',
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HoSo(idChu: widget.idChu),
                              ),
                            );
                            print('result: $result');
                            if (result != null || result == null) {
                              setState(() {
                                _isLoading = true;
                                getThongTinChu();
                              });
                            }
                          },
                          color: Color(0xFF6C63FF),
                        ),
                        _buildDrawerItem(
                          icon: Icons.settings_outlined,
                          title: 'Đổi mật khẩu',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DoiMatKhau(
                                      matKhauCu: TTchu['matKhau'],
                                      idChu: widget.idChu,
                                    ),
                              ),
                            );
                          },
                          color: Color(0xFF00BFA5),
                        ),
                        _buildDrawerItem(
                          icon: Icons.help_outline,
                          title: 'Trợ giúp',
                          onTap: () {
                            Navigator.pop(context);
                          },
                          color: Color(0xFFFF7043),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Divider(color: Colors.grey[300]),
                        ),
                        _buildDrawerItem(
                          icon: Icons.exit_to_app,
                          title: 'Đăng xuất',
                          onTap: () {
                            _showLogoutDialog();
                          },
                          color: Color(0xFFE53E3E),
                        ),
                        SizedBox(height: 32),
                        Center(
                          child: Text(
                            'Phiên bản 1.0.0',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Color(0xFFF8F9FA)),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.dashboard_outlined, 0),
                activeIcon: _buildNavIcon(Icons.dashboard, 0),
                label: 'Dashboard',
              ),

              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.chat_bubble_outline, 2),
                activeIcon: _buildNavIcon(Icons.chat_bubble, 2),
                label: 'Trò chuyện',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFF6C63FF),
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Color(0xFF6C63FF).withOpacity(0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isSelected ? Color(0xFF6C63FF) : Colors.grey[500],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF2D3436),
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: color.withOpacity(0.05),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFE53E3E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout, color: Color(0xFFE53E3E), size: 24),
              ),
              SizedBox(width: 12),
              Text(
                'Xác nhận đăng xuất',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Đăng xuất',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
