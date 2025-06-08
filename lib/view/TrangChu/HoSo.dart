import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';

class HoSo extends StatefulWidget {
  int idChu;
  HoSo({Key? key, required this.idChu}) : super(key: key);

  @override
  _HoSoState createState() => _HoSoState();
}

class _HoSoState extends State<HoSo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _hoTenController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _giaDienController = TextEditingController();
  final TextEditingController _giaNuocController = TextEditingController();
  Map<String, dynamic> hoSoChu = {};
  bool isRead = true;
  bool isloading = true;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedAvatar;

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> GetHoSoChu() async {
    try {
      final respone = await http.get(
        Uri.parse('${getUrl()}/api/TrangChu/GetThongTinChu/${widget.idChu}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print('Response status: ${respone.statusCode}');
      if (respone.statusCode == 200) {
        print('Response data: ${respone.body}');
        setState(() {
          hoSoChu = jsonDecode(respone.body);
          isloading = false;

          _hoTenController.text = hoSoChu['ten'] ?? '';
          _emailController.text = hoSoChu['taiKhoan'] ?? '';
          _giaDienController.text = hoSoChu['giaDien']?.toString() ?? '';
          _giaNuocController.text = hoSoChu['giaNuoc']?.toString() ?? '';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updateHoSoChu() async {
    final respone = await http.put(
      Uri.parse('${getUrl()}/api/TrangChu/UpdateHoSoChu/${widget.idChu}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'hoten': _hoTenController.text,
        'taikhoan': _emailController.text,
        'giadien': double.tryParse(_giaDienController.text),
        'gianuoc': double.tryParse(_giaNuocController.text),
      }),
    );
    print('Response status: ${respone.statusCode}');
    if (respone.statusCode == 200) {
      print('Update successful');
      // Refresh the profile after update
      setState(() {
        isRead = true;
        isloading = true;
        GetHoSoChu();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cập nhật hồ sơ thành công')));
        // Set to read-only mode after update
      });
    } else {
      print('Update failed: ${respone.body}');
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    if (await permission
        .isDenied) //Kiểm tra xem quyền cụ thể (ví dụ: quyền truy cập bộ nhớ, camera, v.v.) có bị từ chối hay không.
    {
      await permission
          .request(); //Nếu quyền bị từ chối, phương thức này sẽ hiển thị hộp thoại yêu cầu người dùng cấp quyền.
    }
  }

  Future<void> pickAndPreviewAvatar() async {
    await _requestPermission(Permission.storage);
    final XFile? pickAnh = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickAnh != null) {
      setState(() {
        _pickedAvatar = pickAnh;
      });
      // Hiện dialog xác nhận
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Cập nhật ảnh đại diện?'),
              content: Text('Bạn có muốn cập nhật ảnh đại diện này không?'),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pickedAvatar = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await uploadAvatar(_pickedAvatar!);
                  },
                  child: Text('Cập nhật'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> uploadAvatar(XFile pickAnh) async {
    final bytes = await pickAnh.readAsBytes();
    final base64Image = base64Encode(bytes);
    print('Base64 length: ${base64Image.length}');

    print('Base64 Image: $base64Image');
    final response = await http.put(
      Uri.parse('${getUrl()}/api/TrangChu/UpdateAvatarChu/${widget.idChu}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'avatar': base64Image}),
    );
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      setState(() {
        _pickedAvatar = null;
        GetHoSoChu();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật ảnh đại diện thất bại')));
      setState(() {
        _pickedAvatar = null;
        GetHoSoChu();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    GetHoSoChu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Hồ Sơ Cá Nhân',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        leading: IconButton(
          onPressed: () {
            if (!isRead && _formKey.currentState!.validate()) {
              updateHoSoChu();
            }
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body:
          isloading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[600]!,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Đang tải hồ sơ...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header với background màu
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      padding: EdgeInsets.only(bottom: 30),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          // Avatar section
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child:
                                    _pickedAvatar != null
                                        ? CircleAvatar(
                                          radius: 60,
                                          backgroundImage: FileImage(
                                            File(_pickedAvatar!.path),
                                          ),
                                        )
                                        : (hoSoChu['avatar'] == 'khonghinh'
                                            ? CircleAvatar(
                                              radius: 60,
                                              backgroundImage: AssetImage(
                                                'assets/images/avatar.jpg',
                                              ),
                                            )
                                            : CircleAvatar(
                                              radius: 60,
                                              backgroundImage: NetworkImage(
                                                '${getUrl()}/images/Avatar/${hoSoChu['avatar']}',
                                              ),
                                            )),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: pickAndPreviewAvatar,
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.blue[600],
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            hoSoChu['ten'] ?? 'Chưa có tên',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            hoSoChu['taiKhoan'] ?? 'Chưa có email',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form section
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Card chứa form
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thông tin cá nhân',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Họ tên
                                  _buildTextField(
                                    controller: _hoTenController,
                                    label: 'Họ và tên',
                                    icon: Icons.person,
                                    readOnly: isRead,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập họ tên';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: 15),

                                  // Email
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.email,
                                    readOnly: isRead,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập email';
                                      } else if (!RegExp(
                                        r'^[^@]+@[^@]+\.[^@]+',
                                      ).hasMatch(value)) {
                                        return 'Vui lòng nhập email hợp lệ';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20),

                            // Card giá cả
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thiết lập giá',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _giaDienController,
                                          label: 'Giá điện ',
                                          icon: Icons.flash_on,
                                          readOnly: isRead,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value == '0') {
                                              return 'Vui lòng nhập giá điện';
                                            } else if (double.tryParse(value) ==
                                                null) {
                                              return 'Vui lòng nhập số hợp lệ';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _giaNuocController,
                                          label: 'Giá nước ',
                                          icon: Icons.water_drop,
                                          readOnly: isRead,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value == '0') {
                                              return 'Vui lòng nhập giá nước';
                                            } else if (double.tryParse(value) ==
                                                null) {
                                              return 'Vui lòng nhập số hợp lệ';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 30),

                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isRead = !isRead;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            isRead
                                                ? Colors.orange
                                                : Colors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isRead ? Icons.edit : Icons.cancel,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            isRead ? 'Chỉnh sửa' : 'Hủy',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed:
                                          isRead
                                              ? null
                                              : () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  updateHoSoChu();
                                                }
                                              },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.save, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Lưu thay đổi',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // Hàm helper để tạo TextField đẹp
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool readOnly,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
      ),
    );
  }
}
