import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../model/hoadon.dart';

import 'package:http/http.dart' as http;

class QLHoaDon extends StatefulWidget {
  int idChu;
  QLHoaDon({Key? key, required this.idChu}) : super(key: key);

  @override
  _QLHoaDonState createState() => _QLHoaDonState();
}

class _QLHoaDonState extends State<QLHoaDon> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _showPaidInvoices = true;
  bool _showNewInvoices = false;
  List<Map<String, dynamic>> hoaDons = [];
  List<Map<String, dynamic>> newHoaDons = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    GetHoaDons();
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

  Future<void> GetHoaDons() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('${getUrl()}/api/QLHoaDon/GetHoaDons/${widget.idChu}'),
        headers: {"Content-Type": "application/json"},
      );
      await Future.delayed(Duration(seconds: 2));
      print('GetHoaDons code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('GetHoaDons data: ${response.body}');
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          hoaDons = data.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        print('Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> AddHoaDon() async {
    try {
      final response = await http.get(
        Uri.parse('${getUrl()}/api/QLHoaDon/AddHoaDon/${widget.idChu}'),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        setState(() {
          GetHoaDons();
          _isLoading = false;
        });
      } else {
        print('Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
    }
  }

  Widget _buildFilterButton(String text, bool isSelected, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          borderRadius: BorderRadius.circular(25),
          elevation: isSelected ? 4 : 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: onPressed,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: isSelected ? null : Colors.grey[200],
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> hoaDon, int index) {
    final isNewInvoice = hoaDon['trangThai'] == -1;
    final isPaid = hoaDon['trangThai'] == 1;
    final totalAmount = hoaDon['soTien'] + hoaDon['tienNuoc'] + hoaDon['tienDien'];
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (index * 0.1).clamp(0.0, 1.0),
              ((index * 0.1) + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 1.0),
                ((index * 0.1) + 0.3).clamp(0.0, 1.0),
              ),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: isNewInvoice
                      ? [Color(0xFFffecd2), Color(0xFFfcb69f)]
                      : isPaid
                          ? [Color(0xFFa8edea), Color(0xFFfed6e3)]
                          : [Color(0xFFffeaa7), Color(0xFFfab1a0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Xử lý khi nhấn vào hóa đơn
                  },
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phòng ${hoaDon['tenPhong']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    hoaDon['tenCoSo'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isNewInvoice
                                    ? Colors.orange
                                    : isPaid
                                        ? Colors.green
                                        : Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isNewInvoice
                                    ? 'Mới tạo'
                                    : isPaid
                                        ? 'Đã thanh toán'
                                        : 'Chưa thanh toán',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tổng tiền:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '${totalAmount.toStringAsFixed(0)} VNĐ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              if (hoaDon['ngayThanhToan'] != null) ...[
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Ngày thanh toán:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      hoaDon['ngayThanhToan'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Quản lý hóa đơn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
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
          : Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildFilterButton(
                          'Đã thanh toán',
                          _showPaidInvoices && !_showNewInvoices,
                          () {
                            setState(() {
                              _showPaidInvoices = true;
                              _showNewInvoices = false;
                            });
                            _animationController.reset();
                            _animationController.forward();
                          },
                        ),
                        _buildFilterButton(
                          'Chưa thanh toán',
                          !_showPaidInvoices && !_showNewInvoices,
                          () {
                            setState(() {
                              _showPaidInvoices = false;
                              _showNewInvoices = false;
                            });
                            _animationController.reset();
                            _animationController.forward();
                          },
                        ),
                        _buildFilterButton(
                          'Thêm hóa đơn',
                          _showNewInvoices,
                          () {
                            setState(() {
                              _showNewInvoices = true;
                            });
                            _animationController.reset();
                            _animationController.forward();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _showNewInvoices
                        ? hoaDons.where((hoaDon) => hoaDon['trangThai'] == -1).length
                        : hoaDons
                            .where((hoaDon) =>
                                hoaDon['trangThai'] == (_showPaidInvoices ? 1 : 0))
                            .length,
                    itemBuilder: (context, index) {
                      final filteredHoaDons = _showNewInvoices
                          ? hoaDons
                              .where((hoaDon) => hoaDon['trangThai'] == -1)
                              .toList()
                          : hoaDons
                              .where((hoaDon) =>
                                  hoaDon['trangThai'] == (_showPaidInvoices ? 1 : 0))
                              .toList();
                      final hoaDon = filteredHoaDons[index];
                      return _buildInvoiceCard(hoaDon, index);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: _showNewInvoices
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.add_circle_outline, color: Color(0xFF667eea)),
                            SizedBox(width: 8),
                            Text(
                              'Thêm hóa đơn mới',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'Bạn có chắc chắn muốn thêm hóa đơn mới cho tháng ${DateTime.now().month}?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Hủy',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF667eea),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                              });
                              AddHoaDon();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Xác nhận',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                label: Text(
                  'Thêm hóa đơn',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
    );
  }
}