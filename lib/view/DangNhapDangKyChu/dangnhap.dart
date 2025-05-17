import 'dart:convert';

import 'package:buoi03/TrangChu.dart';
import 'package:buoi03/dashboard.dart';
import 'package:buoi03/view/DangNhapDangKyChu/dangky.dart';
import 'package:buoi03/view/DangNhapDangKyChu/quenmk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Dangnhap());
  }
}

class Dangnhap extends StatefulWidget {
  const Dangnhap({Key? key}) : super(key: key);

  @override
  _DangnhapState createState() => _DangnhapState();
}

class _DangnhapState extends State<Dangnhap> {
  final TextEditingController taikhoan = TextEditingController();
  final TextEditingController matkhau = TextEditingController();
  final check = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isHide = true;

  Future<void> _login() async {
    if (check.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Perform login logic here
        // For example, send data to your backend or API
        final respone = await http.post(
          Uri.parse('http://localhost:5167/api/dangnhap/DangNhapChu'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "taiKhoan": taikhoan.text,
            "matKhau": matkhau.text,
          }),
        );
        await Future.delayed(Duration(seconds: 2));
        print(respone.statusCode);
        if (respone.statusCode == 200) {
          // Handle successful login
          final data = jsonDecode(respone.body);

          print(data);
          if (data['id'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Đăng nhập thành công"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(idChu: data['id']),
              ),
            );
          }
        }
        if (respone.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Tài khoản hoặc mật khẩu không đúng"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("Login failed: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: check,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đăng nhập",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: taikhoan,
                  decoration: InputDecoration(
                    labelText: "Email/CCCD",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tài khoản';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: matkhau,
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
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Quenmk()),
                        );
                      },
                      child: Text(
                        "Quên mật khẩu?",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Dangky()),
                        );
                      },
                      child: Text(
                        "Dang ky",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              "Đăng nhập",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
