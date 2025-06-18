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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Thống kê',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple[600],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
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
  int tongPhongDaThue = 0;
  int tongPhongTrong = 0;
  bool isLoading = true;
  String erroMessage = "";

  //biến thống kê số lượng phòng và khách
  List<Map<String, dynamic>> data = [];
  bool isloadingGetSLPhongVaKH = true;

  //biến thống kê doanh thu
  List<Map<String, dynamic>> dataDoanhThu = [];
  bool isloadingGetThongKeDoanhThu = true;

  //biến trạng thái hóa đơn
  List<Map<String, dynamic>> dataTrangThaiHoaDon = [];
  bool isloadingGetTrangThaiHoaDon = true;

  @override
  void initState() {
    super.initState();
    GetSLPhongVaKH();
    GetThongKeDoanhThu();
    GetTrangThaiHoaDon();
  }

  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  void setLoading() {
    setState(() {
      if (isloadingGetSLPhongVaKH ||
          isloadingGetThongKeDoanhThu ||
          isloadingGetTrangThaiHoaDon) {
        isLoading = true;
      } else {
        isLoading = false;
      }
    });
  }

  Future<void> GetSLPhongVaKH() async {
    try {
      final response = await http.get(
        Uri.parse("${getUrl()}/api/ThongKeKhach/GetKhach/${widget.idChuu}"),
      );

      print('status code GetSLPhongVaKH: ${response.statusCode}');
      if (response.statusCode == 200) {
        final _result = jsonDecode(response.body);
        List<dynamic> dataConvert = _result['coSo'];
        data = dataConvert.map((item) => item as Map<String, dynamic>).toList();
        tongPhongDaThue = _result['phongthue'];
        tongPhongTrong = _result['phongtrong'];
        setState(() {
          isloadingGetSLPhongVaKH = false;
          setLoading();
          erroMessage = "";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Thống kê thành công'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }
    } catch (e) {}
  }

  Future<void> GetThongKeDoanhThu() async {
    final respone = await http.get(
      Uri.parse('${getUrl()}/api/ThongKeDoanhThu/GetDoanhThu/${widget.idChuu}'),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    await Future.delayed(Duration(seconds: 2));
    print('status code GetThongKeDoanhThu: ${respone.statusCode}');
    print('body: ${respone.body}');
    if (respone.statusCode == 200) {
      List<dynamic> dataConvert = jsonDecode(respone.body);
      if (dataConvert.isNotEmpty) {
        setState(() {
          dataDoanhThu =
              dataConvert.map((item) => item as Map<String, dynamic>).toList();
          isloadingGetThongKeDoanhThu = false;
          setLoading();
        });
      } else {
        setState(() {
          isloadingGetThongKeDoanhThu = false;
          erroMessage = 'Không có dữ liệu doanh thu';
          isLoading = false;
        });
      }
    }
  }

  Future<void> GetTrangThaiHoaDon() async {
    final respone = await http.get(
      Uri.parse(
        '${getUrl()}/api/ThongKeHoaDon/GetTrangThaiHoaDon/${widget.idChuu}',
      ),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('status code GetTrangThaiHoaDon: ${respone.statusCode}');
    if (respone.statusCode == 200) {
      // Xử lý dữ liệu
      List<dynamic> dataConvert = jsonDecode(respone.body);
      dataTrangThaiHoaDon =
          dataConvert.map((item) => item as Map<String, dynamic>).toList();
      setState(() {
        // Cập nhật trạng thái nếu cần
        isloadingGetTrangThaiHoaDon = false;
        setLoading();
      });
    } else {
      setState(() {
        erroMessage = 'Không thể tải trạng thái hóa đơn';
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(erroMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: Duration(seconds: 1),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
              SizedBox(height: 16),
              Text(
                'Đang tải thống kê...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        )
        : erroMessage.isEmpty
        ? SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              _buildThongTinChung(),
              SizedBox(height: 24),

              // Mục 1: Doanh thu
              if (isloadingGetThongKeDoanhThu == false) ...[
                _buildKhungGiaoDien(
                  'Doanh thu năm: ${DateTime.now().year}',
                  Icons.trending_up,
                  Colors.green,
                ),
                SizedBox(height: 12),
                _buildBieuDoCot(),
                SizedBox(height: 16),
                _buildDoanhThuThang(),
                SizedBox(height: 24),
              ] else ...[
                Center(child: CircularProgressIndicator()),
              ],
              // Mục 2: Số lượng khách thuê
              _buildKhungGiaoDien(
                'Số lượng khách thuê',
                Icons.people,
                Colors.blue,
              ),
              SizedBox(height: 12),
              _buildBieuDoTron(),
              SizedBox(height: 16),
              _buildThongKeSLKhachTrenCS(),
              SizedBox(height: 24),

              // Mục 3: Tình trạng hóa đơn
              _buildKhungGiaoDien(
                'Tình trạng hóa đơn',
                Icons.receipt,
                Colors.orange,
              ),
              SizedBox(height: 12),
              _buildTinhTrangHoaDon(),
              SizedBox(height: 24),
            ],
          ),
        )
        : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                erroMessage,
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildThongTinChung() {
    final totalRooms = tongPhongDaThue + tongPhongTrong;
    final occupancyRate =
        totalRooms > 0 ? (tongPhongDaThue / totalRooms * 100) : 0;

    return Row(
      children: [
        Expanded(
          child: _buildCardThongTinChung(
            'Phòng đã thuê',
            tongPhongDaThue.toString(),
            Icons.hotel,
            Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildCardThongTinChung(
            'Phòng trống',
            tongPhongTrong.toString(),
            Icons.home_outlined,
            Colors.orange,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildCardThongTinChung(
            'Tỷ lệ lấp đầy',
            '${occupancyRate.toStringAsFixed(1)}%',
            Icons.pie_chart,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildCardThongTinChung(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKhungGiaoDien(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildBieuDoCot() {
    return Container(
      height: 240,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          backgroundColor: Colors.transparent,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}M',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() <= dataDoanhThu.length) {
                    return Text(
                      'T${dataDoanhThu[value.toInt()]['thang']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _listCotDuLieu(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _listCotDuLieu() {
    return List.generate(dataDoanhThu.length, (index) {
      final item = dataDoanhThu[index];
      return BarChartGroupData(
        x: index, // dùng index làm x
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: (item['tongtien'] as num).toDouble() / 1000000,
            color: Colors.green[400]!,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildDoanhThuThang() {
    final Map<String, dynamic> doanhThuThangTruoc =
        dataDoanhThu
            .where((item) => item['thang'] == DateTime.now().month - 1)
            .first;
    final Map<String, dynamic> doanhThuThangTruocNua =
        dataDoanhThu
            .where((item) => item['thang'] == DateTime.now().month - 2)
            .first;
    double phanTramBienTrien =
        ((doanhThuThangTruoc['tongtien'] /
                doanhThuThangTruocNua['tongtien'] *
                100) -
            100);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.attach_money, color: Colors.green[600], size: 24),
        ),
        title: Text(
          'Tổng doanh thu tháng ${doanhThuThangTruoc['thang'].toString()}',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${doanhThuThangTruoc['tongtien'].toString()} VNĐ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[600],
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              phanTramBienTrien >= 0
                  ? Text(
                    '+${phanTramBienTrien.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                  : Text(
                    '-${phanTramBienTrien.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildBieuDoTron() {
    return Container(
      height: 240,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: tongPhongDaThue.toDouble(),
                    color: Colors.green[400]!,
                    title: '${tongPhongDaThue}',
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: tongPhongTrong.toDouble(),
                    color: Colors.orange[400]!,
                    title: '${tongPhongTrong}',
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(
                  'Đã thuê',
                  Colors.green[400]!,
                  tongPhongDaThue,
                ),
                SizedBox(height: 12),
                _buildLegendItem('Trống', Colors.orange[400]!, tongPhongTrong),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThongKeSLKhachTrenCS() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.business, color: Colors.blue[600], size: 20),
            ),
            title: Text(
              data[index]['tenCoSo'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            subtitle: Text(
              'Số lượng khách thuê',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${data[index]['soKhach']} khách',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
      itemCount: data.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  Widget _buildTinhTrangHoaDon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: dataTrangThaiHoaDon.length,
        itemBuilder: (context, index) {
          return _buildTheHoaDon(dataTrangThaiHoaDon[index]);
        },
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _buildTheHoaDon(Map<String, dynamic> hoaDon) {
    IconData getIconByStatus() {
      switch (hoaDon['trangThai']) {
        case 1: // Đã thanh toán
          return Icons.check_circle;
        case 0: // Chưa thanh toán
          return Icons.warning;
        case -1: // Chờ xác nhận
          return Icons.hourglass_empty;
        case 2: // Chờ cập nhật điện nước
          return Icons.edit_note;
        default:
          return Icons.help_outline;
      }
    }

    Color getColorByStatus() {
      switch (hoaDon['trangThai']) {
        case 1: // Đã thanh toán
          return Colors.green[600]!;
        case 0: // Chưa thanh toán
          return Colors.red[600]!;
        case -1: // Chờ xác nhận
          return Colors.orange[600]!;
        case 2: // Chờ cập nhật điện nước
          return Colors.blue[600]!;
        default:
          return Colors.grey[600]!;
      }
    }

    Color getBackgroundColorByStatus() {
      switch (hoaDon['trangThai']) {
        case 1: // Đã thanh toán
          return Colors.green[50]!;
        case 0: // Chưa thanh toán
          return Colors.red[50]!;
        case -1: // Chờ xác nhận
          return Colors.orange[50]!;
        case 2: // Chờ cập nhật điện nước
          return Colors.blue[50]!;
        default:
          return Colors.grey[50]!;
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.all(16),
      leading: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: getBackgroundColorByStatus(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(getIconByStatus(), color: getColorByStatus(), size: 20),
      ),
      title: Text(
        hoaDon['trangThai'] == 1
            ? 'Hóa đơn đã thanh toán'
            : hoaDon['trangThai'] == 0
            ? 'Hóa đơn chưa thanh toán'
            : hoaDon['trangThai'] == -1
            ? 'Hoá đơn chờ xác nhận'
            : 'Hóa đơn chờ cập nhật điện nước',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${hoaDon['soluong']} hóa đơn',
          style: TextStyle(
            color:
                hoaDon['trangThai'] == 1
                    ? Colors.green[600]
                    : hoaDon['trangThai'] == 0
                    ? Colors.red[600]
                    : hoaDon['trangThai'] == -1
                    ? Colors.orange[600]
                    : Colors.blue[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
