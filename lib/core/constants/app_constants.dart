class AppConstants {
  // App Info
  static const String appName = 'MimdTask';
  static const String appVersion = '1.0.0';
  
  // API
  static const String baseUrl = 'https://api.example.com';
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  
  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  static const String userPreferencesKey = 'user_preferences';
  
  // Hive Boxes
  static const String todoBox = 'todos';
  static const String noteBox = 'notes';
  static const String categoryBox = 'categories';
  static const String statisticsBox = 'statistics';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // File Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxAudioDuration = 300; // 5 minutes
  static const List<String> supportedImageFormats = ['.jpg', '.jpeg', '.png', '.gif'];
  static const List<String> supportedAudioFormats = ['.mp3', '.wav', '.m4a', '.aac'];
  
  // Validation
  static const int minTitleLength = 1;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int maxNoteContentLength = 10000;
  
  // AI Settings
  static const int maxAiTokens = 1000;
  static const double aiTemperature = 0.7;
  
  // Navigation Transition Duration
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  
  // Search
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  
  // Chart Settings
  static const int maxChartDataPoints = 30;
  static const List<String> timePeriods = ['Day', 'Week', 'Month'];
  
  // Categories
  static const List<String> defaultCategories = [
    'Work',
    'Personal',
    'Study',
    'Health',
    'Shopping',
    'Travel',
  ];
  
  // Priority Levels
  static const List<String> priorityLevels = [
    'Low',
    'Medium',
    'High',
  ];
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy - HH:mm';
}