import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseApi {
  static const String url = 'https://saexbzapfzfkzqkunsom.supabase.co';
  static const String anonKey = 'sb_publishable_3YZ2OA5MiOoVoLqFCXcsxw_JIjNlEjY';

  static Future<bool> sendEmailOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$url/auth/v1/otp'),
        headers: {
          'apikey': anonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> verifyEmailOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$url/auth/v1/verify'),
        headers: {
          'apikey': anonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'token': otp}),
      );
      if (response.statusCode == 200) {
        await saveLocalSession(jsonDecode(response.body));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> saveLocalSession(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_session', jsonEncode(user));
    } catch (e) {
      // Silent fail for offline
    }
  }

  static Future<Map<String, dynamic>?> getLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final session = prefs.getString('user_session');
      return session != null ? jsonDecode(session) : null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_session');
    } catch (e) {
      // Silent fail
    }
  }

  static Future<bool> saveItem(String type, String title, Map<String, dynamic> data) async {
    try {
      final session = await getLocalSession();
      if (session == null) return false;

      final response = await http.post(
        Uri.parse('$url/rest/v1/items'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer ${session['access_token']}',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'type': type,
          'title': title,
          'data': data,
          'user_id': session['user']['id'],
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>?> getItems(String type) async {
    try {
      final session = await getLocalSession();
      if (session == null) return null;

      final response = await http.get(
        Uri.parse('$url/rest/v1/items?type=eq.$type&select=*'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer ${session['access_token']}',
        },
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> recordTx(String type, num amount, String title) async {
    try {
      final session = await getLocalSession();
      if (session == null) return false;

      final response = await http.post(
        Uri.parse('$url/rest/v1/transactions'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer ${session['access_token']}',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'type': type,
          'amount': amount,
          'title': title,
          'user_id': session['user']['id'],
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>?> getTransactions() async {
    try {
      final session = await getLocalSession();
      if (session == null) return null;

      final response = await http.get(
        Uri.parse('$url/rest/v1/transactions?select=*'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer ${session['access_token']}',
        },
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : null;
    } catch (e) {
      return null;
    }
  }
}