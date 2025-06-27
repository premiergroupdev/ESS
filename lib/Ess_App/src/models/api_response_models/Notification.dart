class Notification_model {
  String? title;
  String? body;
  DateTime? timestamp;
  int? notificationsCount; // New attribute for notifications_count

  Notification_model({
    required this.title,
    required this.body,
    required this.timestamp,
    this.notificationsCount = 0, // Default value
  });

  factory Notification_model.fromJson(Map<String, dynamic> json) {
    return Notification_model(
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      notificationsCount: json['notifications_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp?.toIso8601String(),
      'notifications_count': notificationsCount,
    };
  }
}
