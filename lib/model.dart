class Product {
  final int id;
  final int tenantId;
  final String name;
  final String description;
  final bool isAvailable;

  Product({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.description,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      tenantId: json['tenantId'],
      name: json['name'],
      description: json['description'],
      isAvailable: json['isAvailable'],
    );
  }
}
