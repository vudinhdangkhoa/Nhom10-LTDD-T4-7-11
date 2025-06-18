import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChiTietHoaDon extends StatefulWidget {
  Map<String, dynamic> hoadon;
  ChiTietHoaDon({Key? key, required this.hoadon}) : super(key: key);

  @override
  _ChiTietHoaDonState createState() => _ChiTietHoaDonState();
}

class _ChiTietHoaDonState extends State<ChiTietHoaDon> {
  bool isConfirming = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> XacNhanHoaDon() async {
    if (isConfirming) return;
    setState(() {
      isConfirming = true; // Bắt đầu loading
    });
    final respone = await http.put(
      Uri.parse(
        '${getUrl()}/api/QLHoaDon/XacNhanHoaDon/${widget.hoadon['idHoaDon']}',
      ),
      headers: {'Content-Type': 'application/json'},
    );
    print(respone.statusCode);
    if (respone.statusCode == 200) {
      // Xử lý thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonDecode(respone.body)['message'])),
      );
      setState(() {
        widget.hoadon['trangThai'] = 1; // Cập nhật trạng thái hóa đơn
      });
    } else {
      // Xử lý lỗi
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi xác nhận hóa đơn')));
    }
  }

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  @override
  Widget build(BuildContext context) {
    final int totalAmount =
        (widget.hoadon['soTien'] +
            widget.hoadon['tienNuoc'] +
            widget.hoadon['tienDien'] * widget.hoadon['giaDien']);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Chi Tiết Hóa Đơn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'HÓA ĐƠN #${widget.hoadon['idHoaDon']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Ngày Thanh Toán: ${widget.hoadon['ngayThanhToan']}',
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
                _buildInfoRow(Icons.home, 'Phòng', widget.hoadon['tenPhong']),
                _buildInfoRow(
                  Icons.business,
                  'Cơ sở',
                  widget.hoadon['tenCoSo'],
                ),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Trạng thái',
                  widget.hoadon['trangThai'] == 1
                      ? 'Đã thanh toán'
                      : 'Chờ xác nhận',
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
                  widget.hoadon['soTien'],
                  Colors.blue,
                ),
                _buildCostRow(
                  'Tiền nước',
                  widget.hoadon['tienNuoc'],
                  Colors.cyan,
                ),
                _buildCostRow(
                  'Tiền điện',
                  widget.hoadon['tienDien'] * widget.hoadon['giaDien'],
                  Colors.amber,
                ),
                Divider(thickness: 2, color: Colors.grey[300]),
                _buildCostRow(
                  'TỔNG CỘNG',
                  totalAmount,
                  Colors.red,
                  isTotal: true,
                ),
              ],
            ),

            SizedBox(height: 20),

            // Hình ảnh hóa đơn
            if (widget.hoadon['anhHoaDon'] != null)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.image, color: Color(0xFF667eea)),
                          SizedBox(width: 8),
                          Text(
                            'Hình Ảnh Chuyển Khoản',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          '${getUrl()}/images/HoaDon/${widget.hoadon['anhHoaDon']}',
                          height: 640,
                          width: 360,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 400,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text('Không thể tải hình ảnh'),
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
            // Thay thế phần ElevatedButton cũ bằng đoạn code này
            if (widget.hoadon['trangThai'] == 2) ...[
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF667eea).withOpacity(0.4),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap:
                        isConfirming
                            ? null
                            : () {
                              XacNhanHoaDon();
                            },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                isConfirming
                                    ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            isConfirming
                                ? 'Đang xử lý...'
                                : 'Xác Nhận Thanh Toán',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Color(0xFF667eea)),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Color(0xFF667eea)),
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
                    color: Colors.grey[800],
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
    dynamic amount,
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
}
