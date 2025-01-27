// TODO Implement this library.
class ChatResponse {
         final String response;
         ChatResponse({
             required this.response,
     });
     factory ChatResponse.fromJson(Map<String, dynamic> json) {
         return ChatResponse(
             response: json['response']
         );
      }
    }