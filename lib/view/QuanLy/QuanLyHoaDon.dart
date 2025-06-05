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

class _QLHoaDonState extends State<QLHoaDon> {
  bool _isLoading = true;
  bool _showPaidInvoices = true;
  bool _showNewInvoices = false;
  List<Map<String, dynamic>> hoaDons = [];
  List<Map<String, dynamic>> newHoaDons = [];

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
        // Xử lý dữ liệu ở đây
        print('GetHoaDons data: ${response.body}');
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          hoaDons = data.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        // Xử lý lỗi
        print('Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetHoaDons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý hóa đơn')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Dòng nút bấm
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Nút "Đã thanh toán"
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _showPaidInvoices && !_showNewInvoices
                                    ? Colors.purple
                                    : Colors.grey,
                            padding: EdgeInsets.only(
                              left: 8,
                              right: 8,
                            ), // Loại bỏ khoảng cách dư thừa bên trong nút
                            // Đảm bảo nút chỉ vừa đủ với nội dung
                          ),
                          onPressed: () {
                            setState(() {
                              _showPaidInvoices = true;
                              _showNewInvoices = false;
                            });
                          },
                          child: Text(
                            'Đã thanh toán',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        // Nút "Chưa thanh toán"
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                !_showPaidInvoices && !_showNewInvoices
                                    ? Colors.purple
                                    : Colors.grey,
                            padding: EdgeInsets.only(
                              left: 8,
                              right: 8,
                            ), // Loại bỏ khoảng cách dư thừa bên trong nút
                            // Đảm bảo nút chỉ vừa đủ với nội dung
                          ),
                          onPressed: () {
                            setState(() {
                              _showPaidInvoices = false;
                              _showNewInvoices = false;
                            });
                          },
                          child: Text(
                            'Chưa thanh toán',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        // Nút "Thêm hóa đơn"
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _showNewInvoices ? Colors.purple : Colors.grey,
                            padding: EdgeInsets.only(
                              left: 8,
                              right: 8,
                            ), // Loại bỏ khoảng cách dư thừa bên trong nút
                            // Đảm bảo nút chỉ vừa đủ với nội dung
                          ),
                          onPressed: () {
                            setState(() {
                              _showNewInvoices = true;
                            });
                          },
                          child: Text(
                            'Thêm hóa đơn',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Danh sách hóa đơn
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          _showNewInvoices
                              ? hoaDons
                                  .where((hoaDon) => hoaDon['trangThai'] == -1)
                                  .length
                              : hoaDons
                                  .where(
                                    (hoaDon) =>
                                        hoaDon['trangThai'] ==
                                        (_showPaidInvoices ? 1 : 0),
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
                                : hoaDons
                                    .where(
                                      (hoaDon) =>
                                          hoaDon['trangThai'] ==
                                          (_showPaidInvoices ? 1 : 0),
                                    )
                                    .toList();
                        final hoaDon = filteredHoaDons[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            title: Text(
                              'Phòng ${hoaDon['tenPhong']} - ${hoaDon['tenCoSo']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Số tiền: ${hoaDon['soTien'] + hoaDon['tienNuoc'] + hoaDon['tienDien']} - Ngày thanh toán: ${hoaDon['ngayThanhToan'] ?? 'Chưa có'}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: Text(
                              hoaDon['trangThai'] == 1
                                  ? 'Đã thanh toán'
                                  : hoaDon['trangThai'] == 0
                                  ? 'Chưa thanh toán'
                                  : 'Mới tạo',
                              style: TextStyle(
                                color:
                                    hoaDon['trangThai'] == 1
                                        ? Colors.green
                                        : hoaDon['trangThai'] == 0
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                            onTap: () {
                              // Xử lý khi nhấn vào hóa đơn
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      floatingActionButton:
          _showNewInvoices
              ? FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Thêm hóa đơn mới'),
                        content: Text(
                          'Bạn có chắc chắn muốn thêm hóa đơn mới cho tháng ${DateTime.now().month}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                              });
                              AddHoaDon();
                              Navigator.of(context).pop();
                            },
                            child: Text('Xác nhận'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.purple,
              )
              : null,
    );
  }
}
