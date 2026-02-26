import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class DirectMessagePage extends StatefulWidget {
  final String userId;
  const DirectMessagePage({super.key, required this.userId});

  @override
  State<DirectMessagePage> createState() => _DirectMessagePageState();
}

class _DirectMessagePageState extends State<DirectMessagePage> {
  final _messageController = TextEditingController();
  final RxList<Map<String, dynamic>> _messages = <Map<String, dynamic>>[].obs;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messages.add({
      'content': text,
      'isSelf': true,
      'time': DateTime.now(),
    });

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.cardDark,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User ${widget.userId.substring(0, 6)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const Text('Online', style: TextStyle(color: AppTheme.successColor, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.white)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => _messages.isEmpty
                ? const Center(
                    child: Text('Start a conversation', style: TextStyle(color: AppTheme.textMuted)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isSelf = msg['isSelf'] as bool;
                      return Align(
                        alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            gradient: isSelf ? AppTheme.primaryGradient : null,
                            color: isSelf ? null : AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg['content'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      );
                    },
                  )),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.dividerDark)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.dividerDark),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined, color: AppTheme.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
