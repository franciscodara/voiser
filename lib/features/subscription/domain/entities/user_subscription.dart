enum UserPlan {
  free,
  premium,
}

class UserSubscription {
  final UserPlan plan;
  final DateTime? expiresAt;

  const UserSubscription({
    required this.plan,
    this.expiresAt,
  });

  bool get isPremium {
    if (plan == UserPlan.premium) {
      if (expiresAt == null) return true;
      return DateTime.now().isBefore(expiresAt!);
    }
    return false;
  }

  factory UserSubscription.free() {
    return const UserSubscription(plan: UserPlan.free);
  }

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    final planString = json['plan'] as String?;
    final plan = planString == 'premium' ? UserPlan.premium : UserPlan.free;

    DateTime? expiresAt;
    if (json['current_period_end'] != null) {
      expiresAt = DateTime.tryParse(json['current_period_end'] as String);
    }

    return UserSubscription(
      plan: plan,
      expiresAt: expiresAt,
    );
  }
}
