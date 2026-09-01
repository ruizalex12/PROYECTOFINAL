class AppConfig {
  static const _defaultSupabaseUrl = 'https://pupdcwklegkeuxkvrzii.supabase.co';
  static const _defaultSupabaseKey =
      'sb_publishable_A9qhHUiD3RvNKw8YA6vtbQ_IaaTJqj6';

  const AppConfig({
    required this.demoMode,
    required this.supabaseUrl,
    required this.supabaseKey,
  });

  final bool demoMode;
  final String supabaseUrl;
  final String supabaseKey;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      demoMode: bool.fromEnvironment('DEMO_MODE', defaultValue: false),
      supabaseUrl: String.fromEnvironment('SUPABASE_URL',
          defaultValue: _defaultSupabaseUrl),
      supabaseKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY',
          defaultValue: _defaultSupabaseKey),
    );
  }

  bool get hasSupabaseConfig =>
      supabaseUrl.trim().isNotEmpty && supabaseKey.trim().isNotEmpty;

  bool get useSupabase => !demoMode && hasSupabaseConfig;

  String get modeLabel => useSupabase ? 'SUPABASE' : 'DEMO';
}
