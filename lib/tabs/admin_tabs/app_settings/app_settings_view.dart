import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/mixins/appbar_mixin.dart';
import 'package:increatorkz_admin/components/custom_buttons.dart';
import 'package:increatorkz_admin/mixins/textfields.dart';
import 'package:increatorkz_admin/mixins/user_mixin.dart';
import 'package:increatorkz_admin/services/app_service.dart';
import 'package:increatorkz_admin/utils/toasts.dart';
import '../../../models/app_settings_model.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/user_data_provider.dart';
import '../../../services/firebase_service.dart';
import 'app_setting_providers.dart';

class AppSettings extends ConsumerWidget with TextFields {
  const AppSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final isFreeCoursesEnbled = ref.watch(isFreeCoursesEnabledProvider);
    final isFeaturedEnbled = ref.watch(isFeaturedEnabledProvider);
    final isCategoriesEnbaled = ref.watch(isCategoriesEnabledProvider);
    final isTopAuthorsEnabled = ref.watch(isTopAuthorsEnabledProvider);
    final isLatestCoursesEnabled = ref.watch(isLatestCoursesProvider);
    final isTagsEnabled = ref.watch(isTagsEnabledProvider);
    final isSkipLoginEnabled = ref.watch(isSkipLoginEnabledProvider);
    final onBoardingEnabled = ref.watch(isOnboardingEnabledProvider);
    final contentSecurityEnabled = ref.watch(isContentSecurityEnabledProvider);
    final telegramCtrl = ref.watch(telegramProvider);
    final whatsappCtrl = ref.watch(whatsappProvider);
    final websiteCtlr = ref.watch(websiteTextfieldProvider);
    final supportEmailCtlr = ref.watch(supportEmailTextfieldProvider);
    final privacyCtlr = ref.watch(privacyUrlTextfieldProvider);
    final kaspiCtlr = ref.watch(kaspiPaymentLinkProvider);

    final selectedCategoryId1 = ref.watch(selectedHomeCategoryId1Provider);
    final selectedCategoryId2 = ref.watch(selectedHomeCategoryId2Provider);
    final selectedCategoryId3 = ref.watch(selectedHomeCategoryId3Provider);

    final fbCtlr = ref.watch(fbProvider);
    final youtubeCtlr = ref.watch(youtubeProvider);
    final twitterCtrl = ref.watch(twitterProvider);
    final instaCtlr = ref.watch(instaProvider);
    final aboutDescriptionCtrl = ref.watch(aboutDescriptionProvider);
    final aboutImageCtlr = ref.watch(aboutImageProvider);

