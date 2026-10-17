class AuditModel {
  final String? id;
  final String itemId;
  final int systemStock;
  final int physicalStock;
  final int discrepancy;
  final String reason;

  AuditModel({
    this.id,
    required this.itemId,
    required this.systemStock,
    required this.physicalStock,
    int? discrepancy,
    this.reason = 'Penyesuaian hasil audit fisik garmen',
  }) : discrepancy = discrepancy ?? (physicalStock - systemStock);

  factory AuditModel.fromJson(Map<String, dynamic> json) {
    return AuditModel(
      id: json['id'] as String?,
      itemId: json['item_id'] as String,
      systemStock: (json['system_stock'] as num).toInt(),
      physicalStock: (json['physical_stock'] as num).toInt(),
      discrepancy: (json['discrepancy'] as num).toInt(),
      reason: json['reason'] as String? ?? 'Penyesuaian hasil audit fisik garmen',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'item_id': itemId,
      'system_stock': systemStock,
      'physical_stock': physicalStock,
      'discrepancy': discrepancy,
      'reason': reason,
    };
  }
}
