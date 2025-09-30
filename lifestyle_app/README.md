Lifestyle app

A Flutter app powered by Firebase Authentication and Firestore that helps users build better habits, track streaks, and compete on leaderboards.

✨ Features

🔑 Authentication – Register & login with email/password via Firebase Auth.

📝 Habit Tracking

Add habits (e.g., Run, Read Books, Drink Water).

Choose frequency (Daily, Weekly, Monthly).

Mark habits as completed for the day.

Automatic streak calculation.

🏅 Points & Rewards

Earn points for every check-in (+10 by default).

Undo check-in to remove points.

👤 Profile Page

View total points and badges.

Navigate to leaderboard by habit type.

🏆 Leaderboard

Compare points with other users.

Filter by habit (Run / Read Books / Drink Water).

📂 Project Structure
lib/
│
├── services/
│   └── firestore_service.dart   # Firestore CRUD & leaderboard logic
│
├── pages/
│   ├── auth/                    # Login & Register screens
│   ├── habits/                  # AddHabitPage + habit UI
│   ├── home/                    # HomePage with habit list
│   └── profile/                 # ProfilePage with points & leaderboard
│
└── main.dart                    # App entry point

🔧 Installation
1. Clone Repo
git clone https://github.com/yourusername/habit-tracker.git
cd habit-tracker

2. Install Flutter Dependencies
flutter pub get

3. Firebase Setup

Create a new project in Firebase Console
.

Enable:

Authentication → Email/Password

Firestore Database

Add your Firebase config:

Android: android/app/google-services.json

iOS: ios/Runner/GoogleService-Info.plist

Web: firebase_options.dart (via flutterfire configure)

4. Run the App
flutter run

🗂 Firestore Collections
Users

Stores user metadata, points, and badges.

{
  "uid": "abc123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "points": 120,
  "badges": ["Starter", "Consistency Hero"]
}

Habits

Each user’s habit document.

{
  "ownerId": "abc123",
  "ownerName": "John Doe",
  "habitTitle": "Run",
  "streak": 5,
  "frequency": "Daily",
  "createdAt": "2025-09-30T10:00:00.000Z",
  "completedDates": ["2025-09-28", "2025-09-29", "2025-09-30"],
  "points": 50
}

Leaderboard

No separate collection needed — leaderboard is generated dynamically by querying habits filtered by habitTitle and sorted by points.

📊 Leaderboard Query Example
Stream<QuerySnapshot> getLeaderboardByHabit(String habitTitle) {
  return _db
      .collection('habits')
      .where('habitTitle', isEqualTo: habitTitle)
      .orderBy('points', descending: true)
      .limit(10)
      .snapshots();
}

🚀 Roadmap

 Push notifications (reminders for habits)

 Social sharing (share streaks with friends)

 Custom habit creation beyond predefined ones

 Weekly/Monthly habit analytics

🛡 License

MIT License. Free to use & modify.
