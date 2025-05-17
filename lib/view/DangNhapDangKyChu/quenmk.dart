import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Quenmk extends StatefulWidget {
  const Quenmk({Key? key}) : super(key: key);

  @override
  _QuenmkState createState() => _QuenmkState();
}

class _QuenmkState extends State<Quenmk> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _codeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _newPasswordFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isCodeVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> CapLaiMatKhau() async {
    if (_codeFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      try {
        final response = await http.get(
          Uri.parse(
            'http://localhost:5167/api/dangnhap/XacThuc/${_codeController.text}',
          ),
          headers: {"Content-Type": "application/json"},
        );
        print(response.statusCode);
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          int userid = responseData['userId'];
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Nhập mật khẩu mới"),
                content: SingleChildScrollView(
                  child: Form(
                    key: _newPasswordFormKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _newPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu mới';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          hintText: 'Nhập mật khẩu mới',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      if (_newPasswordFormKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = !_isLoading;
                        });
                        Navigator.pop(context);
                        try {
                          final response = await http.put(
                            Uri.parse(
                              'http://localhost:5167/api/dangnhap/CapLaiMatKhau/$userid',
                            ),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({
                              "taiKhoan": "string",
                              "matKhau": _newPasswordController.text,
                            }),
                          );
                          print(response.statusCode);
                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Cập nhật mật khẩu thành công"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text("Lỗi"),
                                  content: Text(
                                    "Đã xảy ra lỗi: ${e.toString()}",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                          );
                        }
                      }
                    },
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              "Cập nhật",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Lỗi"),
                content: Text("Đã xảy ra lỗi: ${e.toString()}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> GuiMail() async {
    _isLoading = false;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await http.get(
          Uri.parse(
            'http://localhost:5167/api/dangnhap/ForgotPassword/${_emailController.text}',
          ),
        );
        print(response.statusCode);
        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Vui lòng nhập mã gửi về email của bạn"),
                content: SingleChildScrollView(
                  child: Form(
                    key: _codeFormKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _codeController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mã xác nhận';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Mã xác nhận',
                          hintText: 'Nhập mã xác nhận',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      if (_codeFormKey.currentState!.validate()) {
                        setState(() {
                          _isCodeVisible = !_isCodeVisible;
                        });
                        Navigator.pop(context);
                        CapLaiMatKhau();
                      }
                    },
                    child:
                        _isCodeVisible
                            ? CircularProgressIndicator(
                              color: const Color.fromARGB(255, 175, 31, 31),
                            )
                            : Text(
                              "gui",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            margin: EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/avatar.jpg'),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        } else if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        ).hasMatch(value)) {
                          return 'Vui lòng nhập địa chỉ email hợp lệ';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        prefixIconColor: Colors.blue,
                        labelText: 'Email',
                        hintText: 'Nhập email của bạn',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = !_isLoading;
                            });
                            if (_isLoading) {
                              null;
                            }
                            GuiMail();
                          }
                        },
                        child:
                            _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  "Gui",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
