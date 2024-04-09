import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  ChatDetailScreenState createState() => ChatDetailScreenState();
}

class ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  late WebSocketChannel _channel;
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    // Establish WebSocket connection
    final wsUrl = Uri.parse('ws://127.0.0.1:8080/ws');
    _channel = WebSocketChannel.connect(wsUrl);
    _channel.stream.listen((message) {
      setState(() {
        _messages.add(Message(text: message, isSent: false));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageWidget(message: _messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      _channel.sink.add(message);
      _messages.add(Message(text: message, isSent: true));
      _messageController.clear();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}

class Message {
  final String text;
  final bool isSent;

  Message({required this.text, required this.isSent});
}

class MessageWidget extends StatelessWidget {
  final Message message;

  const MessageWidget({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Align(
        alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: message.isSent ? Colors.blue : Colors.grey, 
            borderRadius: BorderRadius.circular(8.0)
          ),
          child: Text(
            message.text,
            style: const TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

