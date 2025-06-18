import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HoSoKH extends StatefulWidget {
  int idKH;
  HoSoKH({Key? key, required this.idKH}) : super(key: key);

  @override
  _HoSoKHState createState() => _HoSoKHState();
}

class _HoSoKHState extends State<HoSoKH> {
  bool isloading = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _tenController = TextEditingController();
  TextEditingController _sdtController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _cccdController = TextEditingController();

  bool isRead = true;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedAvatar;

  Map<String, dynamic> InfoKH = {};

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> getInfoKH() async {
    try {
      final respone = await http.get(
        Uri.parse('${getUrl()}/api/TrangChuKH/getinfoKH/${widget.idKH}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print('getInfoKH: ${respone.statusCode}');
      if (respone.statusCode == 200) {
        setState(() {
          InfoKH = json.decode(respone.body);
          isloading = false;

          // Set giá trị cho các controller
          _tenController.text = InfoKH['tenKh'] ?? '';
          _sdtController.text = InfoKH['sdt'] ?? '';
          _emailController.text = InfoKH['email'] ?? '';
          _cccdController.text = InfoKH['cccd'] ?? '';
        });
        print('InfoKH: $InfoKH');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updateInfoKH() async {
    try {
      final response = await http.put(
        Uri.parse('${getUrl()}/api/TrangChuKH/updateInfoKH/${widget.idKH}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'tenKH': _tenController.text,
          'sdt': _sdtController.text,
          'email': _emailController.text,
          'cccd': _cccdController.text,
        }),
      );
      print('Update response: ${response.statusCode}');
      if (response.statusCode == 200) {
        setState(() {
          isRead = true;
          isloading = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            backgroundColor: Colors.green,
          ),
        );
        getInfoKH(); // Refresh dữ liệu
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật thông tin thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Update error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi khi cập nhật'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
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

    final response = await http.put(
      Uri.parse('${getUrl()}/api/TrangChuKH/updateAvatarKH/${widget.idKH}'),
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
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật ảnh đại diện thành công')),
      );
      getInfoKH();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật ảnh đại diện thất bại')));
      setState(() {
        _pickedAvatar = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInfoKH();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Hồ Sơ Khách Hàng',
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
                      'Đang tải thông tin...',
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
                                        : (InfoKH['avatar'] == 'khonghinh'
                                            ? CircleAvatar(
                                              radius: 60,
                                              backgroundImage: AssetImage(
                                                'assets/images/avatar.jpg',
                                              ),
                                            )
                                            : CircleAvatar(
                                              radius: 60,
                                              backgroundImage: NetworkImage(
                                                '${getUrl()}/images/Avatar/${InfoKH['avatar']}',
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
                            InfoKH['tenKH'] ?? 'Chưa có tên',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            InfoKH['email'] ?? 'Chưa có email',
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
                        key: formKey,
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
                                    controller: _tenController,
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

                                  // Số điện thoại
                                  _buildTextField(
                                    controller: _sdtController,
                                    label: 'Số điện thoại',
                                    icon: Icons.phone,
                                    readOnly: isRead,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập số điện thoại';
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

                                  SizedBox(height: 15),

                                  // CCCD
                                  _buildTextField(
                                    controller: _cccdController,
                                    label: 'CCCD/CMND',
                                    icon: Icons.credit_card,
                                    readOnly: isRead,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập CCCD/CMND';
                                      }
                                      return null;
                                    },
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
                                        if (!isRead) {
                                          // Reset về giá trị ban đầu khi hủy
                                          _tenController.text =
                                              InfoKH['tenKH'] ?? '';
                                          _sdtController.text =
                                              InfoKH['sdt'] ?? '';
                                          _emailController.text =
                                              InfoKH['email'] ?? '';
                                          _cccdController.text =
                                              InfoKH['cccd'] ?? '';
                                        }
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
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  updateInfoKH();
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
