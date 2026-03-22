class HostListingDraft {
  const HostListingDraft({
    required this.id,
    required this.hostUserId,
    required this.title,
    required this.city,
    required this.district,
    required this.pricePerNightUsd,
    required this.guests,
    required this.bedrooms,
    required this.amenities,
    required this.imageUrls,
    required this.published,
    required this.updatedAt,
  });

  final String id;
  final String hostUserId;
  final String title;
  final String city;
  final String district;
  final int pricePerNightUsd;
  final int guests;
  final int bedrooms;
  final List<String> amenities;
  final List<String> imageUrls;
  final bool published;
  final DateTime updatedAt;

  HostListingDraft copyWith({
    String? id,
    String? hostUserId,
    String? title,
    String? city,
    String? district,
    int? pricePerNightUsd,
    int? guests,
    int? bedrooms,
    List<String>? amenities,
    List<String>? imageUrls,
    bool? published,
    DateTime? updatedAt,
  }) {
    return HostListingDraft(
      id: id ?? this.id,
      hostUserId: hostUserId ?? this.hostUserId,
      title: title ?? this.title,
      city: city ?? this.city,
      district: district ?? this.district,
      pricePerNightUsd: pricePerNightUsd ?? this.pricePerNightUsd,
      guests: guests ?? this.guests,
      bedrooms: bedrooms ?? this.bedrooms,
      amenities: amenities ?? this.amenities,
      imageUrls: imageUrls ?? this.imageUrls,
      published: published ?? this.published,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static HostListingDraft empty(String hostUserId) {
    return HostListingDraft(
      id: 'draft_$hostUserId',
      hostUserId: hostUserId,
      title: '',
      city: '',
      district: '',
      pricePerNightUsd: 0,
      guests: 1,
      bedrooms: 1,
      amenities: const <String>[],
      imageUrls: const <String>[],
      published: false,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'hostUserId': hostUserId,
      'title': title,
      'city': city,
      'district': district,
      'pricePerNightUsd': pricePerNightUsd,
      'guests': guests,
      'bedrooms': bedrooms,
      'amenities': amenities,
      'imageUrls': imageUrls,
      'published': published,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HostListingDraft.fromJson(Map<String, dynamic> json) {
    return HostListingDraft(
      id: (json['id'] as String?) ?? '',
      hostUserId: (json['hostUserId'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
      district: (json['district'] as String?) ?? '',
      pricePerNightUsd: (json['pricePerNightUsd'] as num?)?.toInt() ?? 0,
      guests: (json['guests'] as num?)?.toInt() ?? 1,
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 1,
      amenities:
          (json['amenities'] as List?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const <String>[],
      imageUrls:
          (json['imageUrls'] as List?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const <String>[],
      published: (json['published'] as bool?) ?? false,
      updatedAt:
          DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
