import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../inventory/data/item_model.dart';
import '../../inventory/providers/inventory_providers.dart';

class OutboundScreen extends ConsumerStatefulWidget {
  const OutboundScreen({super.key});

  @override
  ConsumerState<OutboundScreen> createState() => _OutboundScreenState();
}

class _OutboundScreenState extends ConsumerState<OutboundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doController = TextEditingController(text: 'DO-GP-2026-001');
  final _recipientController = TextEditingController(text: 'Distributor Apparel Nusantara');
  final _courierController = TextEditingController(text: 'JNE Trucking');
  final _qtyController = TextEditingController(text: '2');
  final _notesController = TextEditingController(text: 'Pengiriman batch pesanan reguler');

  String? _selectedItemId;

  @override
  void dispose() {
    _doController.dispose();
    _recipientController.dispose();
    _courierController.dispose();
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit([String? effectiveId]) {
    if (_formKey.currentState?.validate() ?? false) {
      final qty = int.tryParse(_qtyController.text) ?? 0;
      final targetId = _selectedItemId ?? effectiveId;
      if (targetId != null && qty > 0) {
        ref.read(inventoryRepositoryProvider).deductStock(targetId, qty);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Surat Jalan ${_doController.text} berhasil diterbitkan (-$qty)!'),
          backgroundColor: AppColors.emeraldSuccess,
        ),
      );
      _qtyController.clear();
      _notesController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Surat Jalan Pengiriman (DO)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.slateDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: itemsAsync.when(
        data: (items) {
          final effectiveSelectedId = items.any((i) => i.id == _selectedItemId)
              ? _selectedItemId
              : (items.isNotEmpty ? items.first.id : null);

          ItemModel? selectedItem;
          if (effectiveSelectedId != null) {
            selectedItem = items.where((i) => i.id == effectiveSelectedId).firstOrNull;
          }

          final requestedQty = int.tryParse(_qtyController.text) ?? 0;
          final availableStock = selectedItem?.qty ?? 0;
          final unit = selectedItem?.unit ?? 'pcs';
          final isOverShipping = selectedItem != null && requestedQty > availableStock;
          final isZeroOrNegative = requestedQty <= 0;
          final isButtonEnabled = !isOverShipping && !isZeroOrNegative && selectedItem != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Formulir Pengiriman DO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Penerbitan Delivery Order garmen dengan proteksi anti-overshipping otomatis.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      const Divider(height: 24),
                      TextFormField(
                        controller: _doController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Surat Jalan (DO)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor DO tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: effectiveSelectedId,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Baju Jadi / Produk Siap Kirim',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.checkroom),
                        ),
                        items: items.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(
                              '[${item.sku}] ${item.name} (Stok: ${item.qty} ${item.unit})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedItemId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap pilih item garmen';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Kuantitas Kirim',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.shopping_bag),
                          errorText: isOverShipping
                              ? 'Stok tidak mencukupi! Tersedia hanya $availableStock $unit'
                              : null,
                          errorStyle: const TextStyle(
                            color: AppColors.roseDanger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                        validator: (value) {
                          final qty = int.tryParse(value ?? '');
                          if (qty == null || qty <= 0) {
                            return 'Kuantitas harus lebih dari 0';
                          }
                          if (selectedItem != null && qty > selectedItem.qty) {
                            return 'Stok tidak mencukupi! Tersedia hanya $availableStock $unit';
                          }
                          return null;
                        },
                      ),
                      if (isOverShipping) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.roseDanger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.roseDanger),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: AppColors.roseDanger, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Stok tidak mencukupi! Tersedia hanya $availableStock $unit',
                                  style: const TextStyle(
                                    color: AppColors.roseDanger,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (selectedItem != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Stok tersedia saat ini: $availableStock $unit',
                          style: const TextStyle(
                            color: AppColors.emeraldSuccess,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _recipientController,
                        decoration: const InputDecoration(
                          labelText: 'Penerima / Buyer Apparel',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.store),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Penerima tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _courierController,
                        decoration: const InputDecoration(
                          labelText: 'Ekspedisi / Kurir Logistik',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_shipping),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ekspedisi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Pengiriman',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: isButtonEnabled ? () => _handleSubmit(effectiveSelectedId) : null,
                        icon: const Icon(Icons.send),

                        label: const Text(
                          'Terbitkan Surat Jalan DO',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.slateDark,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error memuat data: $err')),
      ),
    );
  }
}
