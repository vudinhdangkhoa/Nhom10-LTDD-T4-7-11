import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../model/coso.dart';
import '../../model/phong.dart';
import 'QuanLyPhong.dart';

class DSCoSoVaPhong extends StatefulWidget {
  final int idChu;
  const DSCoSoVaPhong({Key? key, required this.idChu}) : super(key: key);

  @override
  _QuanLyPhongVaCoSoState createState() => _QuanLyPhongVaCoSoState();
}

class _QuanLyPhongVaCoSoState extends State<DSCoSoVaPhong> {
  final List<CoSo> coso = [];
  String erroMessage = "";
  bool isLoading = true;
  late TextEditingController tenCoSoController = new TextEditingController();
  late TextEditingController diaChiController = new TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyCapNhat = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    GetCoSo();
  }

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> GetCoSo() async {
    try {
      final response = await http.get(
        Uri.parse("${getUrl()}/api/QLCoSoVaPhong/GetCoSo/${widget.idChu}"),
      );
      await Future.delayed(Duration(seconds: 2));
      print(response.statusCode);
      // Check if the response is successful
      if (response.statusCode == 200) {
        // Handle successful response

        final List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> _results =
            data.map((item) => item as Map<String, dynamic>).toList();
        setState(() {
          coso.clear();
          for (Map<String, dynamic> item in _results) {
            coso.add(CoSo.fromJson(item));
          }
          isLoading = false;
          erroMessage = "";
        });
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addCoSo() async {
    try {
      if (formKey.currentState!.validate()) {
        final response = await http.post(
          Uri.parse(
            "${getUrl()}/api/QLCoSoVaPhong/ThemCoSo/${widget.idChu}", //"http://localhost:5167/api/QLCoSoVaPhong/ThemCoSo/${widget.idChu}",
          ),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "TenCoSo": tenCoSoController.text,
            "DiaChi": diaChiController.text,
          }),
        );

        await Future.delayed(Duration(seconds: 2));
        if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Cơ sở đã tồn tại"),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );

          setState(() {
            erroMessage = "Cơ sở đã tồn tại";
            isLoading = true;
            GetCoSo();
          });
        } else if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Thêm cơ sở thành công"),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          setState(() {
            erroMessage = "";
            isLoading = true;
            GetCoSo();
          });
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e);
    }
  }

  void _showdialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_business, color: Colors.blue),
            ),
            SizedBox(width: 12),
            Text('Thêm cơ sở mới'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tenCoSoController,
                  decoration: InputDecoration(
                    labelText: 'Tên cơ sở',
                    prefixIcon: Icon(Icons.business, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên cơ sở';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: diaChiController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ',
                    prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
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
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Thêm'),
            onPressed: () {
              addCoSo();
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteCoSo(int id) async {
    try {
      final response = await http.delete(
        //Uri.parse("http://localhost:5167/api/QLCoSoVaPhong/XoaCoSo/${id}"),
        Uri.parse("${getUrl()}/api/QLCoSoVaPhong/XoaCoSo/${id}"),
        headers: {"Content-Type": "application/json"},
      );
      body:
      jsonEncode({"id": id});
      await Future.delayed(Duration(seconds: 2));

      print(response.statusCode);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Xóa cơ sở thành công"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        setState(() {
          erroMessage = "";
          isLoading = false;
          GetCoSo();
        });
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text("Cơ sở không tồn tại"),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        setState(() {
          erroMessage = "Cơ sở không tồn tại";
          isLoading = false;
          GetCoSo();
        });
      } else {
        throw Exception('Failed to delete property');
      }
    } catch (e) {
      print(e);
    }
  }

  void detailCoSo(int id, String tenCoSoCu, String diaChiCoSoCu) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit_note, color: Colors.orange),
              ),
              SizedBox(width: 12),
              Text('Chi tiết cơ sở'),
            ],
          ),
          content: Form(
            key: formKeyCapNhat,
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: tenCoSoController,
                    decoration: InputDecoration(
                      labelText: 'Tên cơ sở',
                      prefixIcon: Icon(Icons.business, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên cơ sở';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: diaChiController,
                    decoration: InputDecoration(
                      labelText: 'Địa chỉ',
                      prefixIcon: Icon(Icons.location_on, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập địa chỉ';
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
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Cập nhật'),
              onPressed: () {
                tenCoSoCu != tenCoSoController.text ||
                        diaChiCoSoCu != diaChiController.text
                    ? capNhatCoSo(id)
                    : Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> capNhatCoSo(int id) async {
    try {
      final response = await http.put(
        //Uri.parse("http://localhost:5167/api/QLCoSoVaPhong/CapNhatCoSo/${id}"),
        Uri.parse("${getUrl()}/api/QLCoSoVaPhong/CapNhatCoSo/${id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "TenCoSo": tenCoSoController.text,
          "DiaChi": diaChiController.text,
        }),
      );

      await Future.delayed(Duration(seconds: 2));
      print(response.statusCode);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Cập nhật cơ sở thành công"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        setState(() {
          erroMessage = "";
          isLoading = true;
          GetCoSo();
        });
        Navigator.pop(context);
      } else if (response.statusCode == 400) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      jsonDecode(response.body)["message"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        });
        Navigator.pop(context);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Quản lý cơ sở & phòng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : erroMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        erroMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : coso.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có cơ sở nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Nhấn nút + để thêm cơ sở mới',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: coso.length,
                        itemBuilder: (context, index) {
                          final CoSo = coso[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.business,
                                  color: Colors.blue[600],
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                CoSo.tenCoSo,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey[500],
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          CoSo.diaChi,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Số phòng: ${CoSo.soLuong}',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.arrow_forward,
                                        color: Colors.blue[600],
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DSPhong(coSo: CoSo),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: CoSo.soLuong == 0
                                          ? Colors.red[50]
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CoSo.soLuong == 0
                                        ? IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red[600]),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                16)),
                                                    title: Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.red
                                                                .withOpacity(0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          child: Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text('Xóa cơ sở'),
                                                      ],
                                                    ),
                                                    content: Text(
                                                      'Bạn có chắc chắn muốn xóa cơ sở này?',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: Text('Hủy',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[600])),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          foregroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                        ),
                                                        child: Text('Xóa'),
                                                        onPressed: () {
                                                          deleteCoSo(
                                                              CoSo.idCoSo);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          )
                                        : IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.grey[400]),
                                            onPressed: null,
                                          ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                tenCoSoController.text = CoSo.tenCoSo;
                                diaChiController.text = CoSo.diaChi;

                                detailCoSo(
                                  CoSo.idCoSo,
                                  tenCoSoController.text,
                                  diaChiController.text,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add, size: 28),
          onPressed: () {
            tenCoSoController.clear();
            diaChiController.clear();
            _showdialog();
          },
        ),
      ),
    );
  }
}