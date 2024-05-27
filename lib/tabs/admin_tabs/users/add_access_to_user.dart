import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/components/custom_buttons.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/models/course.dart';
import 'package:increatorkz_admin/mixins/textfields.dart';
import 'package:increatorkz_admin/services/firebase_service.dart';
import 'package:increatorkz_admin/utils/toasts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AddAccessToUser extends ConsumerStatefulWidget {
  const AddAccessToUser({super.key, required this.course});
  final Course course;

  @override
  ConsumerState<AddAccessToUser> createState() => _AddAccessToUserState();
}

class _AddAccessToUserState extends ConsumerState<AddAccessToUser>
    with TextFields {
  final userEmail = TextEditingController();
  final _addBtnCtlr = RoundedLoadingButtonController();
  var formKey = GlobalKey<FormState>();

  void _handleSubmit() async {
    _addBtnCtlr.start();
    final email = userEmail.text;
    if (email.isNotEmpty) {
      final result = await FirebaseService()
          .giveAccessToCourse(widget.course, email, context: context);
      if (result == null) {
        await FirebaseService()
            .updateStudentCountsOnCourse(true, widget.course.id);
        _addBtnCtlr.reset();
        openSuccessToast(context, context.localized.success);
        Navigator.pop(context, true);
      } else {
        _addBtnCtlr.stop();
        openFailureToast(context, result);
      }
    } else {
      _addBtnCtlr.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (context.screenWidth * .8).clamp(200, 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Spacer(),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black)),
            ],
          ),
          buildTextField(
            context,
            controller: userEmail,
            hint: '',
            title: context.localized.email,
            validationRequired: false,
          ),
          const SizedBox(height: 20),
          CustomButtons.submitButton(
            context,
            buttonController: _addBtnCtlr,
            text: context.localized.add,
            onPressed: _handleSubmit,
          )
        ],
      ),
    );
  }
}
