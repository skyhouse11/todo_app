import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/utils/border_radius_size.dart';
import 'package:todo_app/utils/paddings.dart';
import 'package:todo_app/utils/regex_ext.dart';
import 'package:todo_app/utils/use_error_dialog.dart';
import 'package:todo_app/viewmodel/auth_viewmodel.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final emailFocusNode = useFocusNode();
    final passwordFocusNode = useFocusNode();

    final isPasswordVisible = useState(false);

    final authViewModel = ref.watch(authViewModelProvider);
    final authViewModelAsync = ref.watch(authViewModelProvider.notifier);

    useErrorDialog(authViewModel, context);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            margin: EdgeInsets.all(Paddings.medium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BorderRadiusSize.medium),
            ),
            child: Padding(
              padding: EdgeInsets.all(Paddings.medium),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      focusNode: emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null) {
                          return 'Email is required';
                        }
                        if (!value.isValidEmail) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            BorderRadiusSize.medium,
                          ),
                        ),
                      ),
                      controller: emailController,
                    ),
                    SizedBox(height: Paddings.medium),
                    TextFormField(
                      focusNode: passwordFocusNode,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value == null) {
                          return 'Password is required';
                        }
                        if (!value.isValidPassword) {
                          return 'Please enter a valid password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            BorderRadiusSize.medium,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            isPasswordVisible.value = !isPasswordVisible.value;
                          },
                        ),
                      ),
                      controller: passwordController,
                      obscureText: !isPasswordVisible.value,
                    ),
                    SizedBox(height: Paddings.large),
                    FilledButton.icon(
                      icon: Icon(Icons.login),
                      onPressed: () async {
                        if (formKey.currentState?.validate() == true) {
                          emailFocusNode.unfocus();
                          passwordFocusNode.unfocus();

                          await authViewModelAsync.login(
                            emailController.text,
                            passwordController.text,
                          );
                        }
                      },
                      label:
                          authViewModel.isLoading
                              ? CircularProgressIndicator()
                              : Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
