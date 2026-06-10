# QuickSlot Frontend Guide

This document explains the Flutter app file-by-file for demo and defense. The frontend is built as a simple clean architecture app:

- `core/`: shared constants, result wrapper, notifications
- `data/`: models, HTTP service, repositories
- `presentation/`: providers, screens, reusable widgets
- `theme/`: app-wide Material theme

The main rule is: widgets do not call HTTP directly. Screens call providers, providers call repositories, repositories call `ApiService`.

## Runtime Flow

1. `main.dart` initializes Flutter, AdMob, local notifications, repositories, and providers.
2. `LoginScreen` lets the judge pick one hardcoded demo user.
3. `VenueListScreen` fetches venues from `GET /venues`.
4. `VenueDetailScreen` fetches slots for a selected date from `GET /venues/:id/slots`.
5. User taps an available `SlotTile`, confirms in a bottom sheet, and sends `POST /bookings`.
6. On success, the slot grid refreshes and a local notification is shown.
7. If the backend returns `409`, the app shows a clear "slot just taken" message and refreshes the grid.
8. `MyBookingsScreen` fetches `GET /users/:id/bookings` and can cancel with `DELETE /bookings/:id`.

## State Management Choice

The app uses `Provider` with `ChangeNotifier`.

Why this choice:

- Easy to explain in a defense round.
- Small app with simple async state does not need Bloc/Riverpod complexity.
- Providers keep business state out of widgets.
- Each feature has a focused provider: user, venues, slots, bookings.

Common state shape:

- `ViewState.idle`: screen has not loaded yet.
- `ViewState.loading`: API request in progress.
- `ViewState.data`: data loaded successfully.
- `ViewState.error`: request failed and screen shows retry UI.

## Core Files

### `lib/core/constants.dart`

Stores values shared across the app.

- `kBaseUrl`: backend URL.
  - Android emulator uses `http://10.0.2.2:3000`.
  - Physical device should use laptop LAN IP or deployed backend URL.
- `kUsers`: hardcoded demo users matching backend `X-User-Id` users.

Defense point: hardcoded users are acceptable because the problem statement explicitly says light auth is fine.

### `lib/core/result.dart`

Defines a sealed `Result<T>` type.

- `Success<T>` carries parsed data.
- `Failure<T>` carries a user-readable message.
- `when()` forces success and failure handling at call sites.

Why it exists:

- Avoids throwing exceptions through UI code.
- Makes repository/provider code predictable.
- Keeps API error handling consistent.

### `lib/core/notifications.dart`

Wraps `flutter_local_notifications`.

- `init()` configures Android notification initialization.
- `showBookingConfirmed()` shows a local notification after successful booking.

This is a bonus polish feature. It does not affect booking correctness.

## Data Layer

### `lib/data/services/api_service.dart`

Lowest-level HTTP client.

Responsibilities:

- Builds URLs from `kBaseUrl`.
- Adds `Content-Type` and `X-User-Id` headers where required.
- Converts HTTP responses into `Result`.
- Maps `409 Conflict` from booking API into special failure code `SLOT_TAKEN`.
- Converts network errors into "Network error. Is the server running?"

Important methods:

- `getVenues()`: calls `GET /venues`.
- `getSlots(int venueId, String date)`: calls `GET /venues/:id/slots?date=YYYY-MM-DD`.
- `postBooking(int slotId, String date, String userId)`: calls `POST /bookings`.
- `getUserBookings(String userId)`: calls `GET /users/:id/bookings`.
- `deleteBooking(int bookingId, String userId)`: calls `DELETE /bookings/:id`.

Defense point: only this file knows HTTP status codes. UI only sees success/failure.

### `lib/data/models/venue.dart`

Domain model for a sports venue.

Fields:

- `id`
- `name`
- `sport`
- `address`
- `locality`
- `rating`
- `reviewCount`
- `sourceName`
- `sourceUrl`
- `openTime`
- `closeTime`

`Venue.fromJson()` maps backend JSON to Dart object.

### `lib/data/models/slot.dart`

Domain model for one hourly slot.

Fields:

- `id`
- `venueId`
- `startTime`
- `endTime`
- `isBooked`
- `bookedBy`

Backend sends `is_booked` as `0/1`; the model converts it to a Dart `bool`.

### `lib/data/models/booking.dart`

Domain model for a confirmed booking.

