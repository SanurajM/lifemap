import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/llm_service.dart' show buildSystemPrompt;

class AppProvider extends ChangeNotifier {
  // Auth
  bool _isLoggedIn = false;
  bool _onboardingDone = false;
  bool get isLoggedIn => _isLoggedIn;
  bool get onboardingDone => _onboardingDone;

  // Data
  ProfileModel profile = ProfileModel();
  List<TripModel> trips = [sampleTrip1, sampleTrip2];
  List<DailyTask> dailyTasks = sampleDailyTasks;
  List<EventModel> events = [sampleEvent];
  List<HabitModel> habits = sampleHabits;
  MovingModel moving = sampleMoving;

  // Chat history
  List<Map<String, String>> chatHistory = [];

  AppProvider() {
    _loadPrefs();
    _initChat();
  }

  void _initChat() {
    chatHistory = [
      {
        'role': 'ai',
        'text':
            'Hi! I\'m your LifeMap AI 🤖\nI run entirely on your device — no internet needed. Ask me anything about your trips, habits, events, or daily routine!'
      }
    ];
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _onboardingDone = prefs.getBool('onboardingDone') ?? false;
    final savedName = prefs.getString('userName');
    if (savedName != null) profile.name = savedName;
    notifyListeners();
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
    _onboardingDone = true;
    notifyListeners();
  }

  Future<void> login(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', name);
    profile.name = name;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    _isLoggedIn = false;
    notifyListeners();
  }

  // ── Build system prompt for LLM ────────────────────────────────────────────
  // Calls the top-level buildSystemPrompt() from llm_service.dart
  String getSystemPrompt() {
    return buildSystemPrompt(
      name: profile.name,
      travelStyle: profile.travelStyle,
      diet: profile.diet,
      avatar: profile.avatar,
      upcomingTrips: trips.map((t) =>
        '${t.emoji} ${t.name} → ${t.destination} in ${t.daysUntil} days '
        '(${(t.packingPercent * 100).round()}% packed, '
        'budget ₹${t.budget.toStringAsFixed(0)}, spent ₹${t.spent.toStringAsFixed(0)})'
      ).toList(),
      dailyTasksDone: totalDailyDone,
      dailyTasksTotal: dailyTasks.length,
      habits: habits.map((h) =>
        '${h.icon} ${h.name}: ${h.streak}-day streak (best: ${h.bestStreak})'
      ).toList(),
      topStreak: topStreak,
      upcomingEvents: events.map((e) =>
        '${e.emoji} ${e.name} at ${e.venue} in ${e.daysUntil} days '
        '(${e.tasksDone}/${e.tasks.length} tasks done, ${e.confirmedGuests} guests confirmed)'
      ).toList(),
      movingAddress: moving.address,
      movingDaysLeft: moving.moveDate.difference(DateTime.now()).inDays,
      movingProgress: moving.progress,
    );
  }

  // ── Chat history ────────────────────────────────────────────────────────────
  void addChatMessage(String role, String text) {
    chatHistory.add({'role': role, 'text': text});
    notifyListeners();
  }

  void updateLastAIMessage(String text) {
    for (int i = chatHistory.length - 1; i >= 0; i--) {
      if (chatHistory[i]['role'] == 'ai') {
        chatHistory[i] = {'role': 'ai', 'text': text};
        notifyListeners();
        return;
      }
    }
  }

  // ── Trip actions ────────────────────────────────────────────────────────────
  void togglePackingItem(int tripId, int itemId) {
    final trip = trips.firstWhere((t) => t.id == tripId);
    final item = trip.items.firstWhere((i) => i.id == itemId);
    item.isDone = !item.isDone;
    notifyListeners();
  }

  void addTrip(TripModel trip) {
    trips.add(trip);
    notifyListeners();
  }

  void addPackingItem(int tripId, PackingItem item) {
    trips.firstWhere((t) => t.id == tripId).items.add(item);
    notifyListeners();
  }

  // ── Daily task actions ──────────────────────────────────────────────────────
  void toggleDailyTask(int taskId) {
    final task = dailyTasks.firstWhere((t) => t.id == taskId);
    task.isDone = !task.isDone;
    notifyListeners();
  }

  void addDailyTask(DailyTask task) {
    dailyTasks.add(task);
    notifyListeners();
  }

  // ── Event actions ───────────────────────────────────────────────────────────
  void toggleEventTask(int eventId, int taskId) {
    final event = events.firstWhere((e) => e.id == eventId);
    final task = event.tasks.firstWhere((t) => t.id == taskId);
    task.isDone = !task.isDone;
    notifyListeners();
  }

  void cycleGuestStatus(int eventId, int guestId) {
    final event = events.firstWhere((e) => e.id == eventId);
    final guest = event.guests.firstWhere((g) => g.id == guestId);
    if (guest.status == 'host') return;
    const cycle = {
      'pending': 'confirmed',
      'confirmed': 'declined',
      'declined': 'pending',
    };
    guest.status = cycle[guest.status] ?? 'pending';
    notifyListeners();
  }

  void addEvent(EventModel event) {
    events.add(event);
    notifyListeners();
  }

  void addGuest(int eventId, EventGuest guest) {
    events.firstWhere((e) => e.id == eventId).guests.add(guest);
    notifyListeners();
  }

  void addEventTask(int eventId, EventTask task) {
    events.firstWhere((e) => e.id == eventId).tasks.add(task);
    notifyListeners();
  }

  // ── Habit actions ───────────────────────────────────────────────────────────
  void logHabitToday(int habitId) {
    final habit = habits.firstWhere((h) => h.id == habitId);
    habit.streak++;
    if (habit.streak > habit.bestStreak) habit.bestStreak = habit.streak;
    habit.history.add(1);
    notifyListeners();
  }

  void addHabit(HabitModel habit) {
    habits.add(habit);
    notifyListeners();
  }

  // ── Moving actions ──────────────────────────────────────────────────────────
  void toggleMovingTask(int roomId, int taskId) {
    final room = moving.rooms.firstWhere((r) => r.id == roomId);
    final task = room.tasks.firstWhere((t) => t.id == taskId);
    task.isDone = !task.isDone;
    notifyListeners();
  }

  // ── Profile ─────────────────────────────────────────────────────────────────
  void updateProfile(ProfileModel updated) {
    profile = updated;
    notifyListeners();
  }

  // ── Stats ───────────────────────────────────────────────────────────────────
  int get topStreak =>
      habits.isEmpty ? 0 : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
  int get totalDailyDone => dailyTasks.where((t) => t.isDone).length;
  int get totalPacked => trips.fold(0, (s, t) => s + t.packedCount);
  int get totalItems => trips.fold(0, (s, t) => s + t.totalItems);
  double get totalBudgetLeft =>
      trips.fold(0.0, (s, t) => s + (t.budget - t.spent));
}
