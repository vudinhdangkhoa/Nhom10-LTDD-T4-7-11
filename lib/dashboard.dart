import 'dart:convert';

import 'package:http/http.dart' as http;

import 'view/ThongKe/ThongKe.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'view/QuanLy/QuanLyCoSo.dart';
import 'view/QuanLy/QuanLyKhach.dart';
import 'view/QuanLy/QuanLyHoaDon.dart';

class TrangDashboard extends StatefulWidget {
  final int idChu;
  const TrangDashboard({Key? key, required this.idChu}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<TrangDashboard> {
  int tongPhong = 0;
  int phongTrong = 0;
  int khachThue = 0;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    GetPhongvaKhach();
  }

  Future<void> GetPhongvaKhach() async {
    // Simulate a network call
    try {
      final response = await http.get(
        Uri.parse(
          "http://localhost:5167/api/TrangChu/GetPhongvaKhach/${widget.idChu}",
        ),
        headers: {"Content-Type": "application/json"},
      );
      await Future.delayed(Duration(seconds: 2));
      print(response.statusCode);
      if (response.statusCode == 200) {
        // Handle successful response
        final data = jsonDecode(response.body);

        // Parse the data and update your state
        setState(() {
          // Assuming the response is a JSON object with keys "tongPhong", "phongTrong", and "khachThue"
          tongPhong = data['tongPhong'] ?? 0;
          phongTrong = data['phongTrong'] ?? 0;
          khachThue = data['tongKhach'] ?? 0;
          _isLoading = false;
        });
      } else {
        // Handle error response
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle any errors here
      print("Error fetching data: $e");
    }

    // Here you would typically fetch data from an API or database
  }

  Widget _buildGridItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget route,
  ) {
    return GestureDetector(
      onTap: () async {
        // Navigate to respective management page
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => route),
        );
        if (result == null) {
          setState(() {
            // Refresh the dashboard state if needed
            _isLoading = true;
            GetPhongvaKhach();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                  children: [
                    Text(
                      "Tổng quan",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildDashboardCard(
                            "Số phòng",
                            tongPhong.toString(),
                            Icons.hotel,
                          ),
                        ),
                        Expanded(
                          child: _buildDashboardCard(
                            "Phòng trống",
                            phongTrong.toString(),
                            Icons.meeting_room,
                          ),
                        ),
                        Expanded(
                          child: _buildDashboardCard(
                            "Khách thuê",
                            khachThue.toString(),
                            Icons.people,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        _buildGridItem(
                          context,
                          "Quản lý phòng",
                          Icons.room,
                          Colors.red,
                          DSCoSoVaPhong(idChu: widget.idChu),
                        ),
                        _buildGridItem(
                          context,
                          "Quản lý khách",
                          Icons.person,
                          Colors.green,
                          QLKhachHang(idChu: widget.idChu),
                        ),
                        _buildGridItem(
                          context,
                          "Quản lý hóa đơn",
                          Icons.room_service,
                          Colors.orange,
                          QLHoaDon(),
                        ),
                        _buildGridItem(
                          context,
                          "Thống kê",
                          Icons.receipt,
                          Colors.blue,
                          Thongke(idChuu: widget.idChu),
                        ),
                      ],
                    ),
                    Text(
                      "Thống kê doanh thu",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
      ),
    );
  }
}

Widget _buildDashboardCard(String title, String value, IconData icon) {
  return Card(
    elevation: 5,

    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 18, color: Colors.blue)),
        ],
      ),
    ),
  );
}
