import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../inventory/providers/inventory_providers.dart';

class InboundScreen extends ConsumerStatefulWidget {
  const InboundScreen({super.key});

  @override
  ConsumerState<InboundScreen> createState() => _InboundScreenState();
}

class _InboundScreenState extends ConsumerState<InboundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _poController = TextEditingController(text: 'PO-TX-2026-001');
  final _supplierController = TextEditingController(text: 'PT Argo Manunggal Triasta');
  final _lotController = TextEditingController(text: 'LOT-2026-A1');
  final _qtyController = TextEditingController(text: '10');
  final _notesController = TextEditingController(text: 'Penerimaan kain rol reguler');

  String? _selectedItemId;

  @override
  void dispose() {
    _poController.dispose();
    _supplierController.dispose();
    _lotController.dispose();
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit([String? effectiveId]) {
    if (_formKey.currentState?.validate() ?? false) {
      final qty = int.tryParse(_qtyController.text) ?? 0;
      final targetId = _selectedItemId ?? effectiveId;
      if (targetId != null && qty > 0) {
        ref.read(inventoryRepositoryProvider).addStock(targetId, qty);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bahan masuk ${_poController.text} berhasil dicatat!'),
          backgroundColor: AppColors.emeraldSuccess,
        ),
      );
      _qtyController.clear();
      _lotController.clear();
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
          'Penerimaan Bahan Masuk (PO)',
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
                        'Formulir Penerimaan PO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Catat barang masuk dari supplier ke sistem inventaris gudang.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      const Divider(height: 24),
                      TextFormField(
                        controller: _poController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Purchase Order (PO)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.receipt_long),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor PO tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: effectiveSelectedId,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Bahan / Item Garmen',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        items: items.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(
                              '[${item.sku}] ${item.name}',
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
                            return 'Harap pilih item';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _supplierController,
                        decoration: const InputDecoration(
                          labelText: 'Supplier / Vendor Tekstil',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Supplier wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _lotController,
                              decoration: const InputDecoration(
                                labelText: 'Lot Kain / Batch',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.qr_code),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Kuantitas Masuk',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.add_shopping_cart),
                              ),
                              validator: (value) {
                                final qty = int.tryParse(value ?? '');
                                if (qty == null || qty <= 0) {
                                  return 'Qty harus > 0';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Penerimaan (QC)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _handleSubmit(effectiveSelectedId),
                        icon: const Icon(Icons.save),

                        label: const Text(
                          'Catat Bahan Masuk',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.slateDark,
                          foregroundColor: Colors.white,
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
