import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_models.dart';
import '../domain/booking.dart';
import 'providers.dart';

String errorMessage(Object e) {
  if (e is SlotTakenException || e is BookingLimitException || e is SlotInPastException ||
      e is InvalidEmailDomainException || e is AuthFailure) {
    return e.toString();
  }
  return 'Something went wrong: $e';
}

String two(int n) => n.toString().padLeft(2, '0');
String fmtTime(DateTime d) => '${d.hour}:${two(d.minute)}';
String fmtDateTime(DateTime d) => '${d.day}/${d.month} ${fmtTime(d)}';


void listenBookingActions(BuildContext context, WidgetRef ref) {
  ref.listen<AsyncValue<void>>(bookingActionProvider, (prev, next) {
    final m = ScaffoldMessenger.of(context);
    if (next is AsyncError) {
      m.clearSnackBars();
      m.showSnackBar(SnackBar(content: Text(errorMessage(next.error))));
    } else if (prev is AsyncLoading && next is AsyncData) {
      m.clearSnackBars();
      m.showSnackBar(const SnackBar(content: Text('Done ✔')));
    }
  });
}
