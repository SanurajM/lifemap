import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Profile ──────────────────────────────────────────────────────────────────
class ProfileModel {
  String name;
  String avatar;
  String travelStyle;
  String diet;
  int completeness;

  ProfileModel({
    this.name = 'Alex',
    this.avatar = '🧭',
    this.travelStyle = 'Adventure',
    this.diet = 'No restrictions',
    this.completeness = 40,
  });
}

// ── Trip ─────────────────────────────────────────────────────────────────────
class PackingItem {
  final int id;
  final String category;
  final String text;
  bool isDone;
  PackingItem({required this.id, required this.category, required this.text, this.isDone = false});
}

class ItineraryDay {
  final String dayLabel;
  final String plan;
  ItineraryDay({required this.dayLabel, required this.plan});
}

class TripModel {
  final int id;
  String name;
  String destination;
  String emoji;
  DateTime startDate;
  DateTime endDate;
  String tripType;
  String weather;
  double budget;
  double spent;
  List<PackingItem> items;
  List<ItineraryDay> itinerary;

  TripModel({
    required this.id,
    required this.name,
    required this.destination,
    this.emoji = '✈️',
    required this.startDate,
    required this.endDate,
    this.tripType = 'Leisure',
    this.weather = '—',
    this.budget = 0,
    this.spent = 0,
    List<PackingItem>? items,
    List<ItineraryDay>? itinerary,
  })  : items = items ?? [],
        itinerary = itinerary ?? [];

  int get daysUntil => startDate.difference(DateTime.now()).inDays;
  int get packedCount => items.where((i) => i.isDone).length;
  int get totalItems => items.length;
  double get packingPercent => totalItems == 0 ? 0 : packedCount / totalItems;
}

// ── Daily Task ────────────────────────────────────────────────────────────────
class DailyTask {
  final int id;
  final String timeOfDay;
  final String text;
  bool isDone;
  int streak;
  bool isImportant;

  DailyTask({
    required this.id,
    required this.timeOfDay,
    required this.text,
    this.isDone = false,
    this.streak = 0,
    this.isImportant = false,
  });
}

// ── Event ─────────────────────────────────────────────────────────────────────
class EventTask {
  final int id;
  final String text;
  bool isDone;
  EventTask({required this.id, required this.text, this.isDone = false});
}

class EventGuest {
  final int id;
  final String name;
  String status; // host, confirmed, pending, declined
  EventGuest({required this.id, required this.name, this.status = 'pending'});
}

class EventModel {
  final int id;
  String name;
  String emoji;
  DateTime date;
  String venue;
  double budget;
  double spent;
  List<EventTask> tasks;
  List<EventGuest> guests;

  EventModel({
    required this.id,
    required this.name,
    this.emoji = '🎉',
    required this.date,
    this.venue = '',
    this.budget = 0,
    this.spent = 0,
    List<EventTask>? tasks,
    List<EventGuest>? guests,
  })  : tasks = tasks ?? [],
        guests = guests ?? [];

  int get daysUntil => date.difference(DateTime.now()).inDays;
  int get tasksDone => tasks.where((t) => t.isDone).length;
  double get taskPercent => tasks.isEmpty ? 0 : tasksDone / tasks.length;
  int get confirmedGuests => guests.where((g) => g.status == 'confirmed').length;
}

// ── Habit ─────────────────────────────────────────────────────────────────────
class HabitModel {
  final int id;
  String name;
  String icon;
  int streak;
  int bestStreak;
  Color color;
  List<int> history; // 1=done, 0=missed

  HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    this.streak = 0,
    this.bestStreak = 0,
    required this.color,
    List<int>? history,
  }) : history = history ?? [];
}

// ── Moving ────────────────────────────────────────────────────────────────────
class MovingTask {
  final int id;
  final String text;
  bool isDone;
  MovingTask({required this.id, required this.text, this.isDone = false});
}

class MovingRoom {
  final int id;
  final String name;
  final String icon;
  List<MovingTask> tasks;
  MovingRoom({required this.id, required this.name, required this.icon, List<MovingTask>? tasks})
      : tasks = tasks ?? [];
}

class MovingModel {
  String address;
  DateTime moveDate;
  List<MovingRoom> rooms;

  MovingModel({
    required this.address,
    required this.moveDate,
    List<MovingRoom>? rooms,
  }) : rooms = rooms ?? [];

  int get totalTasks => rooms.fold(0, (s, r) => s + r.tasks.length);
  int get doneTasks => rooms.fold(0, (s, r) => s + r.tasks.where((t) => t.isDone).length);
  double get progress => totalTasks == 0 ? 0 : doneTasks / totalTasks;
}

