class Machinery {
  final int id;
  final String name;
  final String price;
  final String branch;
  final List<String> details;
  final String? videoUrl;
  final String? imageUrl;

  Machinery({
    required this.id,
    required this.name,
    required this.price,
    required this.branch,
    required this.details,
    this.videoUrl,
    this.imageUrl,
  });

  static String _formatPrice(dynamic value) {
    if (value == null) return '\$0';

    final number = num.tryParse(value.toString()) ?? 0;
    final digits = number.toStringAsFixed(0);
    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return '\$$formatted';
  }

  factory Machinery.fromJson(Map<String, dynamic> json) {
    final nameValue = json['nombre'] ?? json['name'] ?? 'Producto';
    final priceValue = json['precio'] ?? json['price'] ?? 0;
    final branchValue = json['sucursal'] ?? json['branch'] ?? 'Sucursal central';
    final descriptionValue = json['descripcion'] ?? json['details'];
    final stockValue = json['stock'] ?? json['cantidad'];
    final conditionValue = json['condicion'] ?? json['estado'];

    final detailsList = <String>[];
    if (descriptionValue is String && descriptionValue.trim().isNotEmpty) {
      detailsList.add(descriptionValue.trim());
    }
    detailsList.add('Precio: ${_formatPrice(priceValue)}');
    if (stockValue != null) {
      detailsList.add('Stock: $stockValue');
    }
    if (conditionValue != null) {
      detailsList.add('Condición: $conditionValue');
    }

    return Machinery(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: nameValue.toString(),
      price: _formatPrice(priceValue),
      branch: branchValue.toString(),
      details: detailsList,
      videoUrl: json['video'] as String?,
      imageUrl: (json['imagen_url'] as String?) ?? (json['image'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'precio': price,
      'sucursal': branch,
      'descripcion': details.join(' | '),
      'video': videoUrl,
      'imagen_url': imageUrl,
    };
  }
}
