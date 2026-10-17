class ItemModel {
  final String id;
  final String sku;
  final String name;
  final String category;
  final int qty;
  final String unit;
  final int minStock;
  final String location;
  final String zone;
  final String status;

  ItemModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.qty,
    required this.unit,
    required this.minStock,
    required this.location,
    required this.zone,
    required this.status,
  });

  bool get isLowStock => qty <= minStock && qty > 0;
  bool get isOutOfStock => qty <= 0;
  bool canDispatch(int requestedQty) => requestedQty > 0 && requestedQty <= qty;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      qty: (json['qty'] as num).toInt(),
      unit: json['unit'] as String? ?? 'Pcs',
      minStock: (json['min_stock'] as num?)?.toInt() ?? 15,
      location: json['location'] as String? ?? 'Gudang',
      zone: json['zone'] as String? ?? 'A',
      status: json['status'] as String? ?? 'Tersedia',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'qty': qty,
      'unit': unit,
      'min_stock': minStock,
      'location': location,
      'zone': zone,
      'status': status,
    };
  }
}
