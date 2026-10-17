class InboundModel {
  final String? id;
  final String poNumber;
  final String itemId;
  final int qty;
  final String supplier;
  final String lotNumber;
  final String notes;
  final String status;

  InboundModel({
    this.id,
    required this.poNumber,
    required this.itemId,
    required this.qty,
    required this.supplier,
    this.lotNumber = '-',
    this.notes = '-',
    this.status = 'QC Passed',
  });

  factory InboundModel.fromJson(Map<String, dynamic> json) {
    return InboundModel(
      id: json['id'] as String?,
      poNumber: json['po_number'] as String,
      itemId: json['item_id'] as String,
      qty: (json['qty'] as num).toInt(),
      supplier: json['supplier'] as String,
      lotNumber: json['lot_number'] as String? ?? '-',
      notes: json['notes'] as String? ?? '-',
      status: json['status'] as String? ?? 'QC Passed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'po_number': poNumber,
      'item_id': itemId,
      'qty': qty,
      'supplier': supplier,
      'lot_number': lotNumber,
      'notes': notes,
      'status': status,
    };
  }
}
