import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/viewmodel/init_viewmodel.dart';

class InitPage extends ConsumerWidget {
  const InitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(initViewModelProvider);

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
