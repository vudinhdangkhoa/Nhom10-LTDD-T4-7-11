import 'package:flutter/material.dart';

import 'model/coso.dart';
import 'model/phong.dart';

class DSCoSoVaPhong extends StatelessWidget {
  final List<Property> properties = [
    Property(
      name: 'Cơ sở 1',
      rooms: [
        Room(name: 'Phòng 101', status: 'Đã cho thuê', tenants: 2),
        Room(name: 'Phòng 102', status: 'Còn trống', tenants: 0),
        Room(name: 'Phòng 103', status: 'Đã cho thuê', tenants: 1),
      ],
    ),
    Property(
      name: 'Cơ sở 2',
      rooms: [
        Room(name: 'Phòng 201', status: 'Còn trống', tenants: 0),
        Room(name: 'Phòng 202', status: 'Đã cho thuê', tenants: 3),
      ],
    ),
    Property(
      name: 'Cơ sở 3',
      rooms: [
        Room(name: 'Phòng 301', status: 'Đã cho thuê', tenants: 1),
        Room(name: 'Phòng 302', status: 'Còn trống', tenants: 0),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý cơ sở & phòng')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(
                  property.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Số lượng phòng: ${property.rooms.length}'),
                trailing: Icon(Icons.arrow_forward, color: Colors.blue),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DSPhong(property: property),
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

class DSPhong extends StatelessWidget {
  final Property property;
  DSPhong({required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách phòng - ${property.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: property.rooms.length,
          itemBuilder: (context, index) {
            final room = property.rooms[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(
                  room.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  room.status == 'Đã cho thuê'
                      ? 'Đã cho thuê - Số lượng người: ${room.tenants}'
                      : 'Còn trống',
                  style: TextStyle(
                    color:
                        room.status == 'Đã cho thuê'
                            ? Colors.red
                            : Colors.green,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Thêm chức năng chỉnh sửa phòng
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Thêm chức năng xóa phòng
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Thêm chức năng thêm phòng
        },
      ),
    );
  }
}
