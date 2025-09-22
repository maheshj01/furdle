class SettingsState {
  final bool isNotificationsEnabled;
  final bool isSoundEnabled;
  final bool isDarkMode;

  SettingsState(
      {required this.isNotificationsEnabled,
      required this.isSoundEnabled,
      required this.isDarkMode});

  SettingsState copyWith({
    bool? isNotificationsEnabled,
    bool? isSoundEnabled,
    bool? isDarkMode,
  }) {
    return SettingsState(
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  static SettingsState initial() {
    return SettingsState(
      isNotificationsEnabled: true,
      isSoundEnabled: true,
      isDarkMode: false,
    );
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      isNotificationsEnabled: json['isNotificationsEnabled'],
      isSoundEnabled: json['isSoundEnabled'],
      isDarkMode: json['isDarkMode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isNotificationsEnabled': isNotificationsEnabled,
      'isSoundEnabled': isSoundEnabled,
      'isDarkMode': isDarkMode,
    };
  }
}
