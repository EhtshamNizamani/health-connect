import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentService {
  Future<void> initializePaymentSheet({
    required String clientSecret,
    required String merchantName,
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantName,
      ),
    );
  }

  Future<void> presentPaymentSheet() async {
    await Stripe.instance.presentPaymentSheet();
  }
}
