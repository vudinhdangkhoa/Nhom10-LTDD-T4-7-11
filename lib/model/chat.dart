class Chat {
  final String name;
  final String lastMessage;
  final String time;
  final List<Message> messages;

  Chat({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.messages,
  });
}

class Message {
  final String sender;
  final String content;
  final DateTime timestamp;

  Message({
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}
