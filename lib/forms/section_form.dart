import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/components/custom_buttons.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/utils/reponsive.dart';
import 'package:increatorkz_admin/mixins/textfields.dart';
import 'package:increatorkz_admin/mixins/user_mixin.dart';
import 'package:increatorkz_admin/models/section.dart';
import 'package:increatorkz_admin/services/firebase_service.dart';
import 'package:increatorkz_admin/utils/toasts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../providers/user_data_provider.dart';

class SectionForm extends ConsumerStatefulWidget {
  final String courseId;
  final Section? section;

  const SectionForm({Key? key, required this.courseId, required this.section})
      : super(key: key);

  @override
  ConsumerState<SectionForm> createState() => _SectionFormState();
}

class _SectionFormState extends ConsumerState<SectionForm> with TextFields {
  var nameCtlr = TextEditingController();
  final btnCtlr = RoundedLoadingButtonController();
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.section != null) {
      nameCtlr.text = widget.section!.name;
    }
  }

  void handleSubmit() async {
    if (UserMixin.hasAccess(ref.read(userDataProvider))) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        final navigator = Navigator.of(context);
        btnCtlr.start();
        await _handleUpload();
        btnCtlr.success();
        navigator.pop();
      }
    } else {
      openTestingToast(context);
    }
  }

  _handleUpload() async {
    await FirebaseService().saveSection(widget.courseId, _sectionData());
  }

  Section _sectionData() {
    final String id = widget.section?.id ?? FirebaseService.getUID('sections');
    final int order = widget.section?.order ?? 0;
    final Section section = Section(
      id: id,
      name: nameCtlr.text,
      order: order,
    );
    return section;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomButtons.submitButton(
          context,
          width: 300,
          buttonController: btnCtlr,
          text: widget.section == null
              ? context.localized.create
              : context.localized.update,
          onPressed: handleSubmit,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20, top: 10),
              child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ))),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 20 : 50),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTextField(context,
                  controller: nameCtlr,
                  hint: context.localized.enter,
                  title: context.localized.title,
                  hasImageUpload: false),
            ],
          ),
        ),
      ),
    );
  }
}
