import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

const _modelUrl =
    'https://huggingface.co/litert-community/SmolLM-135M-Instruct/resolve/main/SmolLM-135M-Instruct_multi-prefill-seq_f32_ekv1280.task';
const _modelFileName = 'SmolLM-135M-Instruct_multi-prefill-seq_f32_ekv1280.task';
final _modelType = ModelType.general;

class LLMService extends ChangeNotifier {
  LLMStatus _status = LLMStatus.checking;
  double _downloadProgress = 0.0;
  String _statusMessage = 'Checking...';
  String? _error;
  bool _isGenerating = false;

  InferenceModel? _model;

  LLMStatus get status => _status;
  double get downloadProgress => _downloadProgress;
  String get statusMessage => _statusMessage;
  String? get error => _error;
  bool get isGenerating => _isGenerating;
  bool get isReady => _status == LLMStatus.ready;

  Future<void> initialize() async {
    _setStatus(LLMStatus.checking, 'Checking for model...');
    try {
      final installed = await FlutterGemma.isModelInstalled(_modelFileName);
      debugPrint('LLM: isModelInstalled=$installed');
      if (installed) {
        await _loadModel();
      } else {
        _setStatus(LLMStatus.needsDownload, 'Model not found. Download required (~530 MB).');
      }
    } catch (e, st) {
      debugPrint('LLM initialize error: $e\n$st');
      _setStatus(LLMStatus.needsDownload, 'Could not check model. Tap to download.');
    }
  }

  Future<void> downloadModel() async {
    _setStatus(LLMStatus.downloading, 'Starting download...');
    _downloadProgress = 0;
    _error = null;
    notifyListeners();

    try {
      debugPrint('LLM: Starting install from network...');
      await FlutterGemma.installModel(modelType: _modelType)
          .fromNetwork(_modelUrl)
          .withProgress((int progress) {
            _downloadProgress = progress / 100.0;
            _statusMessage = 'Downloading SmolLM 135M... $progress%';
            notifyListeners();
          })
          .install();

      debugPrint('LLM: install() completed successfully, now loading...');
      _setStatus(LLMStatus.loading, 'Download complete. Loading into memory...');
      await _loadModel();
    } catch (e, st) {
      // Show the REAL error in both the UI and logs
      final msg = e.toString();
      _error = msg;
      debugPrint('LLM downloadModel error: $msg\n$st');
      _setStatus(LLMStatus.error, 'Error: $msg');
    }
  }

  Future<void> _loadModel() async {
    _setStatus(LLMStatus.loading, 'Loading AI model...');
    try {
      debugPrint('LLM: calling getActiveModel...');
      await _model?.close();
      _model = null;

      // flutter_gemma loses "active model" state on app restart even if the
      // file is on disk. Re-calling installModel with the same URL and the
      // default KEEP policy skips the download and just re-registers the file.
      debugPrint('LLM: re-activating model via installModel (KEEP policy)...');
      await FlutterGemma.installModel(modelType: _modelType)
          .fromNetwork(_modelUrl)
          .install();

      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.cpu,
      );

      debugPrint('LLM: model loaded successfully!');
      _setStatus(LLMStatus.ready, 'AI ready · SmolLM 135M · On-device');
    } catch (e, st) {
      final msg = e.toString();
      _error = msg;
      debugPrint('LLM _loadModel error: $msg\n$st');
      _setStatus(LLMStatus.error, 'Load error: $msg');
    }
  }

  Stream<String> generateStream({
    required String userMessage,
    required String systemPrompt,
    required List<Map<String, String>> history,
  }) async* {
    if (!isReady || _model == null) {
      yield '⚠️ AI model not ready. Please download it first.';
      return;
    }

    _isGenerating = true;
    notifyListeners();

    try {
      final chat = await _model!.createChat(
        temperature: 0.7,
        randomSeed: 42,
        topK: 40,
      );

      // For ModelType.general, system prompt must be prepended to the first
      // user message — sending it as a separate chunk gets stripped to 2 chars.
      bool systemInjected = false;

      String prependSystem(String text) {
        if (!systemInjected) {
          systemInjected = true;
          return '$systemPrompt\n\n$text';
        }
        return text;
      }

      for (final msg in history.skip(1)) {
        final text = msg['text'] ?? '';
        if (text.isEmpty) continue;
        final isUser = msg['role'] == 'user';
        await chat.addQueryChunk(
          Message.text(
            text: isUser ? prependSystem(text) : text,
            isUser: isUser,
          ),
        );
      }

      await chat.addQueryChunk(
        Message.text(text: prependSystem(userMessage), isUser: true),
      );

      await for (final response in chat.generateChatResponseAsync()) {
        if (response is TextResponse) {
          yield response.token;
        }
      }
    } catch (e, st) {
      debugPrint('LLM generateStream error: $e\n$st');
      yield '\n\n[Error: ${e.toString()}]';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> deleteModel() async {
    await _model?.close();
    _model = null;
    _setStatus(LLMStatus.needsDownload, 'Model removed. Tap to re-download.');
  }

  @override
  void dispose() {
    _model?.close();
    super.dispose();
  }

  void _setStatus(LLMStatus s, String msg) {
    _status = s;
    _statusMessage = msg;
    notifyListeners();
  }
}

enum LLMStatus { checking, needsDownload, downloading, loading, ready, error }

String buildSystemPrompt({
  required String name,
  required String travelStyle,
  required String diet,
  required String avatar,
  required List<String> upcomingTrips,
  required int dailyTasksDone,
  required int dailyTasksTotal,
  required List<String> habits,
  required int topStreak,
  required List<String> upcomingEvents,
  required String movingAddress,
  required int movingDaysLeft,
  required double movingProgress,
}) =>
    '''You are LifeMap AI, a personal life assistant. Be warm, brief (3-5 sentences), and actionable.

USER: $name | Travel: $travelStyle | Diet: $diet
TRIPS: ${upcomingTrips.isEmpty ? 'None' : upcomingTrips.join('; ')}
TODAY: $dailyTasksDone/$dailyTasksTotal tasks done
HABITS: ${habits.join('; ')} | Top streak: ${topStreak}d
EVENTS: ${upcomingEvents.isEmpty ? 'None' : upcomingEvents.join('; ')}
MOVING: To $movingAddress in ${movingDaysLeft}d (${(movingProgress * 100).round()}% done)

Only reference data above. Use emojis naturally. Never fabricate facts.''';
