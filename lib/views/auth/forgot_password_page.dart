import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/utils/border_radius_size.dart';
import 'package:todo_app/utils/paddings.dart';
import 'package:todo_app/utils/regex_ext.dart';
import 'package:todo_app/utils/use_error_dialog.dart';
import 'package:todo_app/viewmodel/forgot_password_viewmodel.dart';
import 'package:todo_app/views/auth/widget/auth_form_field.dart';

class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final formKey = GlobalKey<FormState>();
    final forgotPasswordViewModel = ref.watch(forgotPasswordViewModelProvider);
    final forgotPasswordViewModelAsync = ref.watch(
      forgotPasswordViewModelProvider.notifier,
    );

    useErrorDialog(forgotPasswordViewModel, context);

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Column(
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
                    Text(
                      'Enter your email address and we will send you a link to reset your password.',
                    ),
                    SizedBox(height: Paddings.large),
                    AuthFormField(
                      controller: controller,
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      toObscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!value.isValidEmail) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Paddings.large),
                    FilledButton(
                      onPressed: () async {
                        if (forgotPasswordViewModel.isLoading) {
                          return;
                        }

                        if (formKey.currentState?.validate() == true) {
                          await forgotPasswordViewModelAsync.forgotPassword(
                            controller.text,
                          );

                          if (forgotPasswordViewModel is AsyncData<void>) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child:
                          forgotPasswordViewModel.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Reset Password'),
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