Fields:

- `id`
- `slotId`
- `userId`
- `bookingDate`
- `startTime`
- `endTime`
- `venueId`
- `venueName`
- `sport`
- `address`

This model is used by the booking success flow and My Bookings list.

### `lib/data/repositories/venue_repository.dart`

Converts raw API data into typed models.

Methods:

- `getVenues()`: returns `Result<List<Venue>>`.
- `getSlotsForDate()`: returns `Result<(Venue, List<Slot>)>`.

Why repository layer exists:

- Keeps JSON parsing out of providers.
- Makes provider code easier to read and test.

### `lib/data/repositories/booking_repository.dart`

Converts booking API responses into `Booking` models.

Methods:

- `bookSlot()`: returns created `Booking`.
- `getUserBookings()`: returns user booking list.
- `cancelBooking()`: returns cancellation result.

Defense point: if API JSON shape changes, repository/model layer is the only place that should need updates.

## Provider Layer

### `lib/presentation/providers/user_provider.dart`

Stores selected demo user.

State:

- `_userId`
- `_userName`
- `isLoggedIn`

Methods:

- `login(id, name)`
- `logout()`

This keeps user selection available across screens.

### `lib/presentation/providers/venue_provider.dart`

Controls venue list screen state.

State:

- `ViewState state`
- `List<Venue> venues`
- `String? errorMessage`

Method:

- `fetchVenues()`

Flow:

1. Set `state = loading`.
2. Call repository.
3. On success, store venues and set `data`.
4. On failure, store message and set `error`.
5. Notify UI with `notifyListeners()`.

### `lib/presentation/providers/slot_provider.dart`

Controls venue detail slot grid.

State:

- `ViewState state`
- `List<Slot> slots`
- `Venue? venue`
- `String? errorMessage`
- `DateTime selectedDate`
- polling timer

Methods:

- `loadSlots(venueId)`: first load and starts polling.
- `changeDate(date, venueId)`: updates selected date and reloads.
- `refresh(venueId)`: fetches without resetting selected date.
- `_startPolling(venueId)`: refreshes every 10 seconds.

Defense point: polling is the bonus slot update feature. It keeps another device's booking visible without restarting the app.

### `lib/presentation/providers/booking_provider.dart`

Controls booking actions and My Bookings list.

State:

- `ViewState listState`
- `BookingAction actionState`
- `List<Booking> bookings`
- `Booking? lastBooking`
- `String? errorMessage`

`BookingAction` values:

- `idle`
- `loading`
- `success`
- `slotTaken`
- `error`

Methods:

- `fetchBookings(userId)`
- `bookSlot(slotId, date, userId)`
- `cancelBooking(bookingId, userId)`
- `resetAction()`

Important logic:

- If repository failure is `SLOT_TAKEN`, state becomes `slotTaken`.
- UI uses this to show the graceful conflict message and refresh the slot grid.

## Screens

### `lib/main.dart`

App entry point.

Responsibilities:

- Calls `WidgetsFlutterBinding.ensureInitialized()`.
- Initializes AdMob and notifications.
- Creates shared `ApiService`.
- Creates repositories.
- Registers providers with `MultiProvider`.
- Starts app at `LoginScreen`.

Defense point: dependencies are created once and injected down through providers.

### `lib/presentation/screens/login_screen.dart`

First screen.

What it does:

- Shows QuickSlot branding.
- Lists hardcoded users from `kUsers`.
- On tap, saves selected user in `UserProvider`.
- Navigates to `VenueListScreen`.

There is no password/auth flow because the hackathon brief allows hardcoded users.

### `lib/presentation/screens/venue_list_screen.dart`

Venue browsing screen.

Lifecycle:

- In `initState`, schedules `fetchVenues()` after first frame.

UI:

- App bar with QuickSlot title.
- My Bookings button.
- Logout button.
- User greeting.
- AdMob banner.
- Venue list with loading/error/empty/data states.

Data state handling:

- Loading: `VenueListSkeleton`.
- Error: `AppError` with retry.
- Empty: `EmptyState`.
- Data: `ListView.builder` of `VenueCard`.

### `lib/presentation/screens/venue_detail_screen.dart`

Most important frontend screen.

Responsibilities:

- Shows selected venue details.
- Lets user pick date.
- Displays hourly slot grid.
- Opens confirmation bottom sheet for available slots.
- Handles success, conflict, and error after booking.

