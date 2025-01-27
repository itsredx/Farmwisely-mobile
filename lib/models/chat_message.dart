// TODO Implement this library.
   class ChatMessage {
      final String sender;
       final String text;
      final String? timeStamp; //making it nullable
      ChatMessage({required this.sender, required this.text, this.timeStamp});

       Map<String, dynamic> toJson() {
        return {
           'sender': sender,
           'text': text,
          };
       }
       factory ChatMessage.fromJson(Map<String, dynamic> json) {
         return ChatMessage(
             sender: json['sender'],
             text: json['text'],
             timeStamp: json['timestamp']
          );
       }
     }