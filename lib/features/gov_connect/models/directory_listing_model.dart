/// Directory Listing Model for Gov Connect App

class DirectoryListing {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String listingType;
  final Category category;
  final String phonePrimary;
  final String emailPrimary;
  final String website;
  final String address;
  final String city;
  final String region;
  final double latitude;
  final double longitude;
  final String? logo;
  final String? coverImage;
  final String status;
  final String verificationStatus;
  final double? averageRating;
  final int reviewCount;
  final double? distance;
  final String createdAt;

  DirectoryListing({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.listingType,
    required this.category,
    required this.phonePrimary,
    required this.emailPrimary,
    required this.website,
    required this.address,
    required this.city,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.logo,
    this.coverImage,
    required this.status,
    required this.verificationStatus,
    this.averageRating,
    required this.reviewCount,
    this.distance,
    required this.createdAt,
  });

  factory DirectoryListing.fromJson(Map<String, dynamic> json) {
    return DirectoryListing(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'] ?? '',
      listingType: json['listing_type'],
      category: Category.fromJson(json['category']),
      phonePrimary: json['phone_primary'] ?? '',
      emailPrimary: json['email_primary'] ?? '',
      website: json['website'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      logo: json['logo'],
      coverImage: json['cover_image'],
      status: json['status'],
      verificationStatus: json['verification_status'],
      averageRating: json['average_rating']?.toDouble(),
      reviewCount: json['review_count'] ?? 0,
      distance: json['distance']?.toDouble(),
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'listing_type': listingType,
      'category': category.toJson(),
      'phone_primary': phonePrimary,
      'email_primary': emailPrimary,
      'website': website,
      'address': address,
      'city': city,
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
      'logo': logo,
      'cover_image': coverImage,
      'status': status,
      'verification_status': verificationStatus,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'distance': distance,
      'created_at': createdAt,
    };
  }
}

class Category {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String categoryType;
  final int? parent;
  final List<dynamic> children;
  final String icon;
  final String color;
  final List<String> targetApps;
  final bool isActive;
  final int order;
  final int listingCount;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.categoryType,
    this.parent,
    required this.children,
    required this.icon,
    required this.color,
    required this.targetApps,
    required this.isActive,
    required this.order,
    required this.listingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'] ?? '',
      categoryType: json['category_type'],
      parent: json['parent'],
      children: json['children'] ?? [],
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#000000',
      targetApps: List<String>.from(json['target_apps'] ?? []),
      isActive: json['is_active'] ?? false,
      order: json['order'] ?? 0,
      listingCount: json['listing_count'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'category_type': categoryType,
      'parent': parent,
      'children': children,
      'icon': icon,
      'color': color,
      'target_apps': targetApps,
      'is_active': isActive,
      'order': order,
      'listing_count': listingCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

