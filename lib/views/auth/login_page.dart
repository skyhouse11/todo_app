import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final isLoading = useState<bool>(false);

    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  controller: emailController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  controller: passwordController,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (isLoading.value) {
                      return;
                    }

                    if (formKey.currentState?.validate() == true) {
                      isLoading.value = true;
                    }
                  },
                  child:
                      isLoading.value
                          ? CircularProgressIndicator()
                          : Text('Login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
