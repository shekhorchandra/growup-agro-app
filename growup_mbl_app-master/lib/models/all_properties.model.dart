class AllPropertiesResponse {
  final String status;
  final List<Property> properties;
  final List<PropertyPackage> propertyPackages;

  AllPropertiesResponse({
    required this.status,
    required this.properties,
    required this.propertyPackages,
  });

  factory AllPropertiesResponse.fromJson(Map<String, dynamic> json) {
    return AllPropertiesResponse(
      status: json['status'],
      properties: (json['properties'] as List)
          .map((e) => Property.fromJson(e))
          .toList(),
      propertyPackages: (json['property_packages'] as List)
          .map((e) => PropertyPackage.fromJson(e))
          .toList(),
    );
  }
}

class Property {
  final int id;
  final String propertyName;

  Property({required this.id, required this.propertyName});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      propertyName: json['property_name'],
    );
  }
}

class PropertyPackage {
  final int id;
  final String packageName;
  final String slug;
  final String imageUrl;
  final int propertyId;
  final String propertyName;

  PropertyPackage({
    required this.id,
    required this.packageName,
    required this.slug,
    required this.imageUrl,
    required this.propertyId,
    required this.propertyName,
  });

  factory PropertyPackage.fromJson(Map<String, dynamic> json) {
    return PropertyPackage(
      id: json['id'],
      packageName: json['package_name'],
      slug: json['slug'],
      imageUrl: json['image_url'],
      propertyId: json['property_id'],
      propertyName: json['property_name'],
    );
  }
}
