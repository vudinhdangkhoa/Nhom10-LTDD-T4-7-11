import 'dart:convert';

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

  Future<void> GetCoSo() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:5167/api/QLCoSoVaPhong/GetCoSo/${widget.idChu}',
        ),
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
            "http://localhost:5167/api/QLCoSoVaPhong/ThemCoSo/${widget.idChu}",
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
              content: Text("Cơ sở đã tồn tại"),
              backgroundColor: Colors.red,
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
              content: Text("Thêm cơ sở thành công"),
              backgroundColor: Colors.green,
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
      builder:
          (context) => AlertDialog(
            title: Text('Thêm cơ sở'),
            content: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: tenCoSoController,
                        decoration: InputDecoration(labelText: 'Tên cơ sở'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên cơ sở';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: diaChiController,
                        decoration: InputDecoration(labelText: 'Địa chỉ'),
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
                  // Handle add action
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
        Uri.parse("http://localhost:5167/api/QLCoSoVaPhong/XoaCoSo/${id}"),
        headers: {"Content-Type": "application/json"},
      );
      body:
      jsonEncode({"id": id});
      await Future.delayed(Duration(seconds: 2));

      print(response.statusCode);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xóa cơ sở thành công"),
            backgroundColor: Colors.green,
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
            content: Text("Cơ sở không tồn tại"),
            backgroundColor: Colors.red,
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
          title: Text('Chi tiết cơ sở'),
          content: Form(
            key: formKeyCapNhat,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: tenCoSoController,
                      decoration: InputDecoration(labelText: 'Tên cơ sở'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên cơ sở';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: diaChiController,
                      decoration: InputDecoration(labelText: 'Địa chỉ'),
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
                // Handle add action
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
        Uri.parse("http://localhost:5167/api/QLCoSoVaPhong/CapNhatCoSo/${id}"),
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
            content: Text("Cập nhật cơ sở thành công"),
            backgroundColor: Colors.green,
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
              content: Text(
                jsonDecode(response.body)["message"],
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
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
      appBar: AppBar(title: Text('Quản lý cơ sở & phòng')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : erroMessage.isNotEmpty
              ? Center(child: Text(erroMessage))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: coso.length,
                  itemBuilder: (context, index) {
                    final CoSo = coso[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(
                          CoSo.tenCoSo,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Số lượng phòng: ${CoSo.soLuong}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DSPhong(coSo: CoSo),
                                  ),
                                );
                              },
                            ),
                            CoSo.soLuong == 0
                                ? IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Xóa cơ sở'),
                                          content: Text(
                                            'Bạn có chắc chắn muốn xóa cơ sở này?',
                                          ),
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
                                                deleteCoSo(CoSo.idCoSo);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                                : IconButton(
                                  icon: Icon(Icons.delete, color: Colors.grey),
                                  onPressed: null,
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showdialog();
        },
      ),
    );
  }
}
