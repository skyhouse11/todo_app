import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/routing/router.dart';
import 'package:todo_app/services/supabase_service.dart';

part 'init_viewmodel.g.dart';

@riverpod
class InitViewModel extends _$InitViewModel {
  @override
  void build() {
    init();
    return;
  }

  Future<void> init() async {
    try {
      await dotenv.load(fileName: "supabase_config.env");
      await ref.read(supabaseServiceProvider).init();
    } catch (error) {
      print(error);
    }

    ref.read(routerProvider).go('/login');
  }
}
