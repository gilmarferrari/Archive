import 'package:flutter/material.dart';
import '../utils/encryptions.dart';
import 'custom_button.dart';
import 'custom_checkbox.dart';
import 'custom_form_field.dart';

class MasterKeyBottomSheet extends StatefulWidget {
  const MasterKeyBottomSheet();

  @override
  State<MasterKeyBottomSheet> createState() => _MasterKeyBottomSheetState();
}

class _MasterKeyBottomSheetState extends State<MasterKeyBottomSheet> {
  final TextEditingController _masterKeyController = TextEditingController();
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
            label: 'Master Key',
            controller: _masterKeyController,
            displayFloatingLabel: true,
            obscureText: !_showPassword,
            icon: Icons.lock,
          ),
          CustomCheckbox(
            label: 'Show password',
            checked: _showPassword,
            onChecked: (bool? checked) {
              setState(() => _showPassword = (checked ?? false));
            },
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: CustomButton(
              label: 'Confirm',
              onSubmit: () => confirm(context),
              height: 15,
            ),
          ),
        ]),
      ),
    );
  }

  void confirm(BuildContext context) async {
    var masterKey = _masterKeyController.value.text;

    if (masterKey.isEmpty) {
      return;
    }

    await Encryptions.setMasterKey(masterKey: masterKey)
        .then((isMasterKeyCorrect) {
      if (isMasterKeyCorrect) {
        Navigator.pop(context, true);
      }
    });
  }
}
