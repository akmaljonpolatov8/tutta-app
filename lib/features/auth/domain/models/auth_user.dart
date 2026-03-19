import '../../../premium/domain/models/subscription_plan.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.phone,
    required this.displayName,
    required this.subscriptionPlan,
    required this.countryCode,
    this.accessToken,
  });

  final String id;
  final String phone;
  final String displayName;
  final SubscriptionPlan subscriptionPlan;
  final String countryCode;
  final String? accessToken;

  bool get isPremium => subscriptionPlan == SubscriptionPlan.premium;
}
