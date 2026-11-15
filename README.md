# IBA RoomBook

## Seed values (personalised)
ERP / roll number: 29200 -> N = 9200
Rooms: Room-N-1 ... Room-N-6, capacity = (9200 mod 8) + 2 = 0 + 2 = 2, odd rooms floor 1, even floor 2.

## Data model
rooms, bookings, users (as per brief) + `slotLocks/{roomId_slotStartMillis}` (one doc per taken slot;
exists only while a booking is active) and `users/{uid}.activeBookingIds`.
Why: the Flutter SDK's `Transaction.get` cannot run queries, so the transaction guards known document refs.

## Domain restriction is not security
Client-side `contains('iba.edu.pk')` can be bypassed by calling the Firebase Auth REST API directly.
Real enforcement needs a blocking Cloud Function / server-side check.

## No-show handling
Client-side: active + slotEnd passed => shown as expired. Production would use a scheduled Cloud Function.

## Design note (WRITE THIS YOURSELF — 3–5 bullets)
- One real bug you hit in the transaction, how you found it, how you fixed it.

## Known trade-offs
- activeBookingIds is writable by its owner (only `role` is protected) — acceptable here, not for production.

## Seed rooms (create by hand in console, `rooms` collection, document ID = name)
| doc ID / name | floor | capacity |
|---|---|---|
| Room-9200-1 | 1 | 2 |
| Room-9200-2 | 2 | 2 |
| Room-9200-3 | 1 | 2 |
| Room-9200-4 | 2 | 2 |
| Room-9200-5 | 1 | 2 |
| Room-9200-6 | 2 | 2 |
(`floor` and `capacity` are numbers.)

## Setup
1. `flutter create roombook` in a scratch folder; copy its `android/ ios/ ...` platform folders next to this `lib/`, `test/`, `pubspec.yaml` (or copy lib/test/pubspec into the new project).
2. `dart pub global activate flutterfire_cli && flutterfire configure` (creates `lib/firebase_options.dart`).
3. Firebase console: enable Email/Password auth + Firestore, paste `rules.txt` into Rules, deploy `firestore.indexes.json` (or click the console link on the first index error).
4. Sign up two accounts; in console set one `users/{uid}.role` to `admin`.
5. `flutter pub get && flutter analyze && flutter test`

## Admin / rules testing checklist
- As student: edit own `role` -> rejected. Force-cancel someone else's booking -> permission-denied.
- As admin: force-cancel works. Nobody can delete a booking.

## Pagination
Past bookings: `orderBy(slotEnd, desc).startAfterDocument(lastDoc).limit(10)` behind "Load more".
