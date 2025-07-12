import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  Future<User?> build() async => null;

  Future<void> login(String email, String password) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, password),
    );
  }

  Future<void> register(String email, String password) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(email, password),
    );
  }

  Future<void> logout() async {
    state = AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).logout();
      state = AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
