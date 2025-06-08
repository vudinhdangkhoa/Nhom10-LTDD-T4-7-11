import 'package:buoi03/model/phong.dart';
import 'package:buoi03/view/QuanLy/ChiTietPhong.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/coso.dart';

class DSPhong extends StatefulWidget {
  final CoSo coSo;
  const DSPhong({Key? key, required this.coSo}) : super(key: key);

  @override
  _QuanLyPhongState createState() => _QuanLyPhongState();
}

class _QuanLyPhongState extends State<DSPhong> {
  late List<Map<String, dynamic>> phongList = [];
  String erroMessage = "";
  bool isLoading = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formkeyCapNhatPhong = GlobalKey<FormState>();
  TextEditingController tenPhongController = TextEditingController();
  TextEditingController tienPhongController = TextEditingController();

  void initState() {
    super.initState();
    getPhong();
  }

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> addPhong() async {
    try {
      final response = await http.post(
        Uri.parse(
          "${getUrl()}/api/QLCoSoVaPhong/ThemPhong/${widget.coSo.idCoSo}",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tenPhong": tenPhongController.text,
          "tienPhong": tienPhongController.text,
        }),
      );
      await Future.delayed(Duration(seconds: 2));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Thêm thành công"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        setState(() {
          tenPhongController.clear();
          isLoading = true;
          erroMessage = "";
          getPhong();
        });
      } else {
        if (response.statusCode == 400) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Flexible(child: Text(jsonDecode(response.body)['message'])),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            isLoading = false;
          });
        } else {
          setState(() {
            erroMessage = "Lỗi không xác định";
          });
        }
      }
      Navigator.pop(context);
    } catch (e) {}
  }

  Future<void> getPhong() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${getUrl()}/api/QLCoSoVaPhong/GetPhong/${widget.coSo.idCoSo}",
        ),
        headers: {"Content-Type": "application/json"},
      );

      await Future.delayed(Duration(seconds: 2));
      print(widget.coSo.idCoSo);
      print(response.statusCode);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        phongList.clear();
        setState(() {
          erroMessage = "";
          isLoading = false;
          phongList = data.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        if (response.statusCode == 400) {
          setState(() {
            erroMessage = "Không có phòng nào";
            isLoading = false;
          });
        } else {
          setState(() {
            erroMessage = "Lỗi không xác định";
          });
        }
      }
    } catch (e) {}
  }

  Future<void> deletePhong(int idPhong) async {
    try {
      final response = await http.delete(
        Uri.parse("${getUrl()}/api/QLCoSoVaPhong/XoaPhong/$idPhong"),
        headers: {"Content-Type": "application/json"},
      );
      Future.delayed(Duration(seconds: 2));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Xóa thành công"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        isLoading = true;
        erroMessage = "";
        getPhong();
      } else {
        if (response.statusCode == 400) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Flexible(child: Text(jsonDecode(response.body)['message'])),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            isLoading = false;
          });
        } else {
          setState(() {
            erroMessage = "Lỗi không xác định";
          });
        }
      }
      Navigator.of(context).pop();
    } catch (e) {}
  }

  void _showdialogDelete(int idPhong) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Xóa phòng', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa phòng này không?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Xóa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                deletePhong(idPhong);
              },
            ),
          ],
        );
      },
    );
  }

  void _showdialogDetail(
    int idPhong,
    TextEditingController tenPhongController,
    String tenPhongCu,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Text(
                'Cập nhật thông tin phòng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: Form(
            key: formkeyCapNhatPhong,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: tenPhongController,
                    decoration: InputDecoration(
                      labelText: 'Tên phòng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.room),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên phòng';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: tienPhongController,
                    decoration: InputDecoration(
                      labelText: 'Giá phòng',
                      hintText: 'Nhập giá phòng...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.attach_money),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.indigo, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập giá phòng';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Giá phòng phải là số dương';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Cập nhật'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                tenPhongCu != tenPhongController.text
                    ? updatePhong(idPhong)
                    : Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updatePhong(int idPhong) async {
    try {
      final response = await http.put(
        Uri.parse("${getUrl()}/api/QLCoSoVaPhong/CapNhatPhong/$idPhong"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tenPhong": tenPhongController.text}),
      );
      Future.delayed(Duration(seconds: 2));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Cập nhật thành công"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        tenPhongController.clear();
        isLoading = true;
        erroMessage = "";
        getPhong();
        Navigator.of(context).pop();
      } else {
        if (response.statusCode == 400) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Flexible(child: Text(jsonDecode(response.body)['message'])),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            isLoading = false;
          });
        } else {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Lỗi không xác định"),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          });
        }
        Navigator.of(context).pop();
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Danh sách phòng - ${widget.coSo.tenCoSo}',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo[600],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Đang tải danh sách phòng...",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
              : erroMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      erroMessage,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: getPhong,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: phongList.length,
                    itemBuilder: (context, index) {
                      final phong = phongList[index];
                      bool isOccupied = phong['soLuong'] > 0;

                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ChiTietPhong(idPhong: phong['idPhong']),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon phòng
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        isOccupied
                                            ? Colors.green[50]
                                            : Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.room,
                                    color:
                                        isOccupied
                                            ? Colors.green[600]
                                            : Colors.red[600],
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),

                                // Thông tin phòng
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        phong['tenPhong'] ??
                                            'Phòng ${phong['idPhong']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isOccupied
                                                      ? Colors.green[100]
                                                      : Colors.red[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isOccupied
                                                  ? 'Đã cho thuê'
                                                  : 'Còn trống',
                                              style: TextStyle(
                                                color:
                                                    isOccupied
                                                        ? Colors.green[700]
                                                        : Colors.red[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (isOccupied) ...[
                                            SizedBox(width: 8),
                                            Text(
                                              '${phong['soLuong']} người',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Action buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue[600],
                                        ),
                                        onPressed: () {
                                          tenPhongController.text =
                                              phong['tenPhong']!;
                                          tienPhongController.text =
                                              phong['tienPhong']?.toString() ??
                                              '';
                                          _showdialogDetail(
                                            phong['idPhong'],
                                            tenPhongController,
                                            tenPhongController.text,
                                          );
                                        },
                                        tooltip: 'Chỉnh sửa',
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            isOccupied
                                                ? Colors.grey[100]
                                                : Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color:
                                              isOccupied
                                                  ? Colors.grey[400]
                                                  : Colors.red[600],
                                        ),
                                        onPressed:
                                            isOccupied
                                                ? null
                                                : () {
                                                  _showdialogDelete(
                                                    phong['idPhong'],
                                                  );
                                                },
                                        tooltip:
                                            isOccupied
                                                ? 'Không thể xóa phòng đã có khách'
                                                : 'Xóa phòng',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            tenPhongController.clear();
            tienPhongController.clear();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.indigo, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Thêm phòng mới',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: tenPhongController,
                            decoration: InputDecoration(
                              labelText: 'Tên phòng',
                              hintText: 'Nhập tên phòng...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.room),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên phòng';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: tienPhongController,
                            decoration: InputDecoration(
                              labelText: 'Giá phòng',
                              hintText: 'Nhập giá phòng...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.attach_money),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập giá phòng';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'Giá phòng phải là số dương';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      child: Text('Thêm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          addPhong();
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
          backgroundColor: Colors.indigo[600],
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            'Thêm phòng',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