// ── Sample Data ───────────────────────────────────────────────────────────────
TripModel get sampleTrip1 => TripModel(
      id: 1,
      name: 'Goa Beach Escape',
      destination: 'Goa, India',
      emoji: '🏖️',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 12)),
      tripType: 'Beach',
      weather: '28°C Sunny',
      budget: 15000,
      spent: 6200,
      items: [
        PackingItem(id: 1, category: 'Documents', text: 'Passport / Aadhaar', isDone: true),
        PackingItem(id: 2, category: 'Documents', text: 'Hotel booking', isDone: true),
        PackingItem(id: 3, category: 'Documents', text: 'Travel insurance', isDone: false),
        PackingItem(id: 4, category: 'Clothing', text: 'Swimwear ×2', isDone: true),
        PackingItem(id: 5, category: 'Clothing', text: 'Flip flops', isDone: true),
        PackingItem(id: 6, category: 'Clothing', text: 'Light linen shirts', isDone: false),
        PackingItem(id: 7, category: 'Clothing', text: 'Light raincoat', isDone: false),
        PackingItem(id: 8, category: 'Health', text: 'Sunscreen SPF 50+', isDone: true),
        PackingItem(id: 9, category: 'Health', text: 'Mosquito repellent', isDone: false),
        PackingItem(id: 10, category: 'Health', text: 'Personal medication', isDone: true),
        PackingItem(id: 11, category: 'Electronics', text: 'Phone charger', isDone: true),
        PackingItem(id: 12, category: 'Electronics', text: 'Power bank', isDone: false),
        PackingItem(id: 13, category: 'Electronics', text: 'Earphones', isDone: true),
        PackingItem(id: 14, category: 'Money', text: 'Cash ₹5000', isDone: true),
        PackingItem(id: 15, category: 'Money', text: 'UPI / Cards ready', isDone: true),
        PackingItem(id: 16, category: 'Misc', text: 'Reusable water bottle', isDone: false),
        PackingItem(id: 17, category: 'Misc', text: 'Beach bag', isDone: false),
        PackingItem(id: 18, category: 'Misc', text: 'Sunglasses', isDone: true),
      ],
      itinerary: [
        ItineraryDay(dayLabel: 'Day 1', plan: 'Arrive, check in, sunset at Calangute Beach'),
        ItineraryDay(dayLabel: 'Day 2', plan: 'Water sports at Baga, seafood dinner'),
        ItineraryDay(dayLabel: 'Day 3', plan: 'Old Goa churches, spice plantation tour'),
        ItineraryDay(dayLabel: 'Day 4', plan: 'Dudhsagar waterfall trek'),
        ItineraryDay(dayLabel: 'Day 5', plan: 'Shopping at Anjuna flea market, sunset cruise'),
        ItineraryDay(dayLabel: 'Day 6', plan: 'Leisurely breakfast, fly home'),
      ],
    );

TripModel get sampleTrip2 => TripModel(
      id: 2,
      name: 'Mumbai Business',
      destination: 'Mumbai, India',
      emoji: '💼',
      startDate: DateTime.now().add(const Duration(days: 28)),
      endDate: DateTime.now().add(const Duration(days: 30)),
      tripType: 'Business',
      weather: '32°C Humid',
      budget: 8000,
      spent: 0,
      items: [
        PackingItem(id: 1, category: 'Documents', text: 'Meeting agenda', isDone: false),
        PackingItem(id: 2, category: 'Documents', text: 'Business cards', isDone: false),
        PackingItem(id: 3, category: 'Clothing', text: 'Formal suit', isDone: false),
        PackingItem(id: 4, category: 'Clothing', text: 'Formal shoes', isDone: false),
        PackingItem(id: 5, category: 'Electronics', text: 'Laptop + charger', isDone: false),
        PackingItem(id: 6, category: 'Money', text: 'Corporate card', isDone: false),
      ],
      itinerary: [
        ItineraryDay(dayLabel: 'Day 1', plan: 'Fly in, check in, client dinner'),
        ItineraryDay(dayLabel: 'Day 2', plan: 'Board meeting 9AM, product demo 2PM'),
        ItineraryDay(dayLabel: 'Day 3', plan: 'Follow-up meetings, fly home evening'),
      ],
    );

