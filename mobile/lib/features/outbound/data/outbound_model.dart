class OutboundModel {
  final String? id;
  final String doNumber;
  final String itemId;
  final int qty;
  final String recipient;
  final String courier;
  final String notes;
  final String status;

  OutboundModel({
    this.id,
    required this.doNumber,
    required this.itemId,
    required this.qty,
    required this.recipient,
    required this.courier,
    this.notes = '-',
    this.status = 'Terkirim',
  });

  factory OutboundModel.fromJson(Map<String, dynamic> json) {
    return OutboundModel(
      id: json['id'] as String?,
      doNumber: json['do_number'] as String,
      itemId: json['item_id'] as String,
      qty: (json['qty'] as num).toInt(),
      recipient: json['recipient'] as String,
      courier: json['courier'] as String,
      notes: json['notes'] as String? ?? '-',
      status: json['status'] as String? ?? 'Terkirim',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'do_number': doNumber,
      'item_id': itemId,
      'qty': qty,
      'recipient': recipient,
      'courier': courier,
      'notes': notes,
      'status': status,
    };
  }
}
