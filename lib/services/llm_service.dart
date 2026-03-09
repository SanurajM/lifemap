import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Model config ──────────────────────────────────────────────────────────────
// Gemma 3 1B int4 — ~600MB, runs on Android & iOS, GPU-accelerated
const _modelFileName = 'gemma3-1B-it-int4.task';

// Download from HuggingFace LiteRT community
// No auth token needed for this public model
const _modelUrl =
    'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1B-it-int4.task';

const _modelReadyKey = 'llm_model_ready';

// ── LLM Service ───────────────────────────────────────────────────────────────
class LLMService extends ChangeNotifier {
  // Download state
  LLMStatus _status = LLMStatus.checking;
  double _downloadProgress = 0.0;
  String _statusMessage = 'Checking...';
  String? _error;

  // Inference state
  bool _isGenerating = false;

  LLMStatus get status => _status;
  double get downloadProgress => _downloadProgress;
  String get statusMessage => _statusMessage;
  String? get error => _error;
  bool get isGenerating => _isGenerating;
  bool get isReady => _status == LLMStatus.ready;

  // ── Initialise ──────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    _setStatus(LLMStatus.checking, 'Checking for model...');

    final modelPath = await _modelFilePath();
    final prefs = await SharedPreferences.getInstance();
    final modelReady = prefs.getBool(_modelReadyKey) ?? false;

    if (modelReady && File(modelPath).existsSync()) {
      await _loadModel(modelPath);
    } else {
      _setStatus(LLMStatus.needsDownload, 'Model not found. Download required.');
    }
  }

  // ── Download ────────────────────────────────────────────────────────────────
  Future<void> downloadModel() async {
    _setStatus(LLMStatus.downloading, 'Starting download...');
    _downloadProgress = 0;
    _error = null;
    notifyListeners();

    try {
      final modelPath = await _modelFilePath();
      final dio = Dio();

      await dio.download(
        _modelUrl,
        modelPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _downloadProgress = received / total;
            _statusMessage =
                'Downloading Gemma 3 1B... ${(received / 1024 / 1024).toStringAsFixed(0)} MB / ${(total / 1024 / 1024).toStringAsFixed(0)} MB';
            notifyListeners();
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 20),
          sendTimeout: const Duration(minutes: 5),
        ),
      );

      // Mark as downloaded
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_modelReadyKey, true);

      _setStatus(LLMStatus.loading, 'Loading model into memory...');
      await _loadModel(modelPath);
    } on DioException catch (e) {
      _error = 'Download failed: ${e.message}';
      _setStatus(LLMStatus.error, 'Download failed. Check connection and retry.');
      debugPrint('LLM download error: $e');
    } catch (e) {
      _error = e.toString();
      _setStatus(LLMStatus.error, 'Unexpected error. Please retry.');
      debugPrint('LLM unexpected error: $e');
    }
  }

  // ── Load model ──────────────────────────────────────────────────────────────
  Future<void> _loadModel(String path) async {
    _setStatus(LLMStatus.loading, 'Loading AI model...');
    try {
      await FlutterGemmaPlugin.instance.init(
        modelPath: path,
        maxTokens: 512,
        temperature: 0.8,
        topK: 40,
        randomSeed: 42,
      );
      _setStatus(LLMStatus.ready, 'AI ready');
    } catch (e) {
      // If model file is corrupt, delete and prompt re-download
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_modelReadyKey, false);
      final file = File(path);
      if (await file.exists()) await file.delete();

      _error = e.toString();
      _setStatus(LLMStatus.needsDownload, 'Model failed to load. Please re-download.');
      debugPrint('LLM load error: $e');
    }
  }

  // ── Generate (streaming) ────────────────────────────────────────────────────
  // Returns a stream of token strings
  Stream<String> generateStream({
    required String userMessage,
    required String systemPrompt,
    required List<Map<String, String>> history,
  }) async* {
    if (!isReady) return;

    _isGenerating = true;
    notifyListeners();

    try {
      // Build message list for flutter_gemma
      // Prepend system prompt as the first user turn (Gemma convention)
      final messages = <Message>[
        // System context as the very first message
        Message(
          text: systemPrompt,
          isUser: true,
        ),
        // Conversation history (skip the first AI greeting for brevity)
        ...history.skip(1).map((m) => Message(
              text: m['text'] ?? '',
              isUser: m['role'] == 'user',
            )),
        // Current user message
        Message(text: userMessage, isUser: true),
      ];

      final responseStream =
          FlutterGemmaPlugin.instance.generateResponseAsync(messages: messages);

      await for (final chunk in responseStream) {
        if (chunk != null) {
          yield chunk;
        }
      }
    } catch (e) {
      debugPrint('LLM generation error: $e');
      yield '\n\n[AI error: ${e.toString()}]';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Future<String> _modelFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_modelFileName';
  }

  Future<String> get modelSizeOnDisk async {
    final path = await _modelFilePath();
    final file = File(path);
    if (!await file.exists()) return '0 MB';
    final bytes = await file.length();
    return '${(bytes / 1024 / 1024).toStringAsFixed(0)} MB';
  }

  Future<void> deleteModel() async {
    final path = await _modelFilePath();
    final file = File(path);
    if (await file.exists()) await file.delete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modelReadyKey, false);
    _setStatus(LLMStatus.needsDownload, 'Model deleted.');
  }

  void _setStatus(LLMStatus status, String message) {
    _status = status;
    _statusMessage = message;
    notifyListeners();
  }
}

// ── Status enum ───────────────────────────────────────────────────────────────
enum LLMStatus {
  checking,
  needsDownload,
  downloading,
  loading,
  ready,
  error,
}

// ── System Prompt Builder ─────────────────────────────────────────────────────
// Injects all LifeMap context so Gemma responds with personal, relevant info
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
}) {
  return '''
You are LifeMap AI, a personal life assistant embedded in the LifeMap app.
You know everything about the user's life and give short, warm, practical responses.

USER PROFILE:
- Name: $name
- Avatar: $avatar
- Travel Style: $travelStyle
- Diet: $diet

TRIPS:
${upcomingTrips.isEmpty ? '- No upcoming trips' : upcomingTrips.map((t) => '- $t').join('\n')}

DAILY ROUTINE:
- Today: $dailyTasksDone / $dailyTasksTotal tasks done

HABITS:
- Top streak: ${topStreak} days
${habits.map((h) => '- $h').join('\n')}

EVENTS:
${upcomingEvents.isEmpty ? '- No upcoming events' : upcomingEvents.map((e) => '- $e').join('\n')}

MOVING PLANNER:
- Moving to: $movingAddress
- In: $movingDaysLeft days
- Progress: ${(movingProgress * 100).round()}% packed

RULES:
- Keep responses concise (3-5 sentences max unless asked for a list)
- Be warm, encouraging, and personal — use the user's name occasionally
- Give actionable tips based on their actual data above
- Use emojis sparingly but naturally
- Never make up data not mentioned above
- If asked something outside the app's scope, answer helpfully but briefly
''';
}
