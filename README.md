IBA RoomBook

Real-time study-room booking for the IBA library. Flutter + Riverpod + Cloud Firestore + Firebase Authentication. Students see live availability for the next 7 days and book 30-minute slots; bookings can never collide, even when two students tap the same slot at the same moment.

Branch: feature/roombook | Course: CSE-450 Application Development for Mobile Devices | ERP: 29200

Personalised seed data

ERP 29200 -> N = 9200 (last 4 digits). Capacity = (9200 mod 8) + 2 = 0 + 2 = 2 for every room (9200 = 8 x 1150, remainder 0). Odd rooms on floor 1, even rooms on floor 2.

Room (doc ID = name)	Floor	Capacity
Room-9200-1	1	2
Room-9200-2	2	2
Room-9200-3	1	2
Room-9200-4	2	2
Room-9200-5	1	2
Room-9200-6	2	2

Seeded by hand in the Firebase console (floor and capacity stored as int64).

Architecture

Clean Architecture, three layers:

lib/domain/ – entities (Booking, Room, AppUser), exceptions, BookingPolicy, repository interfaces. No Flutter or Firebase imports.
lib/data/ – Firestore/Auth implementations of those interfaces. All Firestore calls live here, never in widgets or provider build methods.
lib/presentation/ – Riverpod providers, screens, widgets.

Riverpod usage:

StreamProvider.family<List<Booking>, ({roomId, day})> – live bookings per room per day (.snapshots()).
StreamProvider.family – the logged-in user's upcoming bookings.
StreamProvider – current user (auth state + users/{uid} doc, which carries the role) and rooms.
AsyncNotifierProvider – booking/cancel action (loading state + error surfaced to the UI) and auth actions.
AsyncNotifierProvider.family – paginated past bookings.
No BuildContext inside any provider. Snackbars are triggered in widgets via ref.listen.
Data model (Cloud Firestore)
Collection	Fields	Notes
rooms	name, floor, capacity	6 rooms, seeded by hand
bookings	roomId, date, slotStart, slotEnd, userId, userName, status, createdAt (+ cancelledAt)	slotStart/slotEnd are Firestore Timestamps. status: active / cancelled (expired and completed are derived on the client)
users	uid, name, email, role, activeBookingIds	role: student / admin
slotLocks	bookingId, userId	One doc per taken slot. Doc ID = {roomId}_{slotStartMillis}. Exists only while the booking is active

Slots: fixed 30-minute blocks, 9:00 AM to 9:00 PM = 24 per room per day. Slot length is the single constant kSlotMinutes in lib/domain/booking.dart; the number of slots and the grid are derived from it.

Why slotLocks and activeBookingIds exist

The Flutter Firestore SDK's Transaction.get() accepts only a document reference, not a query. A transaction therefore cannot "query all active bookings for this slot / this user". To make both checks atomic:

Double-booking: each slot has exactly one possible lock document (slotLocks/{roomId_slotStartMillis}). The transaction reads that document; if it exists, the slot is taken.
2-active-booking cap: users/{uid}.activeBookingIds lists the user's booking IDs. The transaction re-reads each of those booking documents by reference and counts those that are still active and have not yet ended. Cancelled or expired ones are dropped from the list on the next booking.

This adds a fourth collection to the brief's three. That is a deliberate design trade-off.

The booking transaction

FirestoreBookingRepository.book() uses runTransaction():

Reject slots whose end time has already passed.
Reads (all before any write): the slot-lock document, the user document, then each booking in activeBookingIds.
If the lock exists -> throw SlotTakenException ("Someone just booked this - pick another slot").
If the user already has 2 live bookings -> throw BookingLimitException.
Writes: create the booking, create the slot lock, update activeBookingIds.

If another student's transaction changes a document this one read before it commits, Firestore automatically retries the transaction; on the retry it sees the lock and throws SlotTakenException. So exactly one of two simultaneous taps succeeds.

On Flutter web, exceptions thrown inside the transaction callback come back wrapped, so book() catches them and _translate() converts them back into the typed exceptions (see the design note).

Cancellation is a batch: set status = 'cancelled' on the booking (never deleted) and delete the slot lock, which frees the slot immediately.

Authentication

Email + password via Firebase Auth. Sessions persist across restarts (the SDK restores the signed-in user; the app listens to authStateChanges()). Sign-up creates users/{uid} with role: 'student'.

Why the domain check alone is not a security guarantee

Only emails containing iba.edu.pk are accepted, and this is validated client-side before calling Firebase. This is a usability filter, not security: anyone can bypass the app and call the Firebase Auth REST API directly with any email address, and an email containing the string iba.edu.pk is not proof of owning an IBA mailbox (e.g. x@iba.edu.pk.evil.com). Real enforcement needs server-side checks (a blocking Cloud Function on sign-up and email verification).

