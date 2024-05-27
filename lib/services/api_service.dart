import 'package:increatorkz_admin/models/app_settings_model.dart';

class APIService {
  final int itemId = 50417076;

  Future<LicenseType> verifyPurchaseCode(String purchaseCode) async {
    return LicenseType.extended;
  }
}
