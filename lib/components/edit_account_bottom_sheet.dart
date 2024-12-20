import 'package:flutter/material.dart';
import '../models/account.dart';
import 'custom_button.dart';
import 'custom_checkbox.dart';
import 'custom_form_field.dart';

class EditAccountBottomSheet extends StatefulWidget {
  final Account? account;
  final void Function(Account) onConfirm;

  const EditAccountBottomSheet({
    required this.onConfirm,
    this.account,
  });

  @override
  State<EditAccountBottomSheet> createState() => _EditAccountBottomSheetState();
}

class _EditAccountBottomSheetState extends State<EditAccountBottomSheet> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.account?.title,
  );
  late final TextEditingController _loginController = TextEditingController(
    text: widget.account?.login,
  );
  late final TextEditingController _passwordController = TextEditingController(
    text: widget.account?.decryptedPassword,
  );
  late bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: IntrinsicHeight(
        child: Column(children: [
          CustomFormField(
            label: 'Title',
            controller: _titleController,
            displayFloatingLabel: true,
            icon: Icons.edit_note,
          ),
          CustomFormField(
            label: 'Login',
            controller: _loginController,
            displayFloatingLabel: true,
            icon: Icons.person,
          ),
          CustomFormField(
            label: 'Password',
            controller: _passwordController,
            displayFloatingLabel: true,
            obscureText: !_showPassword,
            icon: Icons.lock,
          ),
          CustomCheckbox(
            label: 'Show password',
            checked: _showPassword,
            onChecked: (bool? checked) {
              setState(
                () => _showPassword = (checked ?? false),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: CustomButton(
              label: 'Save',
              onSubmit: () => save(context),
              height: 15,
            ),
          ),
        ]),
      ),
    );
  }

  save(BuildContext context) {
    var title = _titleController.value.text;
    var login = _loginController.value.text;
    var password = _passwordController.value.text;

    if (title.isEmpty || login.isEmpty || password.isEmpty) {
      return;
    }

    Navigator.pop(context);

    if (widget.account != null) {
      var editedAccount = widget.account!
        ..update(
          title: title,
          login: login,
          password: password,
        );
        
      widget.onConfirm(editedAccount);
    } else {
      widget.onConfirm(
        Account.create(title: title, login: login, password: password),
      );
    }
  }
}
