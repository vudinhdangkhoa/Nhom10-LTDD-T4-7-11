import 'package:flutter/material.dart';

class TenantManagementScreen extends StatefulWidget {
  @override
  _TenantManagementScreenState createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen> {
  final List<Map<String, dynamic>> tenants = [
    {'name': 'Nguyễn Văn A', 'room': '101', 'status': 'Đang thuê'},
    {'name': 'Trần Thị B', 'room': '102', 'status': 'Đã rời đi'},
    {'name': 'Lê Văn C', 'room': '103', 'status': 'Đang thuê'},
  ];

  String _searchQuery = "";

  List<Map<String, dynamic>> get _filteredTenants {
    if (_searchQuery.isEmpty) {
      return tenants;
    }
    return tenants
        .where((tenant) => tenant['name'].toLowerCase().contains(_searchQuery))
        .toList();
  }

  void _showTenantDialog({Map<String, dynamic>? tenant}) {
    TextEditingController nameController = TextEditingController(
      text: tenant?['name'] ?? '',
    );
    TextEditingController roomController = TextEditingController(
      text: tenant?['room'] ?? '',
    );
    String status = tenant?['status'] ?? 'Đang thuê';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            tenant == null ? 'Thêm khách thuê' : 'Chỉnh sửa khách thuê',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Họ tên'),
              ),
              TextField(
                controller: roomController,
                decoration: InputDecoration(labelText: 'Phòng'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: 'Trạng thái'),
                items:
                    ['Đang thuê']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  status = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (tenant == null) {
                    tenants.add({
                      'name': nameController.text,
                      'room': roomController.text,
                      'status': status,
                    });
                  } else {
                    tenant['name'] = nameController.text;
                    tenant['room'] = roomController.text;
                    tenant['status'] = status;
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _markTenantAsLeft(int index) {
    setState(() {
      tenants[index]['status'] = 'Đã rời đi';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý khách thuê')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Tìm kiếm theo tên',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTenants.length,
              itemBuilder: (context, index) {
                final tenant = _filteredTenants[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(tenant['name']),
                    subtitle: Text("Phòng: ${tenant['room']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tenant['status'],
                          style: TextStyle(
                            color:
                                tenant['status'] == 'Đang thuê'
                                    ? const Color.fromARGB(255, 96, 196, 100)
                                    : Colors.red,
                          ),
                        ),
                        if (tenant['status'] == 'Đang thuê')
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => _markTenantAsLeft(index),
                          ),
                      ],
                    ),
                    onTap: () => _showTenantDialog(tenant: tenant),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTenantDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
