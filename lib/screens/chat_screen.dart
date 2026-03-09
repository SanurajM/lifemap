import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../services/llm_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isStreaming = false;
  String _streamBuffer = '';

  final _quickPrompts = const [
    "What should I pack for Goa?",
    "How's my productivity?",
    "Help with birthday party",
    "Suggest my daily routine",
    "Moving tips for me?",
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String msg) async {
    if (msg.trim().isEmpty || _isStreaming) return;

    final appProvider = context.read<AppProvider>();
    final llmService = context.read<LLMService>();

    _ctrl.clear();

    // Add user message
    appProvider.addChatMessage('user', msg);
    setState(() {
      _isStreaming = true;
      _streamBuffer = '';
    });
    _scrollToBottom();

    // Add empty AI message that we'll fill via streaming
    appProvider.addChatMessage('ai', '');

    if (!llmService.isReady) {
      // Fallback if model not loaded
      appProvider.updateLastAIMessage(
          '⚠️ AI model not loaded yet. Go to Settings to download it.');
      setState(() => _isStreaming = false);
      return;
    }

    try {
      final systemPrompt = appProvider.getSystemPrompt();

      final stream = llmService.generateStream(
        userMessage: msg,
        systemPrompt: systemPrompt,
        history: appProvider.chatHistory,
      );

      await for (final chunk in stream) {
        _streamBuffer += chunk;
        appProvider.updateLastAIMessage(_streamBuffer);
        _scrollToBottom();
      }
    } catch (e) {
      appProvider.updateLastAIMessage('Sorry, something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _streamBuffer = '';
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final llmService = context.watch<LLMService>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // Header
          _buildHeader(llmService),

          // Quick prompts
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(_quickPrompts[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      _quickPrompts[i],
                      style: GoogleFonts.sora(
                          fontSize: 11, color: AppColors.textSub),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Model not ready banner
          if (!llmService.isReady && llmService.status != LLMStatus.checking)
            _buildModelBanner(llmService),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: appProvider.chatHistory.length,
              itemBuilder: (_, i) {
                final msg = appProvider.chatHistory[i];
                final isUser = msg['role'] == 'user';
                final text = msg['text'] ?? '';
                final isLastAI = !isUser &&
                    i == appProvider.chatHistory.length - 1 &&
                    _isStreaming;

                return _ChatBubble(
                  text: text,
                  isUser: isUser,
                  isStreaming: isLastAI,
                );
              },
            ),
          ),

          // Input
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHeader(LLMService llm) {
    final statusColor = llm.isReady
        ? AppColors.teal
        : llm.status == LLMStatus.downloading || llm.status == LLMStatus.loading
            ? AppColors.accent
            : AppColors.rose;

    final statusText = llm.isReady
        ? '● On-device · Private · Offline'
        : llm.status == LLMStatus.downloading
            ? '⬇ Downloading model...'
            : llm.status == LLMStatus.loading
                ? '⚙ Loading model...'
                : '○ Model not loaded';

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withOpacity(0.2),
            AppColors.rose.withOpacity(0.12)
          ],
        ),
        border:
            const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.rose]),
            boxShadow: [
              BoxShadow(
                  color: AppColors.accent.withOpacity(0.35), blurRadius: 12)
            ],
          ),
          child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LifeMap AI',
                style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Row(children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(statusText,
                  style:
                      GoogleFonts.sora(fontSize: 11, color: statusColor)),
            ]),
          ]),
        ),
        // Model info chip
        if (llm.isReady)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.teal.withOpacity(0.3)),
            ),
            child: Text('Gemma 3 1B',
                style: GoogleFonts.sora(
                    fontSize: 10,
                    color: AppColors.teal,
                    fontWeight: FontWeight.w700)),
          ),
      ]),
    );
  }

  Widget _buildModelBanner(LLMService llm) {
    if (llm.status == LLMStatus.downloading ||
        llm.status == LLMStatus.loading) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Row(children: [
          const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  color: AppColors.accent, strokeWidth: 2)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(llm.statusMessage,
                style: GoogleFonts.sora(
                    fontSize: 12, color: AppColors.accent)),
          ),
          if (llm.status == LLMStatus.downloading)
            Text(
              '${(llm.downloadProgress * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent),
            ),
        ]),
      );
    }

    // Not downloaded
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/download'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.roseSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.rose.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Text('⬇️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Download Gemma 3 1B to enable real AI responses',
              style: GoogleFonts.sora(fontSize: 12, color: AppColors.rose),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.rose),
        ]),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            enabled: !_isStreaming,
            style: GoogleFonts.sora(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: _isStreaming
                  ? 'AI is thinking...'
                  : 'Ask me anything...',
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.accent)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 12),
            ),
            onSubmitted: _isStreaming ? null : (v) => _send(v),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _isStreaming ? null : () => _send(_ctrl.text),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isStreaming
                  ? AppColors.textMuted
                  : AppColors.accent,
              boxShadow: _isStreaming
                  ? []
                  : [
                      BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 10)
                    ],
            ),
            child: _isStreaming
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.arrow_upward_rounded,
                    color: Colors.black, size: 22),
          ),
        ),
      ]),
    );
  }
}

// ── Chat Bubble ───────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isStreaming;

  const _ChatBubble({
    required this.text,
    required this.isUser,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.rose]),
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                color: isUser ? AppColors.accent : AppColors.card,
                border: isUser
                    ? null
                    : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (text.isEmpty && isStreaming)
                    const _TypingDots()
                  else
                    Text(
                      text,
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        color: isUser
                            ? Colors.black
                            : AppColors.textPrimary,
                        height: 1.55,
                      ),
                    ),
                  // Streaming cursor
                  if (isStreaming && text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _BlinkingCursor(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Blinking cursor during streaming ─────────────────────────────────────────
class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _ctrl.value,
        child: Container(
          width: 2, height: 14,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

// ── Typing dots (empty response) ──────────────────────────────────────────────
class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) {
      final c = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));
      Future.delayed(Duration(milliseconds: i * 150),
          () { if (mounted) c.repeat(reverse: true); });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => AnimatedBuilder(
          animation: _ctrls[i],
          builder: (_, __) => Container(
            width: 6, height: 6 + _ctrls[i].value * 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppColors.accent
                  .withOpacity(0.5 + _ctrls[i].value * 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
