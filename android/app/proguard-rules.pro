# Release builds are shrunk by R8. WorkManager (pulled in by plugins) creates its Room
# database by reflection; without these rules the app crashes on start with
# "Failed to create an instance of class androidx.work.impl.WorkDatabase" (2026-11-05).
-keep class androidx.work.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.room.** { *; }
-keep class androidx.startup.** { *; }
-dontwarn androidx.work.**
