import 'ThongKe.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'QuanLyPhongVaCoSo.dart';
import 'QuanLyKhach.dart';
import 'QuanLyHoaDon.dart';

Widget _buildGridItem(
  BuildContext context,
  String title,
  IconData icon,
  Color color,
  Widget route,
) {
  return GestureDetector(
    onTap: () {
      // Navigate to respective management page
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
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

class TrangDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Tổng quan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildDashboardCard("Số phòng", "120", Icons.hotel),
                ),
                Expanded(
                  child: _buildDashboardCard(
                    "Phòng trống",
                    "35",
                    Icons.meeting_room,
                  ),
                ),
                Expanded(
                  child: _buildDashboardCard("Khách thuê", "85", Icons.people),
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
                  DSCoSoVaPhong(),
                ),
                _buildGridItem(
                  context,
                  "Quản lý khách",
                  Icons.person,
                  Colors.green,
                  QLKhachHang(),
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
                  Thongke(),
                ),
              ],
            ),
            Text(
              "Thống kê doanh thu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
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
}
