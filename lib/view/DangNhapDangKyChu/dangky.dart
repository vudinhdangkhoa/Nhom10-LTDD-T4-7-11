import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Dangky extends StatelessWidget {
  const Dangky({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: DangkyScreen(),
    );
  }
}

class DangkyScreen extends StatefulWidget {
  const DangkyScreen({Key? key}) : super(key: key);

  @override
  _DangkyScreenState createState() => _DangkyScreenState();
}

class _DangkyScreenState extends State<DangkyScreen> {
  TextEditingController taikhoanController = TextEditingController();
  TextEditingController matkhauController = TextEditingController();
  TextEditingController tenController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final check = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isHide = true;

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> _register() async {
    if (check.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Perform registration logic here
        // For example, send data to your backend or API
        final respone = await http.post(
          Uri.parse('${getUrl()}/api/dangnhap/DangKyChu'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "ten": tenController.text,
            "taiKhoan": emailController.text,
            "matKhau": matkhauController.text,
          }),
        );
        await Future.delayed(Duration(seconds: 2));
        print(respone.statusCode);
        if (respone.statusCode == 200) {
          // Handle successful registration
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Đăng ký thành công')));
          Navigator.pop(context);
        } else {
          // Handle error response
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Đăng ký thất bại')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }

      // Simulate a network request

      // Here you can add your registration logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: check,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Đăng ký",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  ).hasMatch(value)) {
                    return 'Vui lòng nhập địa chỉ email hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: matkhauController,
                obscureText: _isHide,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isHide ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isHide = !_isHide;
                      });
                    },
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: tenController,
                decoration: InputDecoration(
                  labelText: "Tên",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Đăng ký",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
