import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/coso.dart';
import '../../model/phong.dart';

class ChiTietPhong extends StatefulWidget {
  final int idPhong;
  const ChiTietPhong({Key? key, required this.idPhong}) : super(key: key);

  @override
  _ChiTietPhongState createState() => _ChiTietPhongState();
}

class _ChiTietPhongState extends State<ChiTietPhong> {
  late int idPhong;
  late String tenPhong;
  late int soLuong;
  late List<Map<String, dynamic>> khachThueList = [];
  String erroMessage = "";
  bool isLoading = true;
  String getUrl() {
    if (kIsWeb) {
      return 'http://localhost:5167';
    }
    return 'http://10.0.2.2:5167';
  }

  Future<void> getInfoPhong() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${getUrl()}/api/QLCoSoVaPhong/getInfoPhong/${widget.idPhong}",
        ),
        headers: {"Content-Type": "application/json"},
      );
      await Future.delayed(Duration(seconds: 2));
      print(response.statusCode);
      print(widget.idPhong);
      if (response.statusCode == 200) {
        final resulft = jsonDecode(response.body);
        print(resulft);
        List<dynamic> data = resulft['khachHangs'];
        khachThueList.clear();

        if (data.isEmpty) {
          setState(() {
            idPhong = resulft['idPhong'];
            tenPhong = resulft['tenPhong'];
            soLuong = resulft['soLuong'];
            isLoading = false;
            erroMessage = "Không có khách nào";
          });
        } else {
          setState(() {
            idPhong = resulft['idPhong'];
            tenPhong = resulft['tenPhong'];
            soLuong = resulft['soLuong'];
            khachThueList.clear();
            List<Map<String, dynamic>> phonglst =
                data.map((item) => item as Map<String, dynamic>).toList();
            for (Map<String, dynamic> item in phonglst) {
              khachThueList.add(item);
            }
            erroMessage = "";
            isLoading = false;
          });
        }

        print(tenPhong);
        print(soLuong);
        print(khachThueList);
      } else {
        if (response.statusCode == 400) {
          setState(() {
            erroMessage = "Phòng không tồn tại";
            isLoading = false;
          });
        } else {
          setState(() {
            erroMessage = "Lỗi không xác định";
            isLoading = false;
          });
        }
      }
    } catch (e) {}
  }

  void initState() {
    super.initState();
    // Gọi API để lấy danh sách phòng
    getInfoPhong();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết phòng")),

      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tên phòng: $tenPhong",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Số lượng: $soLuong người"),
                      SizedBox(height: 20),
                      Text(
                        "Danh sách khách hàng:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child:
                            erroMessage.isEmpty
                                ? ListView.builder(
                                  itemCount: khachThueList.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      elevation: 4.0,
                                      margin: EdgeInsets.only(bottom: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Thông tin khách hàng',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              columns: [
                                                DataColumn(
                                                  label: Text(
                                                    'Tên',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Số điện thoại',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Ngày đến',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              rows: [
                                                DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Text(
                                                        khachThueList[index]['tenKh'],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        khachThueList[index]['sdt'],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        khachThueList[index]['ngayDen'],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                                : Center(child: Text(erroMessage)),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
