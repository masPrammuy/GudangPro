import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../inventory/data/item_model.dart';
import '../../inventory/providers/inventory_providers.dart';

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _physicalQtyController = TextEditingController();
  final _reasonController = TextEditingController(text: 'Penyesuaian hasil audit fisik garmen');

  String? _selectedItemId;

  @override
  void dispose() {
    _physicalQtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handleSubmit([String? effectiveId]) {
    if (_formKey.currentState?.validate() ?? false) {
      final physicalQty = int.tryParse(_physicalQtyController.text) ?? 0;
      final targetId = _selectedItemId ?? effectiveId;
      if (targetId != null) {
        ref.read(inventoryRepositoryProvider).setPhysicalStock(targetId, physicalQty);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasil audit fisik berhasil disinkronkan ke master stok!'),
          backgroundColor: AppColors.emeraldSuccess,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Stock Opname & Audit Fisik',
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

          if (selectedItem != null && _physicalQtyController.text.isEmpty) {
            final initialQty = selectedItem.qty;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _physicalQtyController.text.isEmpty) {
                _physicalQtyController.text = '$initialQty';
              }
            });
          }

          final systemStock = selectedItem?.qty ?? 0;
          final unit = selectedItem?.unit ?? 'pcs';
          final physicalStock = int.tryParse(_physicalQtyController.text) ?? systemStock;
          final discrepancy = physicalStock - systemStock;

          Color badgeColor;
          String badgeText;
          if (discrepancy == 0) {
            badgeColor = AppColors.emeraldSuccess;
            badgeText = 'Selisih: 0 $unit (Sesuai)';
          } else if (discrepancy < 0) {
            badgeColor = AppColors.roseDanger;
            badgeText = 'Selisih: $discrepancy $unit (Kurang / Defisit)';
          } else {
            badgeColor = AppColors.indigoWip;
            badgeText = 'Selisih: +$discrepancy $unit (Lebih / Surplus)';
          }

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
                        'Formulir Stock Opname',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pencocokan kuantitas fisik gudang dengan sistem & kalkulasi deviasi realtime.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      const Divider(height: 24),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: effectiveSelectedId,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Item Garmen yang Diaudit',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.qr_code_scanner),
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
                            final itm = items.where((i) => i.id == value).firstOrNull;
                            if (itm != null) {
                              _physicalQtyController.text = '${itm.qty}';
                            }
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Stok Tercatat di Sistem:',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$systemStock $unit',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slateDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _physicalQtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stok Fisik Aktual',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calculate),
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                        validator: (value) {
                          final qty = int.tryParse(value ?? '');
                          if (qty == null || qty < 0) {
                            return 'Kuantitas fisik tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Discrepancy Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              discrepancy == 0
                                  ? Icons.check_circle
                                  : (discrepancy < 0 ? Icons.error : Icons.add_circle),
                              color: badgeColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Alasan Penyesuaian / Catatan Audit',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alasan penyesuaian wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _handleSubmit(effectiveSelectedId),
                        icon: const Icon(Icons.sync),

                        label: const Text(
                          'Sinkronisasi Master Stok',
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
