import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/services/supabase_service.dart';

part 'auth_repository.g.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> forgotPassword(String email);
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient client;

  AuthRepositoryImpl({required this.client});

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } on AuthException catch (error) {
      throw _handleAuthError(error);
    }
  }

  @override
  Future<User?> getCurrentUser() async => client.auth.currentUser;

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw AuthException('Login failed');
      }
      return response.user!;
    } on AuthException catch (error) {
      throw _handleAuthError(error);
    }
  }

  @override
  Future<User> register(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw AuthException('Registration failed');
      }
      return response.user!;
    } on AuthException catch (error) {
      throw _handleAuthError(error);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } on AuthException catch (error) {
      throw _handleAuthError(error);
    }
  }

  String _handleAuthError(AuthException error) {
    switch (error.statusCode) {
      case '401':
        return 'Invalid credentials';
      case '409':
        return 'User already exists';
      case '400':
        return 'Invalid input data';
      default:
        return error.message.isEmpty
            ? 'Authentication error occurred'
            : error.message;
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return AuthRepositoryImpl(client: supabaseService.client);
}
