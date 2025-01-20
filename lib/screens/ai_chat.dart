import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Data models
class ChatMessage {
  final String sender;
  final String text;

  ChatMessage({required this.sender, required this.text});

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
    );
  }
}

class ChatHistory {
  final String title;
  final List<ChatMessage> messages;

  ChatHistory({required this.title, required this.messages});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      title: json['title'],
      messages: (json['messages'] as List<dynamic>)
          .map((messageJson) => ChatMessage.fromJson(messageJson))
          .toList(),
    );
  }
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
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
   final FocusNode _textFieldFocus = FocusNode();  // Create a FocusNode for the text field


  @override
  void initState() {
    super.initState();
    _loadChatHistories();
  }

  Future<void> _loadChatHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? chatHistoryString = prefs.getString('chatHistories');
    if (chatHistoryString != null) {
      final List<dynamic> decodedList = json.decode(chatHistoryString);
      final List<ChatHistory> loadedHistories = decodedList
          .map((json) => ChatHistory.fromJson(json))
          .toList();
      _chatHistoriesNotifier.value = loadedHistories;
    } else {
      _chatHistoriesNotifier.value = [];
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String chatHistoryString = json.encode(_chatHistoriesNotifier.value
        .map((history) => history.toJson())
        .toList());
    await prefs.setString('chatHistories', chatHistoryString);
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty && !_isThinkingNotifier.value) {
      final String userMessage = _controller.text.trim();
      _isThinkingNotifier.value = true;
      if (_messagesNotifier.value.isEmpty && _isNewChat) {
        _currentChatTitleNotifier.value = userMessage;
        _isNewChat = false;
      }
      _messagesNotifier.value = [
        ..._messagesNotifier.value,
        ChatMessage(sender: 'user', text: userMessage),
      ];
      _controller.clear();

      // Simulate AI response
      Future.delayed(const Duration(seconds: 5), () {
        _messagesNotifier.value = [
          ..._messagesNotifier.value,
          ChatMessage(sender: 'ai', text: 'This is an AI response.'),
        ];
        _isThinkingNotifier.value = false;
      });
    }
  }

  void _handleDrawerItemTap(String chatTitle) {
    if (_currentChatTitleNotifier.value != null) {
      _saveCurrentChat();
    }
    final chatHistory = _chatHistoriesNotifier.value
        .firstWhere((history) => history.title == chatTitle);
    _messagesNotifier.value = [...chatHistory.messages];
    _currentChatTitleNotifier.value = chatHistory.title;
    _isNewChat = false; // set the chat to existing chat when loading
    Navigator.pop(context);
  }

  Future<void> _saveCurrentChat() async {
    if (_messagesNotifier.value.isNotEmpty &&
        _currentChatTitleNotifier.value != null) {
      final chatHistory = _chatHistoriesNotifier.value.firstWhere(
          (history) => history.title == _currentChatTitleNotifier.value,
          orElse: () => ChatHistory(title: '', messages: []));
      if (chatHistory.title.isNotEmpty) {
        final index = _chatHistoriesNotifier.value.indexOf(chatHistory);
        _chatHistoriesNotifier.value[index] = ChatHistory(
            title: _currentChatTitleNotifier.value!,
            messages: _messagesNotifier.value);
      } else {
        _chatHistoriesNotifier.value = [
          ..._chatHistoriesNotifier.value,
          ChatHistory(
              title: _currentChatTitleNotifier.value!,
              messages: _messagesNotifier.value)
        ];
      }
      await _saveChatHistory();
    }
  }

  void _clearCurrentChat() {
    _saveCurrentChat();
    _messagesNotifier.value = [];
    _currentChatTitleNotifier.value = null;
    _isNewChat = true;
  }

  void _setSuggestionText(String text) {
    _controller.text = text; // Set the text field with the suggestion
     _textFieldFocus.requestFocus(); // Request focus on the text field
  }


  @override
  void dispose() {
    _textFieldFocus.dispose(); // Dispose of the focus node
    super.dispose();
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
            icon: Icon(Icons.add_circle_outline),
            tooltip: 'Start new chat',
            onPressed: () {
              _clearCurrentChat();
            },
          ),
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
            icon: const Icon(Icons.history),
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      endDrawer: Drawer(
        surfaceTintColor: AppColors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    onPressed: () {
                      _deleteAllChatHistories();
                      Navigator.pop(context); // Pop the drawer
                    },
                    tooltip: 'Delete All chats',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ValueListenableBuilder<List<ChatHistory>>(
                  valueListenable: _chatHistoriesNotifier,
                  builder: (context, chatHistories, child) {
                    // Sort chat histories in reverse order based on when added (Newest at the top)
                    final reversedHistories = chatHistories.reversed.toList();
                    return Column(
                      children: [
                        ...reversedHistories.map((history) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ListTile(
                              leading: const Icon(Icons.chat_bubble_outline_outlined),
                              title: Text(history.title),
                              tileColor: AppColors.primary,
                              selectedColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: () {
                                _handleDrawerItemTap(history.title);
                              },
                            ),
                          );
                        }),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ValueListenableBuilder<List<ChatMessage>>(
                    valueListenable: _messagesNotifier,
                    builder: (context, messages, child) {
                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.primary,
                                ),
                                width: 300,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                   child: Column(
                                   children: [
                                       const Text(
                                        'Suggestions',
                                         style: TextStyle(fontSize: 24),
                                         ),
                                        const SizedBox(height: 16),
                                      ListView.builder(
                                         shrinkWrap: true,
                                         physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _suggestions.length,
                                        itemBuilder: (context, index) {
                                           return SizedBox(
                                            width: double.infinity,
                                             child: Card(
                                              color: AppColors.secondary,
                                              surfaceTintColor: AppColors.secondary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                               child: ListTile(
                                                  title: Text(_suggestions[index], 
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 16),
                                                  maxLines: 2,
                                                  ),
                                                 onTap: () {
                                                 _setSuggestionText(_suggestions[index]);
                                                },
                                               ),
                                             ),
                                           );
                                        },
                                       ),
                                      ],
                                   ),
                                ),
                              ),
                                SizedBox(
                                height: 140,
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          ...messages.map((message) {
                            return Align(
                              alignment: message.sender == 'user'
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment: message.sender == 'user'
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (message.sender ==
                                      'ai') // AI Avatar on the left
                                    CircleAvatar(
                                      backgroundColor: AppColors.secondary,
                                      child:
                                          Icon(Icons.person, color: Colors.white),
                                    ),
                                  Flexible(
                                    child: Container(
                                      margin: message.sender == 'user'
                                          ? const EdgeInsets.fromLTRB(
                                              44, 4, 4, 4)
                                          : const EdgeInsets.fromLTRB(
                                              4, 4, 0, 4),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: message.sender == 'user'
                                            ? AppColors.primary
                                            : AppColors.secondary,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        message.text,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  if (message.sender ==
                                      'user') // User Avatar on the right
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      backgroundImage: AssetImage(
                                        'assets/images/profile.jpg',
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                          if (_isThinkingNotifier.value)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Text(
                                      'AI is thinking',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColors.grey),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    LoadingBouncingLine.circle(
                                      size: 16,
                                      backgroundColor: AppColors.secondary,
                                      borderColor: AppColors.primary,
                                      borderSize: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(24),
                child: TextField(
                   focusNode: _textFieldFocus,
                  controller: _controller,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
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
                    filled: true,
                    fillColor: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
   Future<void> _deleteAllChatHistories() async {
    _chatHistoriesNotifier.value = [];
     await _saveChatHistory(); // Update storage to have empty histories
    _messagesNotifier.value = []; // Clear current chat messages
    _currentChatTitleNotifier.value = null; // clear current chat title
    _isNewChat = true; // reset new chat flag
  }
}
/*
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<Map<String, String>> _messages = []; // List to hold chat messages
  final TextEditingController _controller = TextEditingController();
  bool _isThinking = false; // Tracks if AI is responding

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty && !_isThinking) {
      setState(() {
        _messages.add({'sender': 'user', 'text': _controller.text.trim()});
        _controller.clear();
        _isThinking = true; // Set thinking state to true
      });

      // Simulate AI response
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _messages.add({'sender': 'ai', 'text': 'This is an AI response.'});
          _isThinking = false; // Reset thinking state
        });
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
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
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer(); // Open the end drawer
            },
            icon: const Icon(Icons.history),
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      endDrawer: Drawer( // Add the end drawer widget
      surfaceTintColor: AppColors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              child: const Text(
                'History',
                style: TextStyle(color: AppColors.grey, fontSize: 24),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat),
                    title: const Text('Chat History 1'),
                    tileColor: AppColors.primary,
                    selectedColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      // Handle tap for Chat History 1
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                height: 4,
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Chat History 2'),
                tileColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  // Handle tap for Chat History 2
                  Navigator.pop(context);
                },
              ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Main content area with scrollable chat
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_messages.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.primary,
                              ),
                              width: 300,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Suggestions',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Card(
                                            color: AppColors.secondary,
                                            surfaceTintColor:
                                                AppColors.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'How to grow tomato?',
                                                style: TextStyle(fontSize: 16),
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Card(
                                            color: AppColors.secondary,
                                            surfaceTintColor:
                                                AppColors.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'How to grow beans?',
                                                style: TextStyle(fontSize: 16),
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Card(
                                            color: AppColors.secondary,
                                            surfaceTintColor:
                                                AppColors.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'How to grow maize?',
                                                style: TextStyle(fontSize: 16),
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Card(
                                            color: AppColors.secondary,
                                            surfaceTintColor:
                                                AppColors.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'How to grow mango?',
                                                style: TextStyle(fontSize: 16),
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 140,
                            ),
                          ],
                        ),
                      ),
                    ..._messages.map((message) {
                      return Align(
                        alignment: message['sender'] == 'user'
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: message['sender'] == 'user'
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message['sender'] ==
                                'ai') // AI Avatar on the left
                              CircleAvatar(
                                backgroundColor: AppColors.secondary,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            Flexible(
                              child: Container(
                                margin: message['sender'] == 'user'
                                    ? const EdgeInsets.fromLTRB(44, 4, 4, 4)
                                    : const EdgeInsets.fromLTRB(4, 4, 0, 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: message['sender'] == 'user'
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message['text']!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            if (message['sender'] ==
                                'user') // User Avatar on the right
                              CircleAvatar(
                                backgroundColor: AppColors.primary,
                                backgroundImage: AssetImage(
                                  'assets/images/profile.jpg',
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    if (_isThinking)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Text(
                                'AI is thinking',
                                style: TextStyle(
                                    fontSize: 14, color: AppColors.grey),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              LoadingBouncingLine.circle(
                                size: 16,
                                backgroundColor: AppColors.secondary,
                                borderColor: AppColors.primary,
                                borderSize: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // TextField at the bottom
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(24),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
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
                    filled: true,
                    fillColor: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/
