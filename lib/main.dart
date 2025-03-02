import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý khách thuê trọ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý khách thuê trọ')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Dashboard'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.apartment),
              title: Text('Quản lý cơ sở & phòng'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Quản lý khách thuê'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Quản lý hóa đơn'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Trò chuyện với khách thuê'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Chào mừng đến với hệ thống quản lý khách thuê trọ!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class PropertyManagementScreen extends StatelessWidget {
  final List<String> properties = ['Cơ sở 1', 'Cơ sở 2', 'Cơ sở 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý cơ sở & phòng')),
      body: ListView.builder(
        itemCount: properties.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(properties[index]),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          RoomManagementScreen(property: properties[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RoomManagementScreen extends StatefulWidget {
  final String property;
  RoomManagementScreen({required this.property});

  @override
  _RoomManagementScreenState createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  List<String> rooms = ['Phòng 101', 'Phòng 102', 'Phòng 103'];

  void _showRoomDialog({String? existingRoom, int? index}) {
    TextEditingController roomController = TextEditingController(
      text: existingRoom,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingRoom == null ? 'Thêm phòng' : 'Chỉnh sửa phòng'),
          content: TextField(
            controller: roomController,
            decoration: InputDecoration(labelText: 'Tên phòng'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (roomController.text.isNotEmpty) {
                  setState(() {
                    if (existingRoom == null) {
                      rooms.add(roomController.text);
                    } else if (index != null) {
                      rooms[index] = roomController.text;
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách phòng - ${widget.property}')),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(rooms[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed:
                      () => _showRoomDialog(
                        existingRoom: rooms[index],
                        index: index,
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      rooms.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showRoomDialog(),
      ),
    );
  }
}