List<DailyTask> get sampleDailyTasks => [
      DailyTask(id: 1, timeOfDay: 'Morning', text: '10-min meditation', isDone: true, streak: 12, isImportant: true),
      DailyTask(id: 2, timeOfDay: 'Morning', text: 'Hydrate (2 glasses water)', isDone: true, streak: 5),
      DailyTask(id: 3, timeOfDay: 'Morning', text: 'Review today\'s plan', isDone: false, streak: 7, isImportant: true),
      DailyTask(id: 4, timeOfDay: 'Morning', text: 'Quick 5-min stretch', isDone: false, streak: 3),
      DailyTask(id: 5, timeOfDay: 'Afternoon', text: '30-min walk / exercise', isDone: false, streak: 9, isImportant: true),
      DailyTask(id: 6, timeOfDay: 'Afternoon', text: 'Reply to pending messages', isDone: false, streak: 0),
      DailyTask(id: 7, timeOfDay: 'Afternoon', text: 'Healthy lunch (no junk)', isDone: false, streak: 4),
      DailyTask(id: 8, timeOfDay: 'Evening', text: 'Read for 20 minutes', isDone: false, streak: 15, isImportant: true),
      DailyTask(id: 9, timeOfDay: 'Evening', text: 'Gratitude journal (3 things)', isDone: false, streak: 6),
      DailyTask(id: 10, timeOfDay: 'Evening', text: 'Plan tomorrow', isDone: false, streak: 4),
      DailyTask(id: 11, timeOfDay: 'Evening', text: 'Screen off by 10 PM', isDone: false, streak: 2),
    ];

EventModel get sampleEvent => EventModel(
      id: 1,
      name: "Arjun's Birthday Party",
      emoji: '🎂',
      date: DateTime.now().add(const Duration(days: 12)),
      venue: 'Sky Lounge, Kozhikode',
      budget: 5000,
      spent: 1200,
      tasks: [
        EventTask(id: 1, text: 'Book venue', isDone: true),
        EventTask(id: 2, text: 'Order birthday cake', isDone: true),
        EventTask(id: 3, text: 'Send invites', isDone: true),
        EventTask(id: 4, text: 'Arrange decorations', isDone: false),
        EventTask(id: 5, text: 'Order food / catering', isDone: false),
        EventTask(id: 6, text: 'Make playlist', isDone: false),
        EventTask(id: 7, text: 'Buy gift for Arjun', isDone: false),
        EventTask(id: 8, text: 'Arrange transport', isDone: false),
      ],
      guests: [
        EventGuest(id: 1, name: 'Arjun', status: 'host'),
        EventGuest(id: 2, name: 'Priya', status: 'confirmed'),
        EventGuest(id: 3, name: 'Rahul', status: 'confirmed'),
        EventGuest(id: 4, name: 'Sneha', status: 'pending'),
        EventGuest(id: 5, name: 'Dev', status: 'pending'),
        EventGuest(id: 6, name: 'Meera', status: 'declined'),
      ],
    );

List<HabitModel> get sampleHabits => [
      HabitModel(id: 1, name: 'Meditation', icon: '🧘', streak: 12, bestStreak: 21, color: AppColors.teal,
          history: [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1]),
      HabitModel(id: 2, name: 'Exercise', icon: '🏃', streak: 9, bestStreak: 14, color: AppColors.blue,
          history: [1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1]),
      HabitModel(id: 3, name: 'Reading', icon: '📚', streak: 15, bestStreak: 30, color: AppColors.violet,
          history: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1]),
      HabitModel(id: 4, name: 'Journaling', icon: '✍️', streak: 6, bestStreak: 10, color: AppColors.accent,
          history: [0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1]),
    ];

MovingModel get sampleMoving => MovingModel(
      address: 'New Flat, Calicut Beach Road',
      moveDate: DateTime.now().add(const Duration(days: 54)),
      rooms: [
        MovingRoom(id: 1, name: 'Living Room', icon: '🛋️', tasks: [
          MovingTask(id: 1, text: 'Measure furniture vs new space'),
          MovingTask(id: 2, text: 'Pack books & decor items'),
          MovingTask(id: 3, text: 'Disconnect TV & electronics'),
          MovingTask(id: 4, text: 'Disassemble sofa if needed'),
        ]),
        MovingRoom(id: 2, name: 'Bedroom', icon: '🛏️', tasks: [
          MovingTask(id: 1, text: 'Pack clothes in suitcases', isDone: true),
          MovingTask(id: 2, text: 'Dismantle wardrobe'),
          MovingTask(id: 3, text: 'Pack bedding in bags'),
          MovingTask(id: 4, text: 'Label all boxes', isDone: true),
        ]),
        MovingRoom(id: 3, name: 'Kitchen', icon: '🍳', tasks: [
          MovingTask(id: 1, text: 'Use up perishables'),
          MovingTask(id: 2, text: 'Pack utensils in bubble wrap'),
          MovingTask(id: 3, text: 'Defrost and clean fridge'),
          MovingTask(id: 4, text: 'Pack appliances safely'),
        ]),
        MovingRoom(id: 4, name: 'Admin', icon: '📋', tasks: [
          MovingTask(id: 1, text: 'Update address on Aadhaar'),
          MovingTask(id: 2, text: 'Notify bank / credit cards'),
          MovingTask(id: 3, text: 'Transfer utility connections'),
          MovingTask(id: 4, text: 'Hire movers / truck', isDone: true),
          MovingTask(id: 5, text: 'Change address on subscriptions'),
        ]),
      ],
    );
