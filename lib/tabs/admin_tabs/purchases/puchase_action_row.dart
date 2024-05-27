import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/components/custom_buttons.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/models/purchase_model.dart';
import 'package:increatorkz_admin/services/firebase_service.dart';
import 'package:increatorkz_admin/utils/toasts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PurchaseActionRow extends ConsumerStatefulWidget {
  const PurchaseActionRow(this.detail, {super.key});
  final PurchaseDetail detail;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PurchaseActionRowState();
}

class _PurchaseActionRowState extends ConsumerState<PurchaseActionRow> {
  final refuseCntrl = RoundedLoadingButtonController();
  final submitCntrl = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    if (widget.detail.confirmed != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        color: widget.detail.confirmed == true
            ? Colors.green[300]!
            : Colors.red[300]!,
        child: Text(
          widget.detail.confirmed!
              ? context.localized.confirmed
              : context.localized.refused,
          textAlign: TextAlign.center,
          style: context.theme.textTheme.titleMedium
              ?.copyWith(color: Colors.white),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: CustomButtons.submitButton(
            context,
            text: context.localized.refuse,
            buttonController: refuseCntrl,
            onPressed: () async {
              await FirebaseService()
                  .updateEntrollmentRequest(widget.detail.id, false);
            },
            bgColor: Colors.red[300],
          ),
        ),
        Expanded(
          child: CustomButtons.submitButton(
            context,
            text: context.localized.submit,
            buttonController: submitCntrl,
            onPressed: () async {
              final result = await FirebaseService().giveAccessToCourse(
                widget.detail.course,
                widget.detail.user.email,
                context: context,
              );
              if (result == null) {
                await FirebaseService()
                    .updateEntrollmentRequest(widget.detail.id, true);
                await FirebaseService()
                    .updateStudentCountsOnCourse(true, widget.detail.id);
              } else {
                openFailureToast(context, result);
              }
            },
            bgColor: Colors.green[300],
          ),
        ),
      ],
    );
  }
}
