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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<int>(
            value: widget.idcoso == 0 ? null : widget.idcoso,
            hint: Text(
              "Chọn cơ sở",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items:
                widget.lstCoSo
                    .map(
                      (u) => DropdownMenuItem(
                        child: Text(u.tenCoSo, style: TextStyle(fontSize: 16)),
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
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<int>(
            value: widget.idphong,
            hint: Text(
              "Chọn phòng",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items:
                widget.lstPhong
                    .where((u) => u.idCoSo == widget.idcoso)
                    .map(
                      (u) => DropdownMenuItem(
                        child: Text(
                          u.tenPhong ?? 'Không tên',
                          style: TextStyle(fontSize: 16),
                        ),
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
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bộ lọc",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<int?>(
                    value: widget.idcoso,
                    hint: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "Chọn cơ sở",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    isExpanded: true,
                    underline: SizedBox(),
                    items:
                        widget.lstCoSo
                            .map(
                              (coSo) => DropdownMenuItem(
                                value: coSo.idCoSo,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(coSo.tenCoSo),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        widget.idcoso = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<int?>(
                    value: widget.idphong,
                    hint: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "Chọn phòng",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    isExpanded: true,
                    underline: SizedBox(),
                    items:
                        widget.lstPhong
                            .where((phong) => phong.idCoSo == widget.idcoso)
                            .map(
                              (phong) => DropdownMenuItem(
                                value: phong.idPhong,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(phong.tenPhong ?? 'Không tên'),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        widget.idphong = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
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
                  icon: Icon(Icons.filter_list, size: 20),
                  label: Text("Lọc"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      widget.idcoso = null;
                      widget.idphong = null;
                      widget.updateLstKHFilter([]);
                      widget.updateIdPhong(null);
                      widget.updateIdCoSo(null);
                    });
                  },
                  icon: Icon(Icons.clear, size: 20),
                  label: Text("Xóa lọc"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  List<KhachHang> lstKH = [];
  List<Phong> lstPhong = [];
  List<CoSo> lstCoSo = [];
  bool isLoading = true;
  String _searchQuery = "";
  bool isChecked = true;
  String status = 'Đang thuê';
  int? idcoso;
  int? idphong;

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
      Uri.parse("${getUrl()}/api/QuanLyKH/GetKhach/${widget.idChu}"),
      headers: {"Content-Type": "application/json"},
    );
    Future.delayed(Duration(seconds: 2));
    print('status code getkh: ${response.statusCode}');
    print(response.body);
    if (response.statusCode == 200) {
      final dataReturn = json.decode(response.body);

      lstKH.clear();
      lstPhong.clear();
      lstCoSo.clear();

      final List<dynamic> dataKH = dataReturn['khach'];
      List<Map<String, dynamic>> convertDataKH =
          dataKH.map((e) => e as Map<String, dynamic>).toList();
      print(convertDataKH);

      List<dynamic> dataPhong = dataReturn['phongs'];
      List<Map<String, dynamic>> convertDataPhong =
          dataPhong.map((e) => e as Map<String, dynamic>).toList();
      print(convertDataPhong);

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            tenant == null ? 'Thêm khách thuê' : 'Chi tiết khách thuê',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(nameController, 'Họ tên', Icons.person),
                SizedBox(height: 16),
                _buildDialogTextField(roomController, 'Phòng', Icons.room),
                SizedBox(height: 16),
                _buildDialogTextField(
                  TextEditingController(text: tenant?.sdt ?? ''),
                  'Số điện thoại',
                  Icons.phone,
                ),
                SizedBox(height: 16),
                _buildDialogTextField(
                  TextEditingController(text: tenant?.ngayDen ?? ''),
                  'Ngày đến',
                  Icons.calendar_today,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Thoát',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        readOnly: true,
      ),
    );
  }

  Future<void> _markTenantAsLeft(int index) async {
    final response = await http.put(
      Uri.parse("${getUrl()}/api/QuanLyKH/deleteKhach/${lstKH[index].idKh}"),
      headers: {"Content-Type": "application/json"},
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đánh dấu khách đã rời đi thành công'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đánh dấu khách đã rời đi thất bại'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    setState(() {
      lstKH[index].tinhTrang = 0;
    });
    Navigator.pop(context);
  }

  void _showdialogAddKH() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Thêm khách thuê',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Form(
            key: _formKey,
            child: Container(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFormField(
                      _nameController,
                      'Họ tên',
                      Icons.person,
                      'Vui lòng nhập họ tên',
                    ),
                    SizedBox(height: 16),
                    _buildFormField(
                      _emailController,
                      'Email',
                      Icons.email,
                      'Vui lòng nhập email',
                      isEmail: true,
                    ),
                    SizedBox(height: 16),
                    _buildFormField(
                      _sdtController,
                      'Số điện thoại',
                      Icons.phone,
                      'Vui lòng nhập số điện thoại',
                      isPhone: true,
                    ),
                    SizedBox(height: 16),
                    _buildFormField(
                      _cccdController,
                      'CCCD',
                      Icons.credit_card,
                      'Vui lòng nhập CCCD',
                      isNumber: true,
                    ),
                    SizedBox(height: 20),
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
                Navigator.pop(context);
                idcoso = null;
                idphong = null;
                _nameController.clear();
                _sdtController.clear();
                _cccdController.clear();
                _emailController.clear();
              },
              child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  themKH();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormField(
    TextEditingController controller,
    String label,
    IconData icon,
    String errorMsg, {
    bool isEmail = false,
    bool isPhone = false,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorMsg;
          }
          if (isEmail &&
              !RegExp(
                r'^[a-zA-Z0-9._%+-/*]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              ).hasMatch(value)) {
            return 'Email không hợp lệ';
          }
          if ((isPhone || isNumber) && value.contains(RegExp(r'[a-zA-Z]'))) {
            return '${isPhone ? "Số điện thoại" : "CCCD"} không hợp lệ';
          }
          return null;
        },
      ),
    );
  }

  Future<void> themKH() async {
    final response = await http.post(
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('lỗi'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      throw Exception('Failed to load data');
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Quản lý khách thuê',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8),
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
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue.shade600),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải dữ liệu...',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
              : lstKH.isNotEmpty
              ? Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Tìm kiếm theo tên',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
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
                      padding: EdgeInsets.symmetric(horizontal: 16),
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
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 300),
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                tenant.tenKh,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              subtitle: Text(
                                "Phòng: ${tenant.tenPhong} - Cơ sở: ${tenant.tenCoSo}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tenant.tinhTrang == 1
                                        ? 'Đang thuê'
                                        : 'Đã rời đi',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          tenant.tinhTrang == 1
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                  if (tenant.tinhTrang == 1)
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                title: Text(
                                                  'Xác nhận',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                content: Text(
                                                  'Bạn có chắc chắn muốn đánh dấu khách này đã rời đi không?',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: Text(
                                                      'Hủy',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => _markTenantAsLeft(
                                                          index,
                                                        ),
                                                    child: Text(
                                                      'Đồng ý',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Color(
                                                          0xFF667eea,
                                                        ),
                                                      ),
                                                    ),
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
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
              : Center(
                child: Text(
                  "Không có dữ liệu",
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showdialogAddKH(),
        backgroundColor: Color(0xFF667eea),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
