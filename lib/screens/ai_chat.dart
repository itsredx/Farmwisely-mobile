// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_final_fields, use_build_context_synchronously, unused_field, unused_local_variable

import 'dart:async'; // Import for Timer
import 'dart:convert';
import 'package:farmwisely/models/farm_profile_model.dart';
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:farmwisely/models/chat_history.dart';
import 'package:farmwisely/models/chat_message.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // For scrolling to bottom
  final ValueNotifier<List<ChatMessage>> _messagesNotifier = ValueNotifier([]);
  final ValueNotifier<String?> _currentChatTitleNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isThinkingNotifier = ValueNotifier(false);
  final ValueNotifier<List<ChatHistory>> _chatHistoriesNotifier =
      ValueNotifier([]);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isNewChat = true;
  final List<String> _suggestions = [
    'How to grow tomato?',
    'How to grow beans?',
    'How to grow maize?',
    'How to grow mango?',
  ]; // List of suggestions
  final FocusNode _textFieldFocus =
      FocusNode(); // Create a FocusNode for the text field
  String? _token;
  int? _userId;
  int? _farmId;
  FarmProfileModel? _farmProfile;

  // --- Timer state for typing animation ---
  Timer? _typingTimer;
  // --- End Timer state ---

  void _showError(String message, String details) {
    // Cancel timer if an error occurs during potential typing
    _typingTimer?.cancel();
    if (!mounted) return; // Check mount status
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('$message\nDetails: $details'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadToken();

     // Scroll to bottom when messages change
     _messagesNotifier.addListener(_scrollToBottom);
  }

  // --- Scroll to Bottom ---
   void _scrollToBottom() {
     // Add a small delay to allow the UI to build before scrolling
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (_scrollController.hasClients) {
         _scrollController.animateTo(
           _scrollController.position.maxScrollExtent,
           duration: const Duration(milliseconds: 300),
           curve: Curves.easeOut,
         );
       }
     });
   }
  // --- End Scroll to Bottom ---

  @override
  void dispose() {
     // Remove listener to prevent memory leaks
     _messagesNotifier.removeListener(_scrollToBottom);
    _textFieldFocus.dispose();
    _typingTimer?.cancel(); // Cancel timer if active when screen is disposed
    _controller.dispose();
    _scrollController.dispose(); // Dispose scroll controller
     _messagesNotifier.dispose();
     _currentChatTitleNotifier.dispose();
     _isThinkingNotifier.dispose();
     _chatHistoriesNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? userId = prefs.getInt('userId');
    if (token != null && userId != null) {
      if (!mounted) return;
      setState(() {
        _token = token;
        _userId = userId;
      });
       // Await loading profile first to get farmId
      await _loadFarmProfile();
      // Then load chat histories
      await _loadChatHistories();
    } else {
      // Handle case where user is not logged in? Navigate back?
       _showError("Authentication Error", "Please log in again.");
        // Optionally: Navigator.of(context).pop();
    }
  }

  Future<void> _loadFarmProfile() async {
     if (_token == null) return; // Ensure token is loaded
    try {
      final response = await http.get(
        Uri.parse('https://devred.pythonanywhere.com/api/farms/'),
        headers: {
          'Authorization': 'Token $_token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> farmDataList = json.decode(response.body);
        if (farmDataList.isNotEmpty) {
          Map<String, dynamic> decodedData = farmDataList[0];
          _farmProfile = FarmProfileModel.fromJson(decodedData);

          final int? loadedFarmId = _farmProfile?.id;
          setState(() {
            _farmId = loadedFarmId; // Update state
          });

          if (_farmId != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('farmId', _farmId!);
          } else {
             _showError('Farm ID Error', 'Could not retrieve farm ID from the loaded profile.');
          }
        } else {
          // Only show error if farmId isn't already loaded from prefs maybe?
           // Or prompt user to create a farm profile
           print('No farm profiles associated with this user.');
          // _showError('No Farms Found', 'No farm profiles associated with this user. Please create one.');
        }
      } else {
        _showError('Error loading farm data', response.body);
      }
    } catch (e) {
       if (!mounted) return;
      _showError('Error loading farm data', e.toString());
    }
  }

  Future<void> _loadChatHistories() async {
    if (_token == null) return;
    try {
      final response = await http.get(
        Uri.parse('https://devred.pythonanywhere.com/api/chat/'),
        headers: {
          'Authorization': 'Token $_token',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> decodedList = json.decode(response.body);
        final List<ChatHistory> loadedHistories =
            decodedList.map((json) => ChatHistory.fromJson(json)).toList();
        _chatHistoriesNotifier.value = loadedHistories;
      } else {
        // Don't show error if it's just empty, maybe 404 is ok if no history?
         if (response.statusCode != 404) {
            _showError('Error loading chat histories', response.body);
         }
      }
    } catch (e) {
       if (!mounted) return;
      _showError('Error loading chat histories', e.toString());
    }
  }

  Future<void> _sendMessage() async {
    // Cancel any previous typing animation
    _typingTimer?.cancel();

    if (_controller.text.trim().isNotEmpty && !_isThinkingNotifier.value) {
      final String userMessage = _controller.text.trim();

      // Check for Farm ID *before* modifying state
      if (_farmId == null) {
        _showError('Farm Setup Needed',
            'Please ensure you have created a farm profile before chatting.');
        return; // Don't proceed
      }

      // Add user message immediately
      final userChatMessage = ChatMessage(
          sender: 'user',
          text: userMessage,
          timeStamp: DateTime.now().toIso8601String());
      // Create new list and update notifier
      final currentMessages = List<ChatMessage>.from(_messagesNotifier.value)
        ..add(userChatMessage);
      _messagesNotifier.value = currentMessages;

      // Start thinking indicator & clear text field
      _isThinkingNotifier.value = true;
      final String messageToSend = _controller.text.trim(); // Capture before clearing
      _controller.clear();
      _textFieldFocus.unfocus(); // Hide keyboard


      // Determine chat title (use first ~30 chars of message if new)
      final String title = _isNewChat
          ? messageToSend.substring(0, messageToSend.length > 30 ? 30 : messageToSend.length) + '...'
          : _currentChatTitleNotifier.value!;

      try {
        final response = await http.post(
          // Use the corrected URL with 'view/' prefix
          Uri.parse(
              'https://devred.pythonanywhere.com/api/chat/view/$_farmId/'),
          headers: {
            'Authorization': 'Token $_token',
            'Content-Type': 'application/json',
          },
          body: json.encode(
              {'message': messageToSend, 'chat_title': title}), // Send original message
        );

        if (!mounted) return; // Check mount status after await

        if (response.statusCode == 200) {
          final decodedData = json.decode(response.body);

          // --- Start Typing Animation Logic ---
          // 1. Extract the FULL AI response text
          // !!! IMPORTANT: Adjust this based on your actual API response !!!
          // Find the last message in the 'messages' list and get its 'text'
          final List<dynamic> messagesList = decodedData['messages'] ?? [];
          final String fullAiResponseText = messagesList.isNotEmpty
              ? (messagesList.last['text'] ?? "Sorry, I couldn't get a response.")
              : "Sorry, no message received.";
          // !!! END IMPORTANT ADJUSTMENT !!!

          // 2. Add a placeholder message for the AI
          final aiPlaceholderMessage = ChatMessage(
              sender: 'ai',
              text: '▋', // Initial blinking cursor
              timeStamp: DateTime.now().toIso8601String()); // Use current timestamp

          // Add placeholder immediately (create new list)
          final messagesWithPlaceholder = List<ChatMessage>.from(_messagesNotifier.value)
            ..add(aiPlaceholderMessage);
          _messagesNotifier.value = messagesWithPlaceholder;

          // 3. Turn off "thinking" indicator *before* starting typing
          _isThinkingNotifier.value = false;

          // 4. Start the timer
          int charIndex = 0;
          const typingSpeed = Duration(milliseconds: 35); // Adjust speed

          _typingTimer = Timer.periodic(typingSpeed, (timer) {
            if (!mounted) { timer.cancel(); return; }

            if (charIndex < fullAiResponseText.length) {
              charIndex++;
              String currentTypedText = fullAiResponseText.substring(0, charIndex);

              // Create updated message object with cursor
              final updatedAiMessage = ChatMessage(
                  sender: 'ai',
                  text: '$currentTypedText▋',
                  timeStamp: aiPlaceholderMessage.timeStamp); // Keep original timestamp

              // Replace placeholder in a *new* list
              final updatedMessages = List<ChatMessage>.from(_messagesNotifier.value);
              if (updatedMessages.isNotEmpty && updatedMessages.last.sender == 'ai') {
                updatedMessages[updatedMessages.length - 1] = updatedAiMessage;
                _messagesNotifier.value = updatedMessages; // Update notifier
              } else {
                 print("Error: AI placeholder message not found for update.");
                 timer.cancel(); // Stop timer if placeholder is missing
              }
            } else {
              // Typing finished
              timer.cancel();
              if (!mounted) return;

              // Final message without cursor
              final finalAiMessage = ChatMessage(
                  sender: 'ai',
                  text: fullAiResponseText,
                  timeStamp: aiPlaceholderMessage.timeStamp);

              // Update list one last time
              final finalMessages = List<ChatMessage>.from(_messagesNotifier.value);
              if (finalMessages.isNotEmpty && finalMessages.last.sender == 'ai') {
                 finalMessages[finalMessages.length - 1] = finalAiMessage;
                _messagesNotifier.value = finalMessages;
              }

              // Update overall chat state *after* animation
              _currentChatTitleNotifier.value = decodedData['title'] ?? title;
              _isNewChat = false;
              // Refresh history list to potentially show the new/updated chat
              _loadChatHistories();
            }
          });
          // --- End Typing Animation Logic ---

        } else {
           _isThinkingNotifier.value = false; // Stop thinking on error
          _showError("API Error (${response.statusCode})", response.body);
        }
      } catch (e) {
        if (!mounted) return;
        _isThinkingNotifier.value = false; // Stop thinking on exception
        _showError('Network/Request Error:', e.toString());
      }
    }
  }

  void _handleDrawerItemTap(int chatHistoryId) async {
    _typingTimer?.cancel(); // Cancel typing if user selects history
    try {
      // Use GET for fetching existing history
      final response = await http.get(
        Uri.parse(
            'https://devred.pythonanywhere.com/api/chat/$chatHistoryId/'),
        headers: {'Authorization': 'Token $_token'},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        ChatHistory chatHistory = ChatHistory.fromJson(decodedData);
        _messagesNotifier.value = [...chatHistory.messages];
        _currentChatTitleNotifier.value = chatHistory.title;
        _isNewChat = false;
        Navigator.pop(context); // Close drawer
      } else {
        _showError('Error loading chat', response.body);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error loading chat', e.toString());
    }
  }

  void _clearCurrentChat() {
    _typingTimer?.cancel(); // Cancel typing on new chat
    _messagesNotifier.value = [];
    _currentChatTitleNotifier.value = null;
    _isNewChat = true;
     // Optionally refocus text field
     // FocusScope.of(context).requestFocus(_textFieldFocus);
  }

  void _setSuggestionText(String text) {
    _controller.text = text;
    _textFieldFocus.requestFocus();
  }


  Future<void> _deleteAllChatHistories() async {
     _typingTimer?.cancel(); // Cancel typing if deleting history
    try {
      List<ChatHistory> currentHistories = List.from(_chatHistoriesNotifier.value);
      bool errorsOccurred = false;
      for (var chat in currentHistories) {
         if (!mounted) return; // Check before each delete call
        final response = await http.delete(
          Uri.parse('https://devred.pythonanywhere.com/api/chat/${chat.id}/'),
          headers: {'Authorization': 'Token $_token'},
        );
         if (!mounted) return; // Check after each delete call
        if (response.statusCode != 204) {
           errorsOccurred = true;
          _showError('Error deleting chat ${chat.id}', response.body);
           // Maybe break or continue? Depends on desired behavior. Let's continue.
        }
      }

      if (!mounted) return;

      // Update state only after attempting all deletes
      if (!errorsOccurred) {
         _chatHistoriesNotifier.value = []; // Clear local list if all succeeded
      } else {
         _loadChatHistories(); // Reload from server if errors occurred
      }
      // Clear current chat regardless
       _messagesNotifier.value = [];
       _currentChatTitleNotifier.value = null;
       _isNewChat = true;
    } catch (e) {
      if (!mounted) return;
      _showError('Error during delete operation', e.toString());
       _loadChatHistories(); // Reload on exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _clearCurrentChat();
            Navigator.pop(context);
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Farm Advisor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Ask me anything about your farm',
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Start new chat',
            onPressed: _clearCurrentChat, // Use method directly
          ),
          IconButton(
            onPressed: () {
              // Ensure keyboard is hidden before opening drawer
              FocusScope.of(context).unfocus();
              // Refresh history before opening, optional but good practice
               _loadChatHistories();
              _scaffoldKey.currentState!.openEndDrawer();
            },
            icon: const Icon(Icons.history),
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      endDrawer: Drawer(
        surfaceTintColor: AppColors.background,
        child: Column( // Use Column for better structure
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
                children: [
                  const Text(
                    'History',
                    style: TextStyle(color: AppColors.grey, fontSize: 24),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Color.fromRGBO(194, 84, 69, 1),
                    ),
                    onPressed: () async { // Make async
                      Navigator.pop(context); // Close drawer *before* deleting
                      await _deleteAllChatHistories(); // Await deletion
                    },
                    tooltip: 'Delete All chats',
                  ),
                ],
              ),
            ),
             // Make the list scrollable and take remaining space
            Expanded(
              child: ValueListenableBuilder<List<ChatHistory>>(
                  valueListenable: _chatHistoriesNotifier,
                  builder: (context, chatHistories, child) {
                    if (chatHistories.isEmpty) {
                       return const Center(
                         child: Text("No chat history yet.", style: TextStyle(color: AppColors.grey)),
                       );
                    }
                    // Sort chat histories in reverse order (Newest at the top)
                    final reversedHistories = chatHistories.reversed.toList();
                    return ListView.builder( // Use ListView.builder for efficiency
                       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Add padding
                       itemCount: reversedHistories.length,
                       itemBuilder: (context, index) {
                          final history = reversedHistories[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0), // Spacing between items
                            child: ListTile(
                              leading: const Icon(
                                  Icons.chat_bubble_outline_outlined, color: AppColors.grey),
                              title: Text(
                                 history.title,
                                 style: const TextStyle(color: AppColors.grey),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                                 ),
                              tileColor: AppColors.primary,
                              selectedTileColor: AppColors.secondary.withOpacity(0.3), // Color when selected
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: () {
                                _handleDrawerItemTap(history.id);
                                // Don't pop here, _handleDrawerItemTap does on success
                              },
                            ),
                          );
                       },
                    );
                  }),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector( // Add gesture detector to dismiss keyboard on tap
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                controller: _scrollController, // Assign scroll controller
                reverse: true, // Keep this true to stick to bottom
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ValueListenableBuilder<List<ChatMessage>>(
                    valueListenable: _messagesNotifier,
                    builder: (context, messages, child) {
                      // Show suggestions only if messages are empty AND not thinking
                      if (messages.isEmpty && !_isThinkingNotifier.value) {
                        return _buildSuggestions();
                      }
                      // Otherwise, show the message list
                      return _buildMessageList(messages);
                    },
                  ),
                ),
              ),
            ),
          ),
          // Show thinking indicator below messages only when actually thinking
          ValueListenableBuilder<bool>(
              valueListenable: _isThinkingNotifier,
              builder: (context, isThinking, child) {
                 return isThinking ? _buildThinkingIndicator() : const SizedBox.shrink();
              }
          ),
          // --- Input Field ---
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(24),
                color: AppColors.primary, // Ensure background matches
                child: TextField(
                  focusNode: _textFieldFocus,
                  controller: _controller,
                   style: const TextStyle(color: AppColors.grey), // Text color
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                     hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.7)), // Hint text color
                    suffixIcon: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: AppColors.secondary,
                        size: 30,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    // filled: true, // Already set via Material color
                    // fillColor: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets for Build Method ---
  Widget _buildSuggestions() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Takes less vertical space
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary,
            ),
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Increased padding
              child: Column(
                children: [
                  const Text(
                    'Suggestions',
                    style: TextStyle(fontSize: 20, color: AppColors.grey), // Adjusted style
                  ),
                  const SizedBox(height: 16),
                  ListView.separated( // Use separated for spacing
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestions.length,
                     separatorBuilder: (context, index) => const SizedBox(height: 8), // Spacing
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: double.infinity,
                        child: Material( // Use Material for splash effect
                           color: AppColors.secondary,
                           borderRadius: BorderRadius.circular(12),
                          child: InkWell( // Use InkWell for tap effect
                             borderRadius: BorderRadius.circular(12),
                             onTap: () {
                                _setSuggestionText(_suggestions[index]);
                             },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                              child: Text(
                                _suggestions[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 15, color: AppColors.grey), // Adjusted style
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
           // Add some padding below suggestions if needed
           const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    return Column(
      children: messages.map((message) {
        // Using index as part of key can help if timestamps are identical
         int index = messages.indexOf(message);
         Key messageKey = ValueKey('${message.timeStamp}-$index'); // More unique key

        return Align(
          key: messageKey, // Assign key
          alignment: message.sender == 'user'
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: message.sender == 'user'
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.sender == 'ai') // AI Avatar on the left
                const CircleAvatar(
                  radius: 15, // Consistent size
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
              Flexible(
                child: Container(
                   // Add max width constraints if needed
                   // constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  margin: message.sender == 'user'
                      ? const EdgeInsets.fromLTRB(50, 4, 4, 4) // Adjusted margins
                      : const EdgeInsets.fromLTRB(4, 4, 50, 4), // Adjusted margins
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0), // Adjusted padding
                  decoration: BoxDecoration(
                    color: message.sender == 'user'
                        ? AppColors.primary
                        : AppColors.secondary,
                    borderRadius: BorderRadius.circular(16), // Slightly more rounded
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(fontSize: 16, color: AppColors.grey), // Set text color
                  ),
                ),
              ),
              if (message.sender == 'user') // User Avatar on the right
                const CircleAvatar(
                  radius: 15, // Consistent size
                  backgroundColor: AppColors.primary,
                  // TODO: Replace with actual user profile image if available
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
            ],
          ),
        );
      }).toList(), // Don't forget toList() when using map inside Column children
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 4.0), // Adjust padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center, // Align vertically
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Text(
            'AI is thinking',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(width: 4),
          LoadingBouncingLine.circle(
            size: 16,
            backgroundColor: AppColors.secondary,
            borderColor: AppColors.primary,
            borderSize: 2, // Slightly thinner border
          ),
        ],
      ),
    );
  }
  // --- End Helper Widgets ---

} // End _AiChatScreenState