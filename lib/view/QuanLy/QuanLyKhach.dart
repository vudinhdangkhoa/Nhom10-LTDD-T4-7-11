import 'package:buoi03/model/phong.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../model/coso.dart';
import '../../model/khachhang.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class _buildropdown extends StatefulWidget {
  int? idcoso;
  int? idphong;
  List<Phong> lstPhong;
  List<CoSo> lstCoSo;
  Function(int) updateIdPhong;

  _buildropdown({
    Key? key,
    required this.idcoso,
    required this.idphong,
    required this.lstPhong,
    required this.lstCoSo,
    required this.updateIdPhong,
  }) : super(key: key);

  @override
  __buildropdownState createState() => __buildropdownState();
}

class __buildropdownState extends State<_buildropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: widget.idcoso == 0 ? null : widget.idcoso,
          hint: Text("Chọn cơ sở"),
          items:
              widget.lstCoSo
                  .map(
                    (u) => DropdownMenuItem(
                      child: Text(u.tenCoSo),
                      value: u.idCoSo,
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              widget.idcoso = value!;
              widget.idphong = null;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Vui lòng chọn cơ sở';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: widget.idphong,
          hint: Text("Chọn phòng"),
          items:
              widget.lstPhong
                  .where((u) => u.idCoSo == widget.idcoso)
                  .map(
                    (u) => DropdownMenuItem(
                      child: Text(u.tenPhong ?? 'Không tên'),
                      value: u.idPhong,
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              widget.idphong = value!;
              widget.updateIdPhong(value);
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Vui lòng chọn phòng';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _buildFilterBar extends StatefulWidget {
  int? idcoso;
  int? idphong;
  List<Phong> lstPhong;
  List<CoSo> lstCoSo;
  Function(int?) updateIdPhong;
  List<KhachHang> lstKH;
  Function(List<KhachHang>) updateLstKHFilter;
  Function(int?) updateIdCoSo;
  _buildFilterBar({
    Key? key,
    required this.idcoso,
    required this.idphong,
    required this.lstCoSo,
    required this.lstPhong,
    required this.updateIdPhong,
    required this.lstKH,
    required this.updateLstKHFilter,
    required this.updateIdCoSo,
  }) : super(key: key);

  @override
  __buildFilterBarState createState() => __buildFilterBarState();
}

class __buildFilterBarState extends State<_buildFilterBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 3,
          children: [
            // Filter by Status

            // Filter by Facility
            DropdownButton<int?>(
              value: widget.idcoso,
              hint: Text("Chọn cơ sở"),
              items:
                  widget.lstCoSo
                      .map(
                        (coSo) => DropdownMenuItem(
                          value: coSo.idCoSo,
                          child: Text(coSo.tenCoSo),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  widget.idcoso = value;
                });
              },
            ),

            // Filter by Room
            DropdownButton<int?>(
              value: widget.idphong,
              hint: Text("Chọn phòng"),
              items:
                  widget.lstPhong
                      .where((phong) => phong.idCoSo == widget.idcoso)
                      .map(
                        (phong) => DropdownMenuItem(
                          value: phong.idPhong,
                          child: Text(phong.tenPhong ?? 'Không tên'),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  widget.idphong = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Lọc danh sách khách hàng
                  widget.lstKH =
                      widget.lstKH
                          .where(
                            (tenant) =>
                                (widget.idcoso == null ||
                                    tenant.idCoSo == widget.idcoso) &&
                                (widget.idphong == null ||
                                    tenant.idPhong == widget.idphong),
                          )
                          .toList();
                  widget.updateLstKHFilter(widget.lstKH);
                });
              },
              child: Text("Lọc"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Đặt lại các biến lọc

                  widget.idcoso = null;
                  widget.idphong = null;
                  widget.updateLstKHFilter([]);
                  widget.updateIdPhong(null);
                  widget.updateIdCoSo(null);
                });
              },
              child: Text("Xóa lọc"),
            ),
          ],
        ),
      ),
    );
  }
}

class QLKhachHang extends StatefulWidget {
  final int idChu;
  const QLKhachHang({Key? key, required this.idChu}) : super(key: key);
  @override
  _QLKhachHangState createState() => _QLKhachHangState();
}

class _QLKhachHangState extends State<QLKhachHang> {
  // biến cho phần tìm kiếm và thêm KH
  List<KhachHang> lstKH = [];
  List<Phong> lstPhong = [];
  List<CoSo> lstCoSo = [];
  bool isLoading = true;
  String _searchQuery = "";
  bool isChecked = true;
  String status = 'Đang thuê';
  int? idcoso;
  int? idphong;

