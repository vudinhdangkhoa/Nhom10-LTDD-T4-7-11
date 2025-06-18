import 'package:buoi03/view/DangNhapDangKyChu/dangnhap.dart';
import 'package:buoi03/view/KhachHang/DoiMatKhauKH.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'ChiTietHoaDonKH.dart';
import 'HoSoKH.dart';

class KhachHang extends StatelessWidget {
  int idKH;
  KhachHang({Key? key, required this.idKH}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hệ thống Phòng trọ',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: HomePage(idKH: idKH),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  int idKH;
  HomePage({Key? key, required this.idKH}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int currentElectricityUsage = 125;
  Timer? _electricityTimer;

  bool isLoading = true;
  Map<String, dynamic> userInfo = {};
  Map<String, dynamic> hoaDon = {};

  int tongtien = 0;
  bool isloadingHoaDon = true;
  bool isloadingUserInfo = true;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedPaymentImage;

  void setLoading() {
    setState(() {
      if (isloadingHoaDon || isloadingUserInfo) {
        isLoading = true;
      } else {
        isLoading = false;
        tongtien =
            (hoaDon['soTien'] +
                hoaDon['tienDien'] * userInfo['giaDien'] +
                hoaDon['tienNuoc']);
      }
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  Future<void> pickAndPreviewPaymentImage() async {
    await _requestPermission(Permission.storage);
    final XFile? pickAnh = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickAnh != null) {
      setState(() {
        _pickedPaymentImage = pickAnh;
      });
      // Hiện dialog xác nhận
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.payment, color: Colors.green, size: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Xác nhận thanh toán',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bạn có muốn gửi hình ảnh chuyển khoản này không?',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    // Hiển thị preview hình ảnh
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(_pickedPaymentImage!.path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text('Không thể hiển thị hình ảnh'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pickedPaymentImage = null;
                    });
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: Text(
                    'Hủy',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await uploadPaymentImage(_pickedPaymentImage!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Gửi thanh toán',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
      );
    }
  }

  Future<void> uploadPaymentImage(XFile pickAnh) async {
    // Hiển thị loading

    try {
      final bytes = await pickAnh.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.put(
        Uri.parse(
          '${getUrl()}/api/TrangChuKH/uploadPaymentImage/${hoaDon['idHoaDon']}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'avatar': base64Image,
          // Chờ xác nhận
        }),
      );

      // Đóng loading dialog

      print('Upload response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          _pickedPaymentImage = null;
          // Cập nhật trạng thái hóa đơn
          hoaDon['trangThai'] = 2;
          hoaDon['anhHoaDon'] = base64Image;
        });

        _showSuccessDialog();
      } else {
        _showErrorDialog('Gửi hình ảnh thất bại. Vui lòng thử lại.');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Đóng loading dialog
      print('Upload error: $e');
      _showErrorDialog('Đã xảy ra lỗi khi gửi hình ảnh.');
      setState(() {
        _pickedPaymentImage = null;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Thành công',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'Hình ảnh chuyển khoản đã được gửi thành công!\nHóa đơn đang chờ xác nhận từ quản lý.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Đóng',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.error, color: Colors.red, size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'Lỗi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Đóng',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.payment, color: Colors.blue, size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'Thanh toán hóa đơn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hóa đơn tháng ${DateTime.now().month}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tổng tiền: ${tongtien.toString()} VNĐ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vui lòng chuyển khoản và chọn hình ảnh xác nhận',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: Text(
                  'Hủy',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  pickAndPreviewPaymentImage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Chọn hình ảnh',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    getInfoKH();
    getHoaDon();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _electricityTimer?.cancel();
    super.dispose();
  }

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> getInfoKH() async {
    final respone = await http.get(
      Uri.parse('${getUrl()}/api/TrangChuKH/getinfoKH/${widget.idKH}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print('getInfoKH: ${respone.statusCode}');
    if (respone.statusCode == 200) {
      setState(() {
        userInfo = json.decode(respone.body);
        print('Thông tin khách hàng: $userInfo');
        isloadingUserInfo = false;
        setLoading();
      });
      // Process the data as needed
      print('Thông tin khách hàng: $userInfo');
    } else {
      print('Lỗi khi lấy thông tin khách hàng: ${respone.statusCode}');
    }
  }

  Future<void> getHoaDon() async {
    final respone = await http.get(
      Uri.parse('${getUrl()}/api/TrangChuKH/getHoaDon/${widget.idKH}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print('getHoaDon: ${respone.statusCode}');
    if (respone.statusCode == 200) {
      setState(() {
        hoaDon = json.decode(respone.body);
        print('Hóa đơn: $hoaDon');
        isloadingHoaDon = false;
        setLoading();
      });
    } else {
      print('Lỗi khi lấy hóa đơn: ${respone.statusCode}');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ Khách hàng'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      drawer: Drawer(
        child:
            isLoading
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
                          decoration: BoxDecoration(color: Colors.transparent),
                          accountName: Text(
                            'Xin chào, ${userInfo['tenKH'] ?? 'Khách hàng'}',
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
                              userInfo['email'] ?? '',
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
                                  userInfo['avatar'] == 'khonghinh'
                                      ? AssetImage('assets/images/avatar.jpg')
                                      : NetworkImage(
                                            '${getUrl()}/images/Avatar/${userInfo['avatar']}',
                                          )
                                          as ImageProvider<Object>,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildDrawerItem(
                        icon: Icons.home,
                        title: 'Trang chủ',
                        onTap: () {
                          Navigator.pop(context);
                        },
                        color: Color(0xFF6C63FF),
                      ),
                      _buildDrawerItem(
                        icon: Icons.account_circle,
                        title: 'Thông tin cá nhân',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => HoSoKH(idKH: userInfo['idKh']),
                            ),
                          );
                          print('result: $result');
                          if (result != null || result == null) {
                            // Nếu có thay đổi thông tin cá nhân, có thể cập nhật lại thông tin người dùng
                            setState(() {
                              isLoading = true;
                              getHoaDon();
                              getInfoKH();
                            });
                          }
                          // Thêm điều hướng sang trang thông tin cá nhân nếu có
                        },
                        color: Color(0xFF00BFA5),
                      ),
                      _buildDrawerItem(
                        icon: Icons.settings,
                        title: 'Đổi mật khẩu',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DoiMatKhauKH(
                                    matKhauCu: userInfo['matKhau'],
                                    idChu: userInfo['idKh'],
                                  ),
                            ),
                          );
                          if (result != null || result == null) {
                            // Nếu đổi mật khẩu thành công, có thể cập nhật lại thông tin người dùng
                            setState(() {
                              isLoading = true;

                              getInfoKH();
                              getHoaDon();
                            });
                          }
                          // Thêm điều hướng sang trang cài đặt nếu có
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
                          // Xử lý đăng xuất
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
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Đang tải thông tin...'),
                  ],
                ),
              )
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildWelcomeSection(),
                                SizedBox(height: 20),
                                _buildMainContent(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildAppBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ).createShader(bounds),
            child: Text(
              '🏠 Phòng Trọ Smart',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ).createShader(bounds),
            child: Text(
              'Chào mừng trở lại! 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${userInfo['tenKh']}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 30),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard('🏠', '${userInfo['tenPhong']}', 'Phòng hiện tại'),
        _buildStatCard(
          '📅',
          '${userInfo['giaNuoc'] * userInfo['soLuong']}',
          'Tiền Nước',
        ),
        _buildStatCard(
          '💰',
          '${userInfo['tienPhong'] / 1000000}M',
          'Tiền phòng/tháng',
        ),
        _buildStatCard(
          '⚡',
          '${userInfo['soDien']} kWh',
          'Tiêu thụ điện tháng ${DateTime.now().month - 1}',
        ),
      ],
    );
  }

  Widget _buildStatCard(String icon, String value, String label) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: TextStyle(fontSize: 30)),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 768) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildLeftContent()),
              SizedBox(width: 20),
            ],
          );
        } else {
          return Column(children: [_buildLeftContent(), SizedBox(height: 20)]);
        }
      },
    );
  }

  Widget _buildLeftContent() {
    return Column(
      children: [_buildRoomInfo(), SizedBox(height: 20), _buildBillsSection()],
    );
  }

  Widget _buildRoomInfo() {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🏠', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text(
                'Thông tin phòng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${userInfo['tenPhong']}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${userInfo['diaChi']}',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
                SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 4,
                  children: [
                    _buildRoomDetailItem('📐', 'Diện tích: 25m2'),
                    _buildRoomDetailItem('🚿', 'Có toilet riêng'),
                    _buildRoomDetailItem('❄️', 'Máy lạnh'),
                    _buildRoomDetailItem('📶', 'WiFi miễn phí'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetailItem(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 16)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildBillsSection() {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('💰', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text(
                'Hóa đơn gần đây',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          ListTile(
            title: Text(
              'Hóa đơn tháng ${DateTime.now().month}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Tổng tiền: ${tongtien.toString()}VNĐ'),
            onTap: () {
              // Xử lý khi người dùng nhấn vào hóa đơn
              if (hoaDon['trangThai'] == 0) {
                // Chưa thanh toán - hiển thị dialog thanh toán
                _showPaymentDialog();
              }
            },
            trailing: Text(
              hoaDon['trangThai'] == 1
                  ? 'Đã thanh toán'
                  : hoaDon['trangThai'] == 0
                  ? 'Chưa thanh toán'
                  : 'Chờ xác nhận',
              style: TextStyle(
                color:
                    hoaDon['trangThai'] == 1
                        ? Colors.green
                        : hoaDon['trangThai'] == 0
                        ? Colors.red
                        : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
