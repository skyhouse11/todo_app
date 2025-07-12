import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:todo_app/services/appwrite_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password);
  Future<void> logout();
  Future<User> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final Account account;

  AuthRepositoryImpl({required this.account});

  @override
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (error) {
      throw _handleAuthError(error);
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      return await account.get();
    } on AppwriteException catch (error) {
      throw _handleAuthError(error);
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      return await getCurrentUser();
    } on AppwriteException catch (error) {
      throw _handleAuthError(error);
    }
  }

  @override
  Future<User> register(String email, String password) async {
    try {
      await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );

      return await login(email, password);
    } on AppwriteException catch (error) {
      throw _handleAuthError(error);
    }
  }

  String _handleAuthError(AppwriteException error) {
    switch (error.code) {
      case 401:
        return 'Invalid credentials';
      case 409:
        return 'User already exists';
      case 400:
        return 'Invalid input data';
      default:
        return error.message ?? 'Authentication error occurred';
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final appwriteService = ref.read(appwriteServiceProvider);

  return AuthRepositoryImpl(account: appwriteService.account);
}
