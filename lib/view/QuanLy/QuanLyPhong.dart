import 'package:buoi03/model/phong.dart';
import 'package:buoi03/view/QuanLy/ChiTietPhong.dart';
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
  late List<Phong> phongList = [];
  String erroMessage = "";
  bool isLoading = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formkeyCapNhatPhong = GlobalKey<FormState>();
  TextEditingController tenPhongController = TextEditingController();
  void initState() {
    super.initState();
    // Gọi API để lấy danh sách phòng
    getPhong();
  }

  Future<void> addPhong() async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://localhost:5167/api/QLCoSoVaPhong/ThemPhong/${widget.coSo.idCoSo}",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tenPhong": tenPhongController.text}),
      );
      await Future.delayed(Duration(seconds: 2));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Thêm thành công",
              style: TextStyle(color: Colors.green),
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
                content: Text(
                  jsonDecode(response.body)['message'],
                  style: TextStyle(color: Colors.red),
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
          "http://localhost:5167/api/QLCoSoVaPhong/GetPhong/${widget.coSo.idCoSo}",
        ),
        headers: {"Content-Type": "application/json"},
      );

      await Future.delayed(Duration(seconds: 2));
      print(widget.coSo.idCoSo);
      print(response.statusCode);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> phonglst =
            data.map((item) => item as Map<String, dynamic>).toList();
        phongList.clear();
        for (Map<String, dynamic> item in phonglst) {
          phongList.add(Phong.fromJson(item));
        }

        setState(() {
          erroMessage = "";
          isLoading = false;
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
        Uri.parse("http://localhost:5167/api/QLCoSoVaPhong/XoaPhong/$idPhong"),
        headers: {"Content-Type": "application/json"},
      );
      Future.delayed(Duration(seconds: 2));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Xóa thành công",
              style: TextStyle(color: Colors.green),
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
                content: Text(
                  jsonDecode(response.body)['message'],
                  style: TextStyle(color: Colors.red),
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
          title: Text('Xóa phòng'),
          content: Text('Bạn có chắc chắn muốn xóa phòng này không?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xóa'),
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
          title: Text('Cập nhật thông tin phòng'),
          content: Form(
            key: formkeyCapNhatPhong,
            child: TextFormField(
              controller: tenPhongController,
              decoration: InputDecoration(labelText: 'Tên phòng'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên phòng';
                }
                return null;
              },
            ),
          ),

          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cập nhật'),
              onPressed: () {
                // Cập nhật thông tin phòng
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
        Uri.parse(
          "http://localhost:5167/api/QLCoSoVaPhong/CapNhatPhong/$idPhong",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tenPhong": tenPhongController.text}),
      );
      Future.delayed(Duration(seconds: 2));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Cập nhật thành công",
              style: TextStyle(color: Colors.green),
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
                content: Text(
                  jsonDecode(response.body)['message'],
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
            isLoading = false;
          });
        } else {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Lỗi không xác định",
                  style: TextStyle(color: Colors.red),
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
      appBar: AppBar(title: Text('Danh sách phòng - ${widget.coSo.tenCoSo}')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : erroMessage.isNotEmpty
              ? Center(child: Text(erroMessage))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: phongList.length,
                  itemBuilder: (context, index) {
                    final Phong phong = phongList[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(
                          phong.tenPhong ?? 'Phòng ${phong.idPhong}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          phong.soLuong > 0
                              ? 'Đã cho thuê - Số lượng người: ${phong.soLuong}'
                              : 'Còn trống',
                          style: TextStyle(
                            color:
                                phong.soLuong == 0 ? Colors.red : Colors.green,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Thêm chức năng chỉnh sửa phòng
                                tenPhongController.text = phong.tenPhong!;
                                _showdialogDetail(
                                  phong.idPhong,
                                  tenPhongController,
                                  tenPhongController.text,
                                );
                              },
                            ),
                            phong.soLuong > 0
                                ? IconButton(
                                  icon: Icon(Icons.delete, color: Colors.grey),
                                  onPressed: null,
                                )
                                : IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showdialogDelete(phong.idPhong);
                                  },
                                ),
                          ],
                        ),
                        onTap: () {
                          // Thêm chức năng xem chi tiết phòng
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ChiTietPhong(idPhong: phong.idPhong),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Thêm chức năng thêm phòng
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Thêm phòng'),
                content: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: tenPhongController,
                    decoration: InputDecoration(labelText: 'Tên phòng'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên phòng';
                      }
                      return null;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Hủy'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Thêm'),
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
      ),
    );
  }
}
