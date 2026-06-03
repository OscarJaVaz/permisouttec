class RtdbRecord {
  const RtdbRecord({required this.id, required this.data});

  final String id;
  final Map<dynamic, dynamic> data;

  String? string(String key) => data[key] as String?;

  bool boolValue(String key, {bool defaultValue = false}) {
    final value = data[key];
    if (value is bool) return value;
    return defaultValue;
  }

  int intValue(String key, {int defaultValue = 0}) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return defaultValue;
  }
}
