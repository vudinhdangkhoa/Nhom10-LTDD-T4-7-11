import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Thongke extends StatelessWidget {
  int idChuu;
  Thongke({Key? key, required this.idChuu}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thống kê')),
      body: ScreenThongKe(idChuu: idChuu),
    );
  }
}

class ScreenThongKe extends StatefulWidget {
  int idChuu;
  ScreenThongKe({Key? key, required this.idChuu}) : super(key: key);

  @override
  _ScreenThongKeState createState() => _ScreenThongKeState();
}

class _ScreenThongKeState extends State<ScreenThongKe> {
  List<Map<String, dynamic>> data = [];
  int tongPhongDaThue = 0;
  int tongPhongTrong = 0;
  bool isLoading = true;
  String erroMessage = "";
  @override
  void initState() {
    super.initState();
    GetSLPhongVaKH();
  }

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> GetSLPhongVaKH() async {
    try {
      final response = await http.get(
        // Uri.parse(
        //   'http://localhost:5167/api/ThongKeKhach/GetKhach/${widget.idChuu}',
        // ),
        Uri.parse("${getUrl()}/api/ThongKeKhach/GetKhach/${widget.idChuu}"),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        final _result = jsonDecode(response.body);
        List<dynamic> dataConvert = _result['coSo'];
        data = dataConvert.map((item) => item as Map<String, dynamic>).toList();
        tongPhongDaThue = _result['phongthue'];
        tongPhongTrong = _result['phongtrong'];
        setState(() {
          isLoading = false;
          erroMessage = "";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thống kê thành công'),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : erroMessage.isEmpty
        ? ListView(
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
        )
        : Center(
          child: Text(
            erroMessage,
            style: TextStyle(color: Colors.red, fontSize: 18),
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
              value: tongPhongDaThue.toDouble(),
              color: Colors.green,
              title: 'Đã thuê',
            ),
            PieChartSectionData(
              value: tongPhongTrong.toDouble(),
              color: Colors.red,
              title: 'Trống',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestDetails() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            title: Text(
              'Tên Cơ Sở: ${data[index]['tenCoSo']}: ${data[index]['soKhach']} khách',
            ),
          ),
        );
      },
      itemCount: data.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
