// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_final_fields, use_build_context_synchronously

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
  // ignore: unused_field
  int? _userId;
  int? _farmId;
  FarmProfileModel? _farmProfile;

  void _showError(String message, String details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('$message\nDetails: $details'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? userId = prefs.getInt('userId');
    if (token != null && userId != null) {
      setState(() {
        _token = token;
        _userId = userId;
        _loadFarmProfile();
        _loadChatHistories();
      });
    }
  }

Future<void> _loadFarmProfile() async {
  try {
    final response = await http.get(
      Uri.parse('https://devred.pythonanywhere.com/api/farms/'),
      headers: {
        'Authorization': 'Token $_token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> farmDataList = json.decode(response.body);
      if (farmDataList.isNotEmpty) {
        Map<String, dynamic> decodedData = farmDataList[0];
        _farmProfile = FarmProfileModel.fromJson(decodedData);

        // ----> Get the ID directly from the loaded profile <----
        setState(() { // Use setState if UI depends on _farmId immediately
           _farmId = _farmProfile?.id; // Assuming FarmProfileModel has an 'id' property of type int?
        });


        // ----> Optional: Save to SharedPreferences if needed elsewhere <----
        if (_farmId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('farmId', _farmId!); // Save the loaded ID
        } else {
           _showError('Farm ID Error', 'Could not retrieve farm ID from the loaded profile.');
        }

      } else {
        _showError('No Farms Found', 'No farm profiles associated with this user.');
      }
    } else {
      _showError('Error loading farm data', response.body);
    }
  } catch (e) {
    _showError('Error loading farm data', e.toString());
  }
}

  Future<void> _loadChatHistories() async {
    try {
      final response = await http.get(
        Uri.parse('https://devred.pythonanywhere.com/api/chat/'),
        headers: {
          'Authorization': 'Token $_token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> decodedList = json.decode(response.body);
        final List<ChatHistory> loadedHistories =
            decodedList.map((json) => ChatHistory.fromJson(json)).toList();
        _chatHistoriesNotifier.value = loadedHistories;
      } else {
        _showError('Error loading data', response.body);
      }
    } catch (e) {
      _showError('Error loading data', e.toString());
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isNotEmpty && !_isThinkingNotifier.value) {
      final String userMessage = _controller.text.trim();
      if (_farmId == null) {
       _showError('Error', 'Farm ID is missing. Cannot send message. Please try reloading.');
       _isThinkingNotifier.value = false; // Ensure loading indicator stops
       return; // Don't proceed
    }
      _isThinkingNotifier.value = true;
      final String title = _isNewChat
          ? userMessage
          : _currentChatTitleNotifier.value!; // add title if its a new chat
      _messagesNotifier.value = [
        ..._messagesNotifier.value,
        ChatMessage(
            sender: 'user',
            text: userMessage,
            timeStamp: DateTime.now().toString()),
      ];
      _controller.clear();
      try {
        final prefs = await SharedPreferences.getInstance();
        final int? _farmId = prefs.getInt('farmId');
        final response = await http.post(
          Uri.parse(
              'https://devred.pythonanywhere.com/api/chat/$_farmId/'), // added the farm id
          headers: {
            'Authorization': 'Token $_token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'message': userMessage,
            'chat_title': title
          }), //send the user message
        );
        if (response.statusCode == 200) {
          final decodedData = json.decode(response.body);
          ChatHistory chatHistory = ChatHistory.fromJson(decodedData);
          _messagesNotifier.value = [...chatHistory.messages];
          _currentChatTitleNotifier.value = chatHistory.title;
          _isNewChat = false;
          _isThinkingNotifier.value = false;
        } else {
          _showError("Error", response.body);
          _isThinkingNotifier.value = false;
        }
      } catch (e) {
        _showError('Error:', e.toString());
        _isThinkingNotifier.value = false;
      }
    }
  }

  void _handleDrawerItemTap(int chatHistoryId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://devred.pythonanywhere.com/api/chat/$chatHistoryId/'), // send the id of the selected chat history
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        ChatHistory chatHistory = ChatHistory.fromJson(decodedData);
        _messagesNotifier.value = [...chatHistory.messages];
        _currentChatTitleNotifier.value = chatHistory.title;
        _isNewChat = false;
        Navigator.pop(context);
      } else {
        _showError('Error loading data', response.body);
      }
    } catch (e) {
      _showError('Error loading data', e.toString());
    }
  }

  void _clearCurrentChat() {
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

  Future<void> _deleteAllChatHistories() async {
    try {
      for (var chat in _chatHistoriesNotifier.value) {
        final response = await http.delete(
          Uri.parse('https://devred.pythonanywhere.com/api/chat/${chat.id}/'),
          headers: {
            'Authorization': 'Token $_token',
          },
        );
        if (response.statusCode != 204) {
          _showError('Error deleting chat', response.body);
        }
      }
      _chatHistoriesNotifier.value = [];
      _messagesNotifier.value = []; // Clear current chat messages
      _currentChatTitleNotifier.value = null; // clear current chat title
      _isNewChat = true; // reset new chat flag
    } catch (e) {
      _showError('Error deleting chat', e.toString());
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
                              leading: const Icon(
                                  Icons.chat_bubble_outline_outlined),
                              title: Text(history.title),
                              tileColor: AppColors.primary,
                              selectedColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: () {
                                _handleDrawerItemTap(history.id);
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
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _suggestions.length,
                                        itemBuilder: (context, index) {
                                          return SizedBox(
                                            width: double.infinity,
                                            child: Card(
                                              color: AppColors.secondary,
                                              surfaceTintColor:
                                                  AppColors.secondary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  _suggestions[index],
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                  maxLines: 2,
                                                ),
                                                onTap: () {
                                                  _setSuggestionText(
                                                      _suggestions[index]);
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
                                      child: Icon(Icons.person,
                                          color: Colors.white),
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
                                        borderRadius: BorderRadius.circular(12),
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
}
