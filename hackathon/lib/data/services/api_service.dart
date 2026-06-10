import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../core/result.dart';


class ApiService {
  final String _base = kBaseUrl;

  Map<String, String> _headers(String userId) => {
        'Content-Type': 'application/json',
        'X-User-Id': userId,
      };

  Future<Result<T>> _get<T>(
    String path,
    T Function(dynamic) parse, {
    String? userId,
  }) async {
    try {
      final headers = userId != null ? _headers(userId) : <String, String>{};
      final res = await http.get(Uri.parse('$_base$path'), headers: headers);
      if (res.statusCode == 200) {
        return Success(parse(jsonDecode(res.body)));
      }
      return Failure(_errorMessage(res));
    } catch (e) {
      return Failure('Network error. Is the server running?');
    }
  }

  Future<Result<T>> _post<T>(
    String path,
    Map<String, dynamic> body,
    T Function(dynamic) parse,
    String userId,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_base$path'),
        headers: _headers(userId),
        body: jsonEncode(body),
      );
      if (res.statusCode == 201) return Success(parse(jsonDecode(res.body)));
      if (res.statusCode == 409) {
        return Failure('SLOT_TAKEN');
      }
      return Failure(_errorMessage(res));
    } catch (e) {
      return Failure('Network error. Is the server running?');
    }
  }

  Future<Result<String>> _delete(String path, String userId) async {
    try {
      final res = await http.delete(
        Uri.parse('$_base$path'),
        headers: _headers(userId),
      );
      if (res.statusCode == 200) return const Success('Cancelled');
      return Failure(_errorMessage(res));
    } catch (e) {
      return Failure('Network error. Is the server running?');
    }
  }

  String _errorMessage(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['error'] as String? ?? 'Request failed (${res.statusCode})';
    } catch (_) {
      return 'Request failed (${res.statusCode})';
    }
  }

  Future<Result<List<dynamic>>> getVenues() =>
      _get('/venues', (b) => b as List<dynamic>);

  Future<Result<Map<String, dynamic>>> getSlots(int venueId, String date) =>
      _get('/venues/$venueId/slots?date=$date', (b) => b as Map<String, dynamic>);

  Future<Result<Map<String, dynamic>>> postBooking(
    int slotId,
    String date,
    String userId,
  ) =>
      _post(
        '/bookings',
        {'slot_id': slotId, 'booking_date': date},
        (b) => b as Map<String, dynamic>,
        userId,
      );

  Future<Result<List<dynamic>>> getUserBookings(String userId) =>
      _get('/users/$userId/bookings', (b) => b as List<dynamic>, userId: userId);

  Future<Result<String>> deleteBooking(int bookingId, String userId) =>
      _delete('/bookings/$bookingId', userId);
}
