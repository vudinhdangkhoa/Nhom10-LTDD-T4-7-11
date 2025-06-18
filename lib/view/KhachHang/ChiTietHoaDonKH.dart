import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChiTietHoaDonKH extends StatefulWidget {
  Map<String, dynamic> hoadon;
  int giaDien;
  ChiTietHoaDonKH({Key? key, required this.hoadon, required this.giaDien})
    : super(key: key);

  @override
  _ChiTietHoaDonKHState createState() => _ChiTietHoaDonKHState();
}

class _ChiTietHoaDonKHState extends State<ChiTietHoaDonKH> {
  bool isloading = true;
  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  @override
  void initState() {
    super.initState();

    // DEBUG: In toàn bộ dữ liệu hóa đơn
    print('=== DEBUG THÔNG TIN HÓA ĐƠN ===');
    print('Toàn bộ hóa đơn: ${widget.hoadon}');
    print('Giá điện từ widget: ${widget.giaDien}');

    // DEBUG: Kiểm tra từng field riêng lẻ
    print('\n=== KIỂM TRA TỪNG FIELD ===');
    print(
      'idHoaDon: ${widget.hoadon['idHoaDon']} (type: ${widget.hoadon['idHoaDon'].runtimeType})',
    );
    print(
      'soTien: ${widget.hoadon['soTien']} (type: ${widget.hoadon['soTien']?.runtimeType})',
    );
    print(
      'tienNuoc: ${widget.hoadon['tienNuoc']} (type: ${widget.hoadon['tienNuoc']?.runtimeType})',
    );
    print(
      'tienDien: ${widget.hoadon['tienDien']} (type: ${widget.hoadon['tienDien']?.runtimeType})',
    );
    print(
      'giaDien (from hoadon): ${widget.hoadon['giaDien']} (type: ${widget.hoadon['giaDien']?.runtimeType})',
    );
    print(
      'ngayThanhToan: ${widget.hoadon['ngayThanhToan']} (type: ${widget.hoadon['ngayThanhToan']?.runtimeType})',
    );
    print(
      'trangThai: ${widget.hoadon['trangThai']} (type: ${widget.hoadon['trangThai']?.runtimeType})',
    );
    print(
      'tenPhong: ${widget.hoadon['tenPhong']} (type: ${widget.hoadon['tenPhong']?.runtimeType})',
    );
    print(
      'anhHoaDon: ${widget.hoadon['anhHoaDon']} (type: ${widget.hoadon['anhHoaDon']?.runtimeType})',
    );

    // DEBUG: Kiểm tra null values
    print('\n=== KIỂM TRA NULL VALUES ===');
    List<String> nullFields = [];
    widget.hoadon.forEach((key, value) {
      if (value == null) {
        nullFields.add(key);
      }
    });
    print('Các field có giá trị null: $nullFields');

    // DEBUG: Kiểm tra các field quan trọng cho tính toán
    print('\n=== KIỂM TRA TÍNH TOÁN ===');
    var soTien = widget.hoadon['soTien'];
    var tienNuoc = widget.hoadon['tienNuoc'];
    var tienDien = widget.hoadon['tienDien'];
    var giaDien = widget.giaDien;

    print('soTien là null? ${soTien == null}');
    print('tienNuoc là null? ${tienNuoc == null}');
    print('tienDien là null? ${tienDien == null}');
    print('giaDien là null? ${giaDien == null}');

    // Thử tính toán và bắt lỗi
    try {
      double soTienSafe = (soTien ?? 0).toDouble();
      double tienNuocSafe = (tienNuoc ?? 0).toDouble();
      double tienDienSafe = (tienDien ?? 0).toDouble();
      double giaDienSafe = (giaDien ?? 0).toDouble();

      print('soTien sau convert: $soTienSafe');
      print('tienNuoc sau convert: $tienNuocSafe');
      print('tienDien sau convert: $tienDienSafe');
      print('giaDien sau convert: $giaDienSafe');

      double tienDienTotal = tienDienSafe * giaDienSafe;
      double totalAmount = soTienSafe + tienNuocSafe + tienDienTotal;

      print('Tiền điện total: $tienDienTotal');
      print('Tổng tiền: $totalAmount');
    } catch (e) {
      print('LỖI KHI TÍNH TOÁN: $e');
    }

    print('=== KẾT THÚC DEBUG ===\n');

    // Set loading false sau khi debug
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount =
        (widget.hoadon['soTien'] +
                widget.hoadon['tienNuoc'] +
                widget.hoadon['tienDien'] * widget.giaDien)
            .toDouble();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Chi Tiết Hóa Đơn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body:
          isloading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card với gradient
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Hóa Đơn #${widget.hoadon['idHoaDon']}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child:
                                widget.hoadon['ngayThanhToan'] == null
                                    ? Text(
                                      'Chưa thanh toán',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                    : Text(
                                      'Ngày thanh toán: ${widget.hoadon['ngayThanhToan']}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Thông tin cơ bản
                    _buildInfoCard(
                      title: 'Thông Tin Cơ Bản',
                      icon: Icons.info_outline,
                      children: [
                        _buildInfoRow(
                          Icons.home,
                          'Phòng',
                          widget.hoadon['tenPhong'] ?? 'N/A',
                        ),

                        _buildInfoRow(
                          Icons.access_time,
                          'Trạng thái',
                          _getStatusText(widget.hoadon['trangThai']),
                          statusColor: _getStatusColor(
                            widget.hoadon['trangThai'],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Chi tiết chi phí
                    _buildInfoCard(
                      title: 'Chi Tiết Chi Phí',
                      icon: Icons.receipt,
                      children: [
                        _buildCostRow(
                          'Tiền phòng',
                          widget.hoadon['soTien']?.toDouble() ?? 0,
                          Colors.blue,
                        ),
                        _buildCostRow(
                          'Tiền nước',
                          widget.hoadon['tienNuoc']?.toDouble() ?? 0,
                          Colors.cyan,
                        ),
                        _buildCostRow(
                          'Tiền điện',
                          (widget.hoadon['tienDien'] * widget.hoadon['giaDien'])
                                  ?.toDouble() ??
                              0,
                          Colors.amber,
                        ),
                        SizedBox(height: 10),
                        Container(height: 2, color: Colors.grey[300]),
                        SizedBox(height: 10),
                        _buildCostRow(
                          'TỔNG CỘNG',
                          totalAmount,
                          Colors.red,
                          isTotal: true,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Trạng thái thanh toán
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          widget.hoadon['trangThai'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _getStatusColor(widget.hoadon['trangThai']),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(widget.hoadon['trangThai']),
                            color: _getStatusColor(widget.hoadon['trangThai']),
                            size: 30,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trạng thái thanh toán',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  _getStatusText(widget.hoadon['trangThai']),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(
                                      widget.hoadon['trangThai'],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue[600]),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? statusColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[600]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue[600]),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor ?? Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(
    String label,
    double amount,
    Color color, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 12 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? color : Colors.grey[700],
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} VNĐ',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(int? trangThai) {
    switch (trangThai) {
      case 1:
        return 'Đã thanh toán';
      case 0:
        return 'Chưa thanh toán';
      case 2:
        return 'Chờ xác nhận';
      case -1:
        return 'Chờ cập nhật';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(int? trangThai) {
    switch (trangThai) {
      case 1:
        return Colors.green;
      case 0:
        return Colors.red;
      case 2:
        return Colors.orange;
      case -1:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int? trangThai) {
    switch (trangThai) {
      case 1:
        return Icons.check_circle;
      case 0:
        return Icons.warning;
      case 2:
        return Icons.hourglass_empty;
      case -1:
        return Icons.edit_note;
      default:
        return Icons.help_outline;
    }
  }
}
