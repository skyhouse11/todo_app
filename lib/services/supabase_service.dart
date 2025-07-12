import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'supabase_service.g.dart';

class SupabaseService {
  late final SupabaseClient _client;

  SupabaseClient get client => _client;
  GoTrueClient get auth => _client.auth;

  // Configuration
  late final String _supabaseUrl;
  late final String _supabaseAnonKey;

  void getConfig() {
    _supabaseUrl = dotenv.get('SUPABASE_URL');
    _supabaseAnonKey = dotenv.get('SUPABASE_ANON_KEY');
  }

  Future<void> init() async {
    getConfig();
    final supabase = await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );

    _client = supabase.client;
  }
}

@Riverpod(keepAlive: true)
SupabaseService supabaseService(Ref ref) {
  return SupabaseService();
}
