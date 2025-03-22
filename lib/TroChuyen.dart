import 'package:flutter/material.dart';

import 'model/chat.dart';

class TrangChat extends StatelessWidget {
  final List<Chat> chats = [
    Chat(
      name: "Nguyễn Văn A",
      lastMessage: "Xin chào!",
      time: "10:15",
      messages: [
        Message(
          sender: "Nguyễn Văn A",
          content: "Xin chào!",
          timestamp: DateTime.now().subtract(Duration(minutes: 10)),
        ),
      ],
    ),
    Chat(
      name: "Trần Thị B",
      lastMessage: "Phòng bị hư vòi nước",
      time: "08:30",
      messages: [
        Message(
          sender: "Trần Thị B",
          content: "Phòng bị hư vòi nước",
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trò chuyện')),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: CircleAvatar(child: Text(chat.name[0])),
              title: Text(
                chat.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(chat.lastMessage),
              trailing: Text(chat.time),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChiTietChat(chat: chat),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ChiTietChat extends StatefulWidget {
  final Chat chat;

  ChiTietChat({required this.chat});

  @override
  _ChiTietChatState createState() => _ChiTietChatState();
}

class _ChiTietChatState extends State<ChiTietChat> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        widget.chat.messages.add(
          Message(
            sender: "Bạn",
            content: _messageController.text,
            timestamp: DateTime.now(),
          ),
        );
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trò chuyện với ${widget.chat.name}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.chat.messages.length,
              itemBuilder: (context, index) {
                final message = widget.chat.messages[index];
                return ListTile(
                  title: Text(message.content),
                  subtitle: Text(message.sender),
                  trailing:
                      message.sender == "Bạn"
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Nhập tin nhắn',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
