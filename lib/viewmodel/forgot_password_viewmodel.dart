import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/repositories/auth_repository.dart';

part 'forgot_password_viewmodel.g.dart';

@riverpod
class ForgotPasswordViewModel extends _$ForgotPasswordViewModel {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<void> forgotPassword(String email) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).forgotPassword(email),
    );
  }
}
