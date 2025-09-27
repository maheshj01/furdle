class SettingsState {
  final bool isNotificationsEnabled;
  final bool isSoundEnabled;
  final bool isDarkMode;
  final String twitterUsername;

  SettingsState(
      {required this.isNotificationsEnabled,
      required this.isSoundEnabled,
      required this.isDarkMode,
      required this.twitterUsername});

  SettingsState copyWith({
    bool? isNotificationsEnabled,
    bool? isSoundEnabled,
    bool? isDarkMode,
    String? twitterUsername,
  }) {
    return SettingsState(
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      twitterUsername: twitterUsername ?? this.twitterUsername,
    );
  }

  static SettingsState initial() {
    return SettingsState(
      isNotificationsEnabled: true,
      isSoundEnabled: true,
      isDarkMode: false,
      twitterUsername: '',
    );
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      isNotificationsEnabled: json['isNotificationsEnabled'],
      isSoundEnabled: json['isSoundEnabled'],
      isDarkMode: json['isDarkMode'],
      twitterUsername: json['twitterUsername'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isNotificationsEnabled': isNotificationsEnabled,
      'isSoundEnabled': isSoundEnabled,
      'isDarkMode': isDarkMode,
      'twitterUsername': twitterUsername,
    };
  }
}
