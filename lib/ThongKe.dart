import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Bạn có thể dùng thư viện này để thêm biểu đồ

class Thongke extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thống kê')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Mục 1: Doanh thu
          _buildSectionTitle('Doanh thu'),
          _buildBarChart(), // Biểu đồ doanh thu
          SizedBox(height: 16),
          _buildRevenueDetail(), // Thống kê doanh thu chi tiết
          // Mục 2: Số lượng khách thuê
          _buildSectionTitle('Số lượng khách thuê'),
          _buildPieChart(), // Biểu đồ tròn khách thuê
          SizedBox(height: 16),
          _buildGuestDetails(), // Danh sách khách thuê chi tiết
          // Mục 3: Tình trạng hóa đơn
          _buildSectionTitle('Tình trạng hóa đơn'),
          _buildInvoiceSummary(), // Thống kê hóa đơn
          // Mục 4: Tình trạng phòng
          _buildSectionTitle('Tình trạng phòng'),
          _buildRoomStatus(), // Danh sách tình trạng phòng
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBarChart() {
    // Ví dụ: Biểu đồ doanh thu theo tháng
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(fromY: 0, toY: 5, color: Colors.blue)],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(fromY: 0, toY: 6, color: Colors.blue)],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [BarChartRodData(fromY: 0, toY: 8, color: Colors.blue)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueDetail() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text('Tổng doanh thu tháng này'),
        subtitle: Text('10,000,000 VND'),
        trailing: Icon(Icons.attach_money, color: Colors.green),
      ),
    );
  }

  Widget _buildPieChart() {
    // Ví dụ: Biểu đồ tròn hiển thị trạng thái phòng
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 60,
              color: Colors.green,
              title: 'Đã thuê',
            ),
            PieChartSectionData(value: 40, color: Colors.red, title: 'Trống'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestDetails() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.person, color: Colors.blue),
          title: Text('Cơ sở 1: 10 khách'),
        ),
        ListTile(
          leading: Icon(Icons.person, color: Colors.blue),
          title: Text('Cơ sở 2: 8 khách'),
        ),
      ],
    );
  }

  Widget _buildInvoiceSummary() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.check, color: Colors.green),
          title: Text('Hóa đơn đã thanh toán'),
          subtitle: Text('20 hóa đơn'),
        ),
        ListTile(
          leading: Icon(Icons.warning, color: Colors.red),
          title: Text('Hóa đơn chưa thanh toán'),
          subtitle: Text('5 hóa đơn'),
        ),
      ],
    );
  }

  Widget _buildRoomStatus() {
    return Column(
      children: [
        Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            title: Text('Phòng 101'),
            subtitle: Text('Đã thuê'),
            trailing: Icon(Icons.person, color: Colors.red),
          ),
        ),
        Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            title: Text('Phòng 102'),
            subtitle: Text('Còn trống'),
            trailing: Icon(Icons.home, color: Colors.green),
          ),
        ),
      ],
    );
  }
}
