import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/components/image_preview.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/models/purchase_model.dart';
import 'package:increatorkz_admin/services/app_service.dart';
import 'package:increatorkz_admin/services/firebase_service.dart';
import 'package:increatorkz_admin/tabs/admin_tabs/purchases/puchase_action_row.dart';
import 'package:increatorkz_admin/utils/custom_cache_image.dart';
import 'package:increatorkz_admin/utils/empty_with_image.dart';

import '../../../mixins/appbar_mixin.dart';

const int _itemsPerPage = 10;

final purchasesQueryProvider = StateProvider<Query>((ref) {
  final query = FirebaseFirestore.instance
      .collection('enrollment_requests')
      .orderBy('timestamp', descending: true);
  return query;
});

class Purchases extends ConsumerWidget {
  const Purchases({Key? key}) : super(key: key);

  Future<PurchaseDetail?> getPurchaseDetail(PurchasePreview preview) =>
      FirebaseService().getPurchaseDetail(preview);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBarMixin.buildTitleBar(context,
              title: context.localized.purshase_hisotory, buttons: []),
          FirestoreQueryBuilder(
            pageSize: _itemsPerPage,
            query: ref.watch(purchasesQueryProvider),
            builder: (context, snapshot, _) {
              if (snapshot.isFetching) return const CircularProgressIndicator();
              if (snapshot.docs.isEmpty) {
                return EmptyPageWithImage(title: context.localized.no_history);
              } else {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (context.screenWidth / 400).round(),
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 30,
                        childAspectRatio: .8,
                      ),
                      itemCount: snapshot.docs.length,
                      itemBuilder: (context, index) {
                        final PurchasePreview preview =
                            PurchasePreview.fromFirestore(snapshot.docs[index]);

                        return FutureBuilder<PurchaseDetail?>(
                          future: getPurchaseDetail(preview),
                          builder: (context, snapshot) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              constraints: const BoxConstraints(minHeight: 800),
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    FullImagePreview(
                                                        imageUrl: preview
                                                            .receiptUrl));
                                          },
                                          child: CustomCacheImage(
                                            imageUrl: preview.receiptUrl,
                                            radius: 10,
                                            withViewer: true,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      if (snapshot.connectionState ==
                                              ConnectionState.waiting ||
                                          snapshot.connectionState ==
                                              ConnectionState.active)
                                        const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      else if (snapshot.hasError ||
                                          snapshot.data == null)
                                        const Text(
                                            'Error loading purchase detail')
                                      else
                                        ...detailFields(
                                            context, snapshot.data!),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: FloatingActionButton.small(
                                      elevation: 0,
                                      onPressed: () async {
                                        final service = FirebaseService();
                                        await service.deleteEnrollmentRequest(
                                            preview.id);
                                        await service
                                            .deleteImage(preview.receiptUrl);
                                      },
                                      backgroundColor: Colors.red,
                                      child: const Icon(
                                        Icons.delete,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> detailFields(BuildContext context, PurchaseDetail data) => [
        buildRow(context, context.localized.course_title, data.course.name),
        buildRow(
          context,
          context.localized.price,
          '${data.course.price} ₸',
        ),
        buildRow(context, context.localized.email, data.user.email),
        buildRow(context, context.localized.phone, data.user.phone ?? '-'),
        buildRow(context, context.localized.date,
            AppService.getDateTime(context, data.createdAt)),
        const SizedBox(height: 10),
        PurchaseActionRow(data),
      ];

  Widget buildRow(BuildContext context, String title, String value) => Row(
        children: [
          Text(
            title,
            style: context.theme.textTheme.titleSmall,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(
              value,
              textAlign: TextAlign.end,
              style: context.theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      );
}
