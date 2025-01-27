import 'package:farmwisely/models/chat_message.dart';

class ChatHistory {
    final String title;
    final List<ChatMessage> messages;
    final int id;
    ChatHistory({required this.title, required this.messages, required this.id});
       factory ChatHistory.fromJson(Map<String, dynamic> json) {
           return ChatHistory(
             title: json['title'],
               messages: (json['messages'] as List<dynamic>)
                    .map((messageJson) => ChatMessage.fromJson(messageJson))
                   .toList(),
               id: json['id']
            );
        }
    Map<String, dynamic> toJson() { // ADD THIS METHOD
            return {
                'title': title,
                'messages': messages.map((message) => message.toJson()).toList(),
               'id': id,
            };
      }
  }