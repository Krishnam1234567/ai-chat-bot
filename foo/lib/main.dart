import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChatScreen(),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messages[index];
                return ListTile(
                  title: Text(message['text']!,
                      style: TextStyle(
                          color: message['isUser']!
                              ? Colors.blue
                              : Colors.black)),
                  subtitle: message['isUser']!
                      ? const Text("You")
                      : const Text("Bot"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      chatProvider.sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  List<Map<String, dynamic>> messages = [];
  final String apiKey = "AIzaSyC6ah8UmAWHmf-H0BUTxvERT5v5hEgbLz0"; // Replace with your key

  Future<void> sendMessage(String userMessage) async {
    messages.add({'text': userMessage, 'isUser': true});
    notifyListeners();

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": [
          {"role": "system", "content": "You are a helpful assistant."},
          {"role": "user", "content": userMessage}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final botReply = data['choices'][0]['message']['content'];
      messages.add({'text': botReply, 'isUser': false});
      notifyListeners();
    } else {
      messages.add({'text': "Error: ${response.reasonPhrase}", 'isUser': false});
      notifyListeners();
    }
  }
}