Important methods:

- `initState()`: loads slots for venue.
- `_pickDate()`: opens Flutter date picker for today through next 30 days.
- `_onSlotTap(slot)`: opens `_BookingSheet`.
- `_buildGrid(provider)`: renders skeleton/error/empty/grid state.

Conflict flow:

1. User taps available slot.
2. `_BookingSheet` calls `bookingProvider.bookSlot()`.
3. If backend returns `409`, `BookingProvider` sets `slotTaken`.
4. Sheet closes.
5. Red snackbar says slot was just taken.
6. Slot grid refreshes immediately.

Success flow:

1. Backend returns `201`.
2. Sheet closes.
3. Green success snackbar appears.
4. Local notification is shown.
5. Slot grid refreshes immediately.

### `lib/presentation/screens/my_bookings_screen.dart`

User bookings screen.

Lifecycle:

- In `initState`, fetches bookings for current user.

UI:

- Shows count chip when bookings exist.
- Loading: `BookingListSkeleton`.
- Error: `AppError`.
- Empty: `EmptyState`.
- Data: list of `BookingCard`.

Cancel flow:

1. User taps cancel icon.
2. Confirmation dialog opens.
3. If confirmed, provider calls `DELETE /bookings/:id`.
4. On success, booking is removed from local list and snackbar is shown.

## Widgets

### `lib/presentation/widgets/app_states.dart`

Shared state widgets:

- `AppLoading`: centered spinner.
- `AppError`: message, retry button.
- `EmptyState`: icon and message.

Purpose: every screen handles loading, error, and empty states consistently.

### `lib/presentation/widgets/skeleton_loaders.dart`

Shimmer loading placeholders.

Widgets:

- `VenueListSkeleton`
- `SlotGridSkeleton`
- `BookingListSkeleton`

Purpose: gives a polished loading experience instead of blank screens.

### `lib/presentation/widgets/venue_card.dart`

Reusable venue card.

Displays:

- Sport icon.
- Venue name.
- Locality.
- Address.
- Sport badge.
- Hours badge.
- Rating when available.
- Verified source name.
- Chevron.

Sport color:

- Badminton: cyan.
- Football/turf: green.

### `lib/presentation/widgets/slot_tile.dart`

Slot grid tile.

Logic:

- If `slot.isBooked`, tile is red, locked, disabled.
- If available, tile is green, tappable, and opens booking confirmation.

Why this matters: frontend prevents obvious double taps on already booked slots, while backend remains the final source of truth.

### `lib/presentation/widgets/booking_card.dart`

Reusable card for My Bookings.

Displays:

- Venue name.
- Address.
- Sport icon.
- Booking date.
- Time range.
- Cancel button.

Cancel button calls the callback passed by `MyBookingsScreen`.

### `lib/presentation/widgets/admob_banner.dart`

Loads a Google Mobile Ads test banner.

Important notes:

- Uses test ad unit ID.
- If ad fails, it disposes the ad.
- Returns a fixed-height placeholder while loading.

This is demo polish, not core booking logic.

## Theme

### `lib/theme/app_theme.dart`

Defines dark Material 3 theme.

Central colors:

- Available: green.
- Booked/error: red.
- Background: near black.
- Surface/card: dark gray.

Also defines:

- Poppins text theme.
- App bar style.
- Card style.
- Elevated button style.

Defense point: central theme avoids duplicated styling and keeps the app visually consistent.

## Frontend Defense Talking Points

- The app is layered: screen -> provider -> repository -> API service.
- Provider was chosen because the state is simple and explainable.
- The backend is still the source of truth; frontend disabled slots are only UX.
- `409 Conflict` is handled as a first-class booking outcome.
- Every main screen has loading, error, empty, and data states.
- Polling refreshes slot status every 10 seconds.
- Immediate refresh after booking keeps the UI honest during live demo.
- Local notification and AdMob are bonus polish features, not required for correctness.

## Likely Live Change Areas

If asked to make a small live change, these are safe places:

- Change polling interval in `slot_provider.dart`.
- Add a fourth hardcoded user in `constants.dart` and backend `auth.js`.
- Change slot tile colors in `app_theme.dart`.
- Add a new message in `_showTakenSnackbar()`.
- Add another field to `VenueCard`.
