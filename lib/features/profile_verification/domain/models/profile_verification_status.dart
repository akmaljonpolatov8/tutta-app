enum VerificationState { unverified, pending, verified, rejected }

class ProfileVerificationStatus {
  const ProfileVerificationStatus({
    required this.userId,
    required this.state,
    required this.note,
    required this.updatedAt,
  });

  final String userId;
  final VerificationState state;
  final String note;
  final DateTime updatedAt;

  ProfileVerificationStatus copyWith({
    String? userId,
    VerificationState? state,
    String? note,
    DateTime? updatedAt,
  }) {
    return ProfileVerificationStatus(
      userId: userId ?? this.userId,
      state: state ?? this.state,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static ProfileVerificationStatus initial(String userId) {
    return ProfileVerificationStatus(
      userId: userId,
      state: VerificationState.unverified,
      note: 'Complete your profile and submit verification documents.',
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'state': state.name,
      'note': note,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProfileVerificationStatus.fromJson(Map<String, dynamic> json) {
    final rawState =
        (json['state'] as String?) ?? VerificationState.unverified.name;
    final state = VerificationState.values.firstWhere(
      (item) => item.name == rawState,
      orElse: () => VerificationState.unverified,
    );

    return ProfileVerificationStatus(
      userId: (json['userId'] as String?) ?? '',
      state: state,
      note: (json['note'] as String?) ?? '',
      updatedAt:
          DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