    final saveBtnCtlr = ref.watch(saveSettingsBtnProvider);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBarMixin.buildTitleBar(context,
              title: context.localized.app_settings,
              buttons: [
                CustomButtons.submitButton(
                  context,
                  buttonController: saveBtnCtlr,
                  text: context.localized.save,
                  width: 170,
                  borderRadius: 25,
                  onPressed: () async {
                    final categories = ref.read(categoriesProvider);
                    final HomeCategory? category1 = selectedCategoryId1 == null
                        ? null
                        : HomeCategory(
                            id: selectedCategoryId1,
                            name: categories
                                .where((element) =>
                                    element.id == selectedCategoryId1)
                                .first
                                .name);

                    final HomeCategory? category2 = selectedCategoryId2 == null
                        ? null
                        : HomeCategory(
                            id: selectedCategoryId2,
                            name: categories
                                .where((element) =>
                                    element.id == selectedCategoryId2)
                                .first
                                .name);

                    final HomeCategory? category3 = selectedCategoryId3 == null
                        ? null
                        : HomeCategory(
                            id: selectedCategoryId3,
                            name: categories
                                .where((element) =>
                                    element.id == selectedCategoryId3)
                                .first
                                .name);

                    final AppSettingsSocialInfo social = AppSettingsSocialInfo(
                        fb: fbCtlr.text,
                        youtube: youtubeCtlr.text,
                        twitter: twitterCtrl.text,
                        instagram: instaCtlr.text);

                    final AppSettingsModel appSettingsModel = AppSettingsModel(
                      featured: isFeaturedEnbled,
                      categories: isCategoriesEnbaled,
                      freeCourses: isFreeCoursesEnbled,
                      topAuthors: isTopAuthorsEnabled,
                      tags: isTagsEnabled,
                      kaspiPaymentUrl: kaspiCtlr.text,
                      onBoarding: onBoardingEnabled,
                      telegram: telegramCtrl.text,
                      whatsapp: whatsappCtrl.text,
                      skipLogin: isSkipLoginEnabled,
                      contentSecurity: contentSecurityEnabled,
                      privacyUrl: privacyCtlr.text,
                      supportEmail: supportEmailCtlr.text,
                      website: websiteCtlr.text,
                      homeCategory1: category1,
                      homeCategory2: category2,
                      homeCategory3: category3,
                      social: social,
                      latestCourses: isLatestCoursesEnabled,
                      aboutDescription: aboutDescriptionCtrl.text,
                      aboutImage: aboutImageCtlr.text,
                    );

                    final data = AppSettingsModel.getMap(appSettingsModel);
                    if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
                      saveBtnCtlr.start();
                      await FirebaseService().updateAppSettings(data);
                      saveBtnCtlr.reset();
                      if (!context.mounted) return;
                      openSuccessToast(context, context.localized.success);
                    } else {
                      openTestingToast(context);
                    }
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                CustomButtons.circleButton(
                  context,
                  icon: Icons.refresh,
                  bgColor: Theme.of(context).primaryColor,
                  iconColor: Colors.white,
                  radius: 22,
                  onPressed: () async {
                    ref.invalidate(appSettingsProvider);
                    openSuccessToast(context, context.localized.success);
                  },
                ),
              ]),
          settings.isRefreshing
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        left: 30, right: 30, top: 20, bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.localized.app_information,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: supportEmailCtlr,
                                    hint: context.localized.email,
                                    title: context.localized.support_email,
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: websiteCtlr,
                                    hint: context.localized.website_url,
                                    title: context.localized.website_url,
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: privacyCtlr,
                                    hint: context.localized.url,
                                    title: context.localized.privacy_policy,
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: kaspiCtlr,
                                    hint: context.localized.url,
                                    title: context.localized.kaspi_payment,
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: aboutDescriptionCtrl,
                                    hint: context.localized.enter,
                                    title: context.localized.about_description,
                                    maxLines: 10,
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: aboutImageCtlr,
                                    hint: context.localized.url,
                                    title: context.localized.about_image,
                                    hasImageUpload: true,
                                    onPickImage: () async {
                                  XFile? image = await AppService.pickImage();
                                  if (image != null) {
                                    final String? imageUrl =
                                        await FirebaseService()
                                            .uploadImageToFirebaseHosting(
                                                image, 'app_settings');
                                    if (imageUrl != null) {
                                      aboutImageCtlr.text = imageUrl;
                                    }
                                  }
                                }, validationRequired: false),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(30),
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.localized.social_information,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: whatsappCtrl,
                                    hint: context.localized.url,
                                    title: 'WhatsApp',
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: telegramCtrl,
                                    hint: context.localized.url,
                                    title: 'Telegram',
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: youtubeCtlr,
                                    hint: context.localized.url,
                                    title: 'Youtube',
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: instaCtlr,
                                    hint: context.localized.url,
                                    title: 'Instagram',
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: twitterCtrl,
                                    hint: context.localized.url,
                                    title: 'Twitter',
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: buildTextField(context,
                                    controller: fbCtlr,
                                    hint: context.localized.url,
                                    title: 'Facebook',
                                    hasImageUpload: false,
                                    validationRequired: false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
