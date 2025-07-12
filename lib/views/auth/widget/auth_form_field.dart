import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:todo_app/utils/border_radius_size.dart';

class AuthFormField extends HookWidget {
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final String labelText;
  final bool toObscureText;

  const AuthFormField({
    this.focusNode,
    required this.keyboardType,
    required this.validator,
    required this.controller,
    this.prefixIcon,
    required this.labelText,
    this.toObscureText = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final obscureText = useState(toObscureText);

    return TextFormField(
      focusNode: focusNode,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon:
            toObscureText
                ? IconButton(
                  icon: Icon(
                    obscureText.value ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    obscureText.value = !obscureText.value;
                  },
                )
                : null,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BorderRadiusSize.medium),
        ),
      ),
      controller: controller,
      obscureText: toObscureText ? obscureText.value : false,
    );
  }
}
