import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../model/hoadon.dart';

import 'package:http/http.dart' as http;

import 'ChiTietHoaDon.dart';

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
  bool _showChoXacNhan = false;
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
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                jsonDecode(response.body)['message'] ?? 'Lỗi không xác định',
              ),
              backgroundColor: Colors.red,
            ),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
    }
  }

  Future<void> UpdateHoaDon(int maHoaDon, int soDienCu, int soDienMoi) async {
    final respone = await http.put(
      Uri.parse('${getUrl()}/api/QLHoaDon/UpdateHoaDon'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'maHoaDon': maHoaDon,
        'soDienCu': soDienCu,
        'soDienMoi': soDienMoi,
        'idChu': widget.idChu,
      }),
    );
    if (respone.statusCode == 200) {
      setState(() {
        GetHoaDons();
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonDecode(respone.body)['message'] ?? 'Cập nhật thành công',
            ),
            backgroundColor: Colors.green,
          ),
        );
      });
    } else {
      print('Lỗi: ${respone.statusCode}');
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonDecode(respone.body)['message'] ?? 'Lỗi không xác định',
            ),
            backgroundColor: Colors.red,
          ),
        );
        _isLoading = false;
      });
    }
  }

  Widget _buildFilterButton(
    String text,
    bool isSelected,
    VoidCallback onPressed,
  ) {
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
                gradient:
                    isSelected
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

  void showDialogAddHoaDon(int maHoaDon) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _soDienCu = TextEditingController();
    final TextEditingController _soDienMoi = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 20,
          backgroundColor: Colors.white,
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.electric_bolt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cập nhật điện năng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF667eea).withOpacity(0.1),
                            Color(0xFF764ba2).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Color(0xFF667eea).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF667eea),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nhập số điện cũ và mới để tính toán tiền điện',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Số điện cũ
                    Text(
                      'Số điện cũ (kWh)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _soDienCu,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Color(0xFF667eea),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                          hintText: 'Ví dụ: 100',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Container(
                            margin: EdgeInsets.all(12),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.flash_off,
                              color: Color(0xFF667eea),
                              size: 20,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số điện cũ';
                          }
                          final soDienCu = int.tryParse(value);
                          if (soDienCu == null || soDienCu < 0) {
                            return 'Số điện cũ phải là số dương';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    // Số điện mới
                    Text(
                      'Số điện mới (kWh)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _soDienMoi,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Color(0xFF667eea),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                          hintText: 'Ví dụ: 150',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Container(
                            margin: EdgeInsets.all(12),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.flash_on,
                              color: Color(0xFF667eea),
                              size: 20,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số điện mới';
                          }
                          final soDienMoi = int.tryParse(value);
                          if (soDienMoi == null || soDienMoi < 0) {
                            return 'Số điện mới phải là số dương';
                          }
                          final soDienCu = int.tryParse(_soDienCu.text);
                          if (soDienCu != null && soDienMoi <= soDienCu) {
                            return 'Số điện mới phải lớn hơn số điện cũ';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: EdgeInsets.all(20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF667eea).withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final soDienCu = int.tryParse(_soDienCu.text);
                          final soDienMoi = int.tryParse(_soDienMoi.text);

                          if (soDienCu != null && soDienMoi != null) {
                            UpdateHoaDon(maHoaDon, soDienCu, soDienMoi);
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Vui lòng nhập số điện hợp lệ'),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Xác nhận',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showDialogXacNhan(Map<String, dynamic> hoaDon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Xác nhận thanh toán',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Image.network(
                  '${getUrl()}/images/HoaDon/${hoaDon['anhHoaDon']}',
                  height: 160,
                  width: 90,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              child: Text('Xác nhận', style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Xử lý xác nhận thanh toán
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> hoaDon, int index) {
    final isNewInvoice = hoaDon['trangThai'] == -1;
    final isPaid = hoaDon['trangThai'] == 1;
    final isUnPaid = hoaDon['trangThai'] == 0;
    final int totalAmount =
        (hoaDon['soTien'] +
            hoaDon['tienNuoc'] +
            hoaDon['tienDien'] * hoaDon['giaDien']);
    dynamic result;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 1.0),
                ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
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
                  colors:
                      isNewInvoice
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
                    isNewInvoice
                        ? showDialogAddHoaDon(hoaDon['idHoaDon'])
                        : isPaid
                        ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChiTietHoaDon(hoadon: hoaDon),
                          ),
                        )
                        : isUnPaid
                        ? print('Chưa thanh toán')
                        : result = Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChiTietHoaDon(hoadon: hoaDon),
                          ),
                        );
                    if (result == null) {
                      setState(() {
                        _isLoading = true;
                        GetHoaDons();
                      });
                    }
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isNewInvoice
                                        ? Colors.orange
                                        : isPaid
                                        ? Colors.green
                                        : isUnPaid
                                        ? Colors.red
                                        : Colors.blueAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isNewInvoice
                                    ? 'Mới tạo'
                                    : isPaid
                                    ? 'Đã thanh toán'
                                    : isUnPaid
                                    ? 'Chưa thanh toán'
                                    : 'Chờ xác nhận',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF667eea),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải dữ liệu...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
                      itemCount:
                          _showNewInvoices
                              ? hoaDons
                                  .where((hoaDon) => hoaDon['trangThai'] == -1)
                                  .length
                              : _showPaidInvoices
                              ? hoaDons
                                  .where((hoaDon) => hoaDon['trangThai'] == 1)
                                  .length
                              : hoaDons
                                  .where(
                                    (hoaDon) =>
                                        [0, 2].contains(hoaDon['trangThai']),
                                  )
                                  .length,
                      itemBuilder: (context, index) {
                        final filteredHoaDons =
                            _showNewInvoices
                                ? hoaDons
                                    .where(
                                      (hoaDon) => hoaDon['trangThai'] == -1,
                                    )
                                    .toList()
                                : _showPaidInvoices
                                ? hoaDons
                                    .where((hoaDon) => hoaDon['trangThai'] == 1)
                                    .toList()
                                : hoaDons
                                    .where(
                                      (t) => [0, 2].contains(t['trangThai']),
                                    )
                                    .toList();
                        print(filteredHoaDons.length);
                        final hoaDon = filteredHoaDons[index];
                        print(hoaDon);
                        return _buildInvoiceCard(hoaDon, index);
                      },
                    ),
                  ),
                ],
              ),
      floatingActionButton:
          _showNewInvoices
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
                              Icon(
                                Icons.add_circle_outline,
                                color: Color(0xFF667eea),
                              ),
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
