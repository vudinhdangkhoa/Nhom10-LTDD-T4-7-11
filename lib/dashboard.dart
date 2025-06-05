import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'view/ThongKe/ThongKe.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'view/QuanLy/QuanLyCoSo.dart';
import 'view/QuanLy/QuanLyKhach.dart';
import 'view/QuanLy/QuanLyHoaDon.dart';

class TrangDashboard extends StatefulWidget {
  final int idChu;
  const TrangDashboard({Key? key, required this.idChu}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<TrangDashboard>
    with TickerProviderStateMixin {
  int tongPhong = 0;
  int phongTrong = 0;
  int khachThue = 0;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    GetPhongvaKhach();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> GetPhongvaKhach() async {
    try {
      final response = await http.get(
        Uri.parse("${getUrl()}/api/TrangChu/GetPhongvaKhach/${widget.idChu}"),
        headers: {"Content-Type": "application/json"},
      );
      await Future.delayed(Duration(seconds: 2));
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          tongPhong = data['tongPhong'] ?? 0;
          phongTrong = data['phongTrong'] ?? 0;
          khachThue = data['tongKhach'] ?? 0;
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Widget _buildGridItem(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    Widget route,
  ) {
    return GestureDetector(
      onTap: () async {
        // Thêm hiệu ứng haptic feedback
        final result = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => route,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
        if (result == null) {
          setState(() {
            _isLoading = true;
            GetPhongvaKhach();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final result = await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => route,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
              if (result == null) {
                setState(() {
                  _isLoading = true;
                  GetPhongvaKhach();
                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Tổng quan hệ thống",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Statistics cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildDashboardCard(
                              "Tổng số phòng",
                              tongPhong.toString(),
                              Icons.apartment,
                              [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildDashboardCard(
                              "Phòng trống",
                              phongTrong.toString(),
                              Icons.meeting_room_outlined,
                              [Color(0xFF11998E), Color(0xFF38EF7D)],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildDashboardCard(
                              "Khách thuê",
                              khachThue.toString(),
                              Icons.people_outline,
                              [Color(0xFFFA709A), Color(0xFFFEE140)],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),

                      // Management section header
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Quản lý hệ thống",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Management grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                        children: [
                          _buildGridItem(
                            context,
                            "Quản lý phòng",
                            Icons.home_work_outlined,
                            [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                            DSCoSoVaPhong(idChu: widget.idChu),
                          ),
                          _buildGridItem(
                            context,
                            "Quản lý khách",
                            Icons.person_outline,
                            [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                            QLKhachHang(idChu: widget.idChu),
                          ),
                          _buildGridItem(
                            context,
                            "Quản lý hóa đơn",
                            Icons.receipt_long_outlined,
                            [Color(0xFFFF9A56), Color(0xFFFF6B9D)],
                            QLHoaDon(idChu: widget.idChu),
                          ),
                          _buildGridItem(
                            context,
                            "Thống kê",
                            Icons.analytics_outlined,
                            [Color(0xFF667EEA), Color(0xFF764BA2)],
                            Thongke(idChuu: widget.idChu),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),

                      // Revenue statistics section
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Thống kê doanh thu",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Placeholder for future chart
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF667EEA).withOpacity(0.3),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.show_chart,
                                size: 48,
                                color: Colors.white,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Biểu đồ doanh thu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Sẽ được cập nhật sớm',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}