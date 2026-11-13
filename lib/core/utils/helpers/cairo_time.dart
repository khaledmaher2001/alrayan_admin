import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

/// Store time (Africa/Cairo) without a time-zone database: Egypt is UTC+2,
/// and UTC+3 in summer time (last Friday of April 00:00 → last Thursday of
/// October 24:00, the rule in force since 2023). Scheduled pushes are chosen
/// and shown in Cairo time whatever the phone's own zone is.
class CairoTime {
  CairoTime._();

  static DateTime _lastWeekday(int year, int month, int weekday) {
    var d = DateTime.utc(year, month + 1, 0); // last day of month
    while (d.weekday != weekday) {
      d = d.subtract(const Duration(days: 1));
    }
    return d;
  }

  /// Cairo's offset from UTC at the instant [utc].
  static Duration offsetAt(DateTime utc) {
    final u = utc.toUtc();
    final y = u.year;
    // Summer time starts at local 00:00 (UTC+2) on the last Friday of April…
    final start = _lastWeekday(y, 4, DateTime.friday).subtract(const Duration(hours: 2));
    // …and ends at local 24:00 (UTC+3) on the last Thursday of October.
    final end = _lastWeekday(y, 10, DateTime.thursday).add(const Duration(hours: 24 - 3));
    final summer = !u.isBefore(start) && u.isBefore(end);
    return Duration(hours: summer ? 3 : 2);
  }

  /// Cairo wall-clock time for an instant, as a UTC-flagged DateTime whose
  /// fields (year…minute) read as Cairo time.
  static DateTime wall(DateTime instant) {
    final u = instant.toUtc();
    return u.add(offsetAt(u));
  }

  /// The instant a Cairo wall-clock time means.
  static DateTime fromWall(int year, int month, int day, int hour, int minute) {
    final guess = DateTime.utc(year, month, day, hour, minute);
    var instant = guess.subtract(offsetAt(guess.subtract(const Duration(hours: 2))));
    // Re-check once around the switch-over hour.
    instant = guess.subtract(offsetAt(instant));
    return instant;
  }

  static DateTime now() => wall(DateTime.now());

  /// "Fri 24 Oct · 7:00 PM" in Cairo time, current language, Latin digits.
  static String format(BuildContext context, String? iso) {
    final d = DateTime.tryParse(iso ?? '');
    if (d == null) return '—';
    return formatWall(context, wall(d));
  }

  static String formatWall(BuildContext context, DateTime w) {
    final lang = context.locale.languageCode;
    return dsLatin('${DateFormat('EEE d MMM', lang).format(w)} · ${DateFormat('h:mm a', lang).format(w)}');
  }
}
