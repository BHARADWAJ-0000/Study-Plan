import 'dart:convert';

import 'package:http/http.dart' as http;

class MonkeymaxApi {
  static const _defaultUrl = String.fromEnvironment(
    'MONKEYMAX_API_URL',
    defaultValue: 'http://10.0.2.2:8787',
  );

  Future<GeneratedPlan> generatePlan({required String topic, int days = 7}) async {
    final response = await http.post(
      Uri.parse('$_defaultUrl/generate-plan'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'topic': topic, 'days': days}),
    ).timeout(const Duration(seconds: 12));

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(payload['error'] ?? 'The study service is unavailable');
    }

    return GeneratedPlan.fromJson(payload);
  }
}

class GeneratedPlan {
  final String source;
  final List<GeneratedDay> days;

  const GeneratedPlan({required this.source, required this.days});

  factory GeneratedPlan.fromJson(Map<String, dynamic> json) {
    final entries = (json['plan'] as List<dynamic>? ?? const []);
    return GeneratedPlan(
      source: json['source'] as String? ?? 'offline',
      days: entries
          .whereType<Map<String, dynamic>>()
          .map(GeneratedDay.fromJson)
          .toList(),
    );
  }
}

class GeneratedDay {
  final int day;
  final String title;
  final List<String> tasks;

  const GeneratedDay({required this.day, required this.title, required this.tasks});

  factory GeneratedDay.fromJson(Map<String, dynamic> json) {
    return GeneratedDay(
      day: (json['day'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? 'Study session',
      tasks: (json['tasks'] as List<dynamic>? ?? const []).whereType<String>().toList(),
    );
  }
}
