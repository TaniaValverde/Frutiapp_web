import 'dart:convert';

import '../models/access_record.dart';

class AccessLogService {
  final List<AccessRecord> _records = [];

  List<AccessRecord> get records => List.unmodifiable(_records);

  void add(AccessRecord record) {
    _records.add(record);
  }

  void clear() {
    _records.clear();
  }

  String exportJson([List<AccessRecord>? subset]) {
    final data = (subset ?? _records).map((r) => r.toJson()).toList();

    return const JsonEncoder.withIndent(' ').convert(data);
  }

  void importJson(String source) {
    final decoded = jsonDecode(source);

    if (decoded is! List) {
      throw const FormatException('El JSON debe contener una lista');
    }

    final loaded = decoded
        .map((e) => AccessRecord.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    _records
      ..clear()
      ..addAll(loaded);
  }
}
