import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/routing/routes.dart';
import 'package:todo_app/utils/border_radius_size.dart';
import 'package:todo_app/utils/paddings.dart';
import 'package:todo_app/utils/regex_ext.dart';
import 'package:todo_app/utils/use_error_dialog.dart';
import 'package:todo_app/viewmodel/auth_viewmodel.dart';
import 'package:todo_app/views/auth/widget/auth_form_field.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final emailFocusNode = useFocusNode();
    final passwordFocusNode = useFocusNode();

    final authViewModel = ref.watch(authViewModelProvider);
    final authViewModelAsync = ref.watch(authViewModelProvider.notifier);

    useErrorDialog(authViewModel, context);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthFormField(
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
                      controller: emailController,
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    SizedBox(height: Paddings.medium),
                    AuthFormField(
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
                      controller: passwordController,
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Password',
                      toObscureText: true,
                    ),
                    SizedBox(height: Paddings.medium),
                    FilledButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() == true) {
                          emailFocusNode.unfocus();
                          passwordFocusNode.unfocus();

                          await authViewModelAsync.login(
                            emailController.text,
                            passwordController.text,
                          );

                          if (authViewModel.value != null) {
                            print('User logged in');
                          }
                        }
                      },
                      child:
                          authViewModel.isLoading
                              ? CircularProgressIndicator()
                              : Text('Login'),
                    ),
                    SizedBox(height: Paddings.medium),
                    TextButton(
                      onPressed: () {
                        ForgotPasswordRoute().go(context);
                      },
                      child: Text('Forgot Password?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: Paddings.large),
          Text('Don\'t have an account?', textAlign: TextAlign.center),
          SizedBox(height: Paddings.small),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Paddings.medium),
            child: TextButton(
              onPressed: () {
                SignUpRoute().go(context);
              },
              child: Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}