Admin mode

There is no shared admin account. A second test account was registered and its users/{uid}.role was set to admin manually in the Firebase console. Admins get an extra Admin tab showing every room's full grid for the selected day (same 7-day window) with student names, and can tap a booked slot to force-cancel it.

Firestore Security Rules (rules.txt)
Signed-in users can read rooms, bookings, users and slot locks.
Rooms cannot be written from the client.
Booking create requires userId == request.auth.uid and status == 'active'.
Booking update: admin can update any; an owner can only change status to cancelled (and cancelledAt), and only before the slot's start time.
Bookings can never be deleted from the client.
Users can create/update only their own users/{uid} document and cannot change role (the self-promotion trap); sign-up must create role student.
slotLocks: create only with your own uid; delete only by the lock's owner or an admin; no updates.
Rules test results

Tested with a student account (lib/attack_main.dart, which signs in as a student and sends the requests directly to Firestore, bypassing the UI) and with the admin account in the app.

[x] As a student, set own role to admin -> rejected (permission-denied)
[x] As a student, edit own name -> allowed
[x] As a student, cancel another student's booking -> rejected (permission-denied)
[x] As a student, create a booking with someone else's userId -> rejected (permission-denied)
[x] Delete a booking from the client -> rejected (permission-denied)
[x] As a student, edit a room -> rejected (permission-denied)
[x] As admin, force-cancel a student's booking -> works
No-show handling

A booking that is still active after its slotEnd is displayed as expired (Booking.effectiveStatus). This is a client-side check, which is sufficient for this assignment; a production system would flip the status with a scheduled Cloud Function. Expired bookings do not count toward the 2-booking cap.

Pagination

Past bookings (slot already ended) load 10 at a time using orderBy('slotEnd', descending: true).startAfterDocument(lastDoc).limit(10) behind a Load more button.

Composite indexes (firestore.indexes.json)
Query	Fields
Room grid	roomId ASC, status ASC, slotStart ASC
My bookings (upcoming)	userId ASC, slotEnd ASC
Past bookings (newest first)	userId ASC, slotEnd DESC
Tests
flutter test

Unit tests with a fake repository (no widgets, no live Firestore):

Slot already taken -> notifier surfaces SlotTakenException.
Third active booking -> notifier surfaces BookingLimitException.
Successful booking -> AsyncData.
BookingPolicy ignores cancelled and expired bookings in the cap; active-but-ended shows as expired.
Email domain validator.

Manual / integration scripts (separate entry points, not part of the app):

lib/race_main.dart – fires two booking attempts for the same slot at the same instant. Result: exactly one SUCCESS and one FAILED -> Someone just booked this. flutter run -d chrome -t lib/race_main.dart
lib/attack_main.dart – signs in as a student and attempts forbidden writes against the live rules (results above). Credentials are passed with --dart-define, nothing is stored in the code. flutter run -d chrome -t lib/attack_main.dart --dart-define="EMAIL=..." --dart-define="PASS=..."
Running the project
flutter pub get
flutterfire configure --project=iba-roombook-98bf4   # android + web
flutter run -d chrome        # or an Android device/emulator
flutter analyze
flutter test

Firebase console setup: enable Email/Password auth and Firestore; paste rules.txt into the Firestore Rules tab; create the three composite indexes above.

To test live updates with two users at once, use two Chrome profiles (or one normal + one Incognito window): sessions are shared within a single browser profile.

Design note (personal)
When I tried a third booking while already holding two, the cap did reject it, but the snackbar read "Something went wrong: Error: Dart exception: You already have 2 active bookings" instead of my clean message.
My UI decides what to show with is BookingLimitException / is SlotTakenException checks. Those failed because on Flutter web, an exception thrown inside the runTransaction callback comes back wrapped as a generic error, so it fell into the "something went wrong" branch.
I found this by reading the snackbar text: my original message was inside the wrapped string, which told me the transaction logic was right and only the error type had been lost.
I fixed it in the data layer: book() now wraps runTransaction in a try/catch, and a _translate() helper turns the wrapped error back into my typed exceptions by matching its message. The notifier and UI code did not change.
I re-tested by hitting the cap again (clean message), then running my race script with two simultaneous bookings for one slot: one SUCCESS, one "Someone just booked this". Weakness: matching on message text is brittle; error codes would be sturdier.
Known limitations
activeBookingIds and slotLocks are writable by their owner under the rules, so a determined user could tamper with their own cap tracking. Production would move booking creation behind a Cloud Function.
Expiry is computed on the client.
The domain check is client-side only (see above).
Exception translation in _translate() relies on message text.