  // biến cho phần filter
  bool isCheckedFilter = true;
  String statusFilter = 'Đang thuê';
  int? idPhongFilter;
  int? idCoSoFilter;
  List<KhachHang> lstKHFilter = [];

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _sdtController = TextEditingController();
  TextEditingController _cccdController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    GetKhach();
  }

  void updateIdPhong(int newIdPhong) {
    setState(() {
      idphong = newIdPhong;
    });
  }

  void updateIdPhongFilter(int? newIdPhong) {
    setState(() {
      idPhongFilter = newIdPhong;
    });
  }

  void updateIdCoSoFilter(int? newIdCoSo) {
    setState(() {
      idCoSoFilter = newIdCoSo;
    });
  }

  void updateLstKHFilter(List<KhachHang> newList) {
    setState(() {
      lstKHFilter = newList;
    });
  }

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> GetKhach() async {
    final response = await http.get(
      //Uri.parse("http://localhost:5167/api/QuanLyKH/GetKhach/${widget.idChu}"),
      Uri.parse("${getUrl()}/api/QuanLyKH/GetKhach/${widget.idChu}"),
      headers: {"Content-Type": "application/json"},
    );
    Future.delayed(Duration(seconds: 2));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final dataReturn = json.decode(response.body);

      lstKH.clear();
      lstPhong.clear();
      lstCoSo.clear();

      // Lấy danh sách khách hàng
      final List<dynamic> dataKH = dataReturn['khach'];
      List<Map<String, dynamic>> convertDataKH =
          dataKH.map((e) => e as Map<String, dynamic>).toList();
      print(convertDataKH);

      // Lấy danh sách phòng
      List<dynamic> dataPhong = dataReturn['phongs'];
      List<Map<String, dynamic>> convertDataPhong =
          dataPhong.map((e) => e as Map<String, dynamic>).toList();
      print(convertDataPhong);

      // Lấy danh sách cơ sở
      List<dynamic> dataCoSo = dataReturn['coso'];
      List<Map<String, dynamic>> convertDataCoSo =
          dataCoSo.map((e) => e as Map<String, dynamic>).toList();
      print(convertDataCoSo);

      setState(() {
        for (Map<String, dynamic> item in convertDataKH) {
          lstKH.add(KhachHang.fromJson(item));
        }
        for (Map<String, dynamic> item in convertDataPhong) {
          lstPhong.add(Phong.fromJson(item));
        }
        for (Map<String, dynamic> item in convertDataCoSo) {
          lstCoSo.add(CoSo.fromJson(item));
        }
        isLoading = false;
        idcoso = null;
        idphong = null;
        _nameController.clear();
        _sdtController.clear();
        _cccdController.clear();
        _emailController.clear();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showTenantDialog({KhachHang? tenant}) {
    TextEditingController nameController = TextEditingController(
      text: tenant?.tenKh ?? '',
    );
    TextEditingController roomController = TextEditingController(
      text: tenant?.tenPhong ?? '',
    );
    String status = tenant?.tinhTrang == 1 ? 'Đang thuê' : 'Đã rời đi';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            tenant == null ? 'Thêm khách thuê' : 'Chi tiết khách thuê',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Họ tên'),
                readOnly: true,
              ),
              TextField(
                controller: roomController,
                decoration: InputDecoration(labelText: 'Phòng'),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              TextField(
                controller: TextEditingController(text: tenant?.sdt ?? ''),
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                readOnly: true,
              ),
              TextField(
                controller: TextEditingController(text: tenant?.ngayDen ?? ''),
                decoration: InputDecoration(labelText: 'Ngày đến'),
                readOnly: true,
              ),

              // DropdownButtonFormField<String>(
              //   value: status,
              //   decoration: InputDecoration(labelText: 'Trạng thái'),
              //   items:
              //       ['Đang thuê', 'Đã rời đi']
              //           .map(
              //             (status) => DropdownMenuItem(
              //               value: status,
              //               child: Text(status),
              //             ),
              //           )
              //           .toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       if (value == 'Đang thuê') {
              //         tenant?.tinhTrang = 1;
              //       } else {
              //         tenant?.tinhTrang = 0;
              //       }
              //     });
              //     status = value!;
              //   },
              // ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('thoát'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markTenantAsLeft(int index) async {
    final response = await http.put(
      //Uri.parse("http://localhost:5167/api/QuanLyKH/deleteKhach/${lstKH[index].idKh}",),
      Uri.parse("${getUrl()}/api/QuanLyKH/deleteKhach/${lstKH[index].idKh}"),
      headers: {"Content-Type": "application/json"},
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đánh dấu khách đã rời đi thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đánh dấu khách đã rời đi thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      lstKH[index].tinhTrang = 0;
    });
    Navigator.pop(context);
  }

  void _showdialogAddKH() {
    List<DropdownMenuItem<int>>? selectedItem;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm khách thuê'),
          content: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Họ tên'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ tên';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        } else if (!RegExp(
                          r'^[a-zA-Z0-9._%+-/*]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        ).hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _sdtController,
                      decoration: InputDecoration(labelText: 'Số điện thoại'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        } else if (value.contains(RegExp(r'[a-zA-Z]'))) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    TextFormField(
                      controller: _cccdController,
                      decoration: InputDecoration(labelText: 'CCCD'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập CCCD';
                        } else if (value.contains(RegExp(r'[a-zA-Z]'))) {
                          return 'CCCD không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    _buildropdown(
                      idcoso: idcoso,
                      idphong: idphong,
                      lstPhong: lstPhong,
                      lstCoSo: lstCoSo,
                      updateIdPhong: updateIdPhong,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  themKH();
                }
              },
              child: Text('Thêm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                idcoso = null;
                idphong = null;
                _nameController.clear();
                _sdtController.clear();
                _cccdController.clear();
                _emailController.clear();
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> themKH() async {
    final response = await http.post(
      //Uri.parse("http://localhost:5167/api/QuanLyKH/ThemKhach/${idphong}"),
      Uri.parse("${getUrl()}/api/QuanLyKH/ThemKhach/${idphong}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "tenKh": _nameController.text,
        "sdt": _sdtController.text,
        "cccd": _cccdController.text,
        "email": _emailController.text,
      }),
    );

    print(response.statusCode);
    print(idphong);
    if (response.statusCode == 200) {
      setState(() {
        isLoading = true;
        GetKhach();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thêm khách thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('lỗi'), backgroundColor: Colors.red),
        );
      }
      throw Exception('Failed to load data');
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý khách thuê'),
        actions: [
          Text(status),
          Switch(
            value: isChecked,
            onChanged: (value) {
              setState(() {
                isChecked = value;
                print(isChecked);
                if (isChecked) {
                  status = 'Đang thuê';
                } else {
                  status = 'Đã rời đi';
                }
              });
            },
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : lstKH.isNotEmpty
              ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Tìm kiếm theo tên',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  _buildFilterBar(
                    idcoso: idCoSoFilter,
                    idphong: idPhongFilter,
                    lstPhong: lstPhong,
                    lstCoSo: lstCoSo,
                    updateIdPhong: updateIdPhongFilter,
                    lstKH: lstKH,
                    updateLstKHFilter: updateLstKHFilter,
                    updateIdCoSo: updateIdCoSoFilter,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          _searchQuery.isNotEmpty
                              ? lstKH
                                  .where(
                                    (u) => u.tenKh.toLowerCase().contains(
                                      _searchQuery,
                                    ),
                                  )
                                  .length
                              : isChecked
                              ? lstKHFilter.isEmpty
                                  ? lstKH.where((u) => u.tinhTrang == 1).length
                                  : lstKHFilter
                                      .where((u) => u.tinhTrang == 1)
                                      .length
                              : lstKHFilter.isEmpty
                              ? lstKH.where((u) => u.tinhTrang == 0).length
                              : lstKHFilter
                                  .where((u) => u.tinhTrang == 0)
                                  .length,
                      itemBuilder: (context, index) {
                        final tenant =
                            _searchQuery.isNotEmpty
                                ? lstKH
                                    .where(
                                      (u) => u.tenKh.toLowerCase().contains(
                                        _searchQuery,
                                      ),
                                    )
                                    .toList()[index]
                                : isChecked
                                ? lstKHFilter.isEmpty
                                    ? lstKH
                                        .where((u) => u.tinhTrang == 1)
                                        .toList()[index]
                                    : lstKHFilter
                                        .where((u) => u.tinhTrang == 1)
                                        .toList()[index]
                                : lstKHFilter.isEmpty
                                ? lstKH
                                    .where((u) => u.tinhTrang == 0)
                                    .toList()[index]
                                : lstKHFilter
                                    .where((u) => u.tinhTrang == 1)
                                    .toList()[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            title: Text(tenant.tenKh),
                            subtitle: Text(
                              "Phòng: ${tenant.tenPhong} Cơ Sở:${tenant.tenCoSo} ",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tenant.tinhTrang == 1
                                      ? 'Đang thuê'
                                      : 'Đã rời đi',
                                  style: TextStyle(
                                    color:
                                        tenant.tinhTrang == 1
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                if (tenant.tinhTrang == 1)
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),

                                    onPressed:
                                        () => showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Xác nhận'),
                                              content: Text(
                                                'Bạn có chắc chắn muốn đánh dấu khách này đã rời đi không?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Hủy'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _markTenantAsLeft(index);
                                                  },
                                                  child: Text('Đồng ý'),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                  ),
                              ],
                            ),
                            onTap: () => _showTenantDialog(tenant: tenant),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
              : Center(child: Text("Không có dữ liệu")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showdialogAddKH(),
        child: Icon(Icons.add),
      ),
    );
  }
}
