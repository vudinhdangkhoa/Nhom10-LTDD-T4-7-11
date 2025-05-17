import 'package:flutter/material.dart';
import '../../model/hoadon.dart';

class QLHoaDon extends StatelessWidget {
  final List<Invoice> invoices = [
    Invoice(
      id: '001',
      room: 'Phòng 101',
      amount: '2,000,000',
      status: 'Đã thanh toán',
    ),
    Invoice(
      id: '002',
      room: 'Phòng 102',
      amount: '1,800,000',
      status: 'Chưa thanh toán',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý hóa đơn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: ListTile(
                title: Text(
                  invoice.room,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Số tiền: ${invoice.amount} - ${invoice.status}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Icon(Icons.arrow_forward, color: Colors.blue),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvoiceDetailPage(invoice: invoice),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class InvoiceDetailPage extends StatelessWidget {
  final Invoice invoice;

  InvoiceDetailPage({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết hóa đơn')),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 400,
          child: Card(
            margin: EdgeInsets.only(right: 10, left: 10),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mã hóa đơn: ${invoice.id}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Phòng: ${invoice.room}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Số tiền: ${invoice.amount}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Trạng thái: ${invoice.status}",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
