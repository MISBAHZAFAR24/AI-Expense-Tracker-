import 'package:flutter/material.dart';
import 'api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiAdvisorScreen extends StatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  bool _isInitialLoading = true;
  bool _isAiThinking = false;
  Map<String, dynamic>? _aiData;
  final List<ChatMessage> _messages = [];
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickPrompts = [
    "🔮 Predict my next month expenses",
    "🏆 What is my Financial Persona?",
    "💡 Give me a Money Saving Tip",
    "🎯 Help me plan a Savings Goal",
    "📱 Can I buy a phone for ₹15000?",
    "💳 Can I afford a ₹5000 EMI?",
    "📅 What is my safe daily spending limit?",
    "📈 Where should I invest my savings?",
    "🛡️ How much emergency fund do I need?",
    "📊 Analyze my top expenses",
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialAdvice();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
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

  Future<void> _loadInitialAdvice() async {
    setState(() => _isInitialLoading = true);
    try {
      final response = await ApiService.getAIAdvice();
      if (response['status'] == 'success' && response['data'] != null) {
        if (mounted) {
          setState(() {
            _aiData = response['data'];
            final initialAdvice = _aiData?['advice'] ?? "Hello! I am your AI Financial Advisor. Ask me anything about your budget!";
            _messages.clear();
            _messages.add(ChatMessage(text: initialAdvice, isUser: false));
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.add(ChatMessage(
              text: "Hello! I am your FinWise AI Assistant. Ask me any question about your expenses, savings, or budget!",
              isUser: false,
            ));
          });
        }
      }
    } catch (e) {
      debugPrint("AI Advisor Error: $e");
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.add(ChatMessage(
            text: "Hello! Ask me any question about your budget, expenses, or savings tips!",
            isUser: false,
          ));
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  Future<void> _handleSendMessage([String? textToSend]) async {
    final text = textToSend ?? _questionController.text.trim();
    if (text.isEmpty || _isAiThinking) return;

    _questionController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isAiThinking = true;
    });

    _scrollToBottom();

    try {
      final response = await ApiService.getAIAdvice(question: text);
      if (response != null && response['status'] == 'success' && response['data'] != null) {
        final advice = response['data']['advice'] ?? "I couldn't generate advice right now. Please try again.";
        if (mounted) {
          setState(() {
            _aiData = response['data'];
            _messages.add(ChatMessage(text: advice, isUser: false));
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              text: "Sorry, I couldn't process that. ${response?['message'] ?? 'Please try again.'}",
              isUser: false,
            ));
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "Connection error. Please check your internet or try again later.",
            isUser: false,
          ));
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAiThinking = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text("AI Financial Assistant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isInitialLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      _buildSummaryCard(),
                      _buildHealthScoreCard(),
                      _buildSmartTipCard(),
                      _buildQuickPromptsBar(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            ..._messages.map((msg) => _buildChatBubble(msg)),
                            if (_isAiThinking) _buildThinkingBubble(),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          _buildQuestionInput(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final income = _aiData?['totalIncome'] ?? 0;
    final expense = _aiData?['totalExpense'] ?? 0;
    final balance = _aiData?['balance'] ?? 0;

    return Container(
      color: const Color(0xFF10B981),
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem("Income", "₹$income", Colors.green),
            Container(height: 30, width: 1, color: Colors.grey.shade300),
            _statItem("Expense", "₹$expense", Colors.red),
            Container(height: 30, width: 1, color: Colors.grey.shade300),
            _statItem("Balance", "₹$balance", const Color(0xFF10B981)),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHealthScoreCard() {
    final healthScore = (_aiData?['healthScore'] ?? 100) as int;
    final riskLevel = (_aiData?['riskLevel'] ?? "EXCELLENT").toString();
    final warning = (_aiData?['topWarning'] ?? "").toString();
    final persona = (_aiData?['financialPersona'] ?? "⚖️ Balanced Budgeter").toString();

    Color scoreColor = Colors.green;
    if (healthScore < 40) {
      scoreColor = Colors.red;
    } else if (healthScore < 70) {
      scoreColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: scoreColor),
                    const SizedBox(width: 4),
                    Text(
                      "AI Score: $healthScore/100 ($riskLevel)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  persona,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          if (warning.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              warning,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmartTipCard() {
    final tip = (_aiData?['smartTip'] ?? "").toString();
    if (tip.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFFD97706), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPromptsBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _quickPrompts.length,
        itemBuilder: (context, index) {
          final prompt = _quickPrompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF10B981), width: 1),
              label: Text(prompt, style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
              onPressed: () => _handleSendMessage(prompt),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.smart_toy, size: 16, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text("FinWise AI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                  ],
                ),
              ),
            SelectableText(
              message.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
            ),
            SizedBox(width: 10),
            Text("FinWise AI is analyzing...", style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -3))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _questionController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSendMessage(),
                style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "Ask AI (e.g. Can I afford a phone?)",
                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF10B981),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _handleSendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
