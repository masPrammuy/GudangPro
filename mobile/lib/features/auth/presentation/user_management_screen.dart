import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../profile/presentation/edit_profile_dialog.dart';
import '../providers/auth_providers.dart';
import 'add_user_dialog.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  String _getInitials(String name) {
    final cleanName = name.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
    final parts = cleanName.split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final usersAsync = ref.watch(userListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Manajemen Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.slateDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_user_fab'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddUserDialog(),
          );
        },
        backgroundColor: AppColors.slateDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Tambah Akun User',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: usersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Gagal memuat pengguna: $error',
            style: const TextStyle(color: AppColors.roseDanger),
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada data pengguna.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              final isCurrent = currentUser?.id == user.id;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.indigoWip.withOpacity(0.5)
                        : AppColors.border,
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: user.isAdmin
                          ? AppColors.indigoWip
                          : AppColors.slateDark,
                      child: Text(
                        _getInitials(user.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // User Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.slateDark,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Saya',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),

                          // NIK & Email
                          Row(
                            children: [
                              const Icon(
                                Icons.badge_outlined,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.nik,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.email_outlined,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Role & Status Badges
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: user.isAdmin
                                      ? AppColors.indigoWip.withOpacity(0.12)
                                      : AppColors.slateCard.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: user.isAdmin
                                        ? AppColors.indigoWip.withOpacity(0.3)
                                        : AppColors.slateCard.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  user.role.displayName,
                                  style: TextStyle(
                                    color: user.isAdmin
                                        ? AppColors.indigoWip
                                        : AppColors.slateDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(
                                status: user.isActive ? 'Aktif' : 'Non-Aktif',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Edit button
                    IconButton(
                      key: Key('edit_user_button_${user.nik}'),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      tooltip: 'Edit Pengguna',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => EditProfileDialog(
                            targetUser: user,
                            isEditingOther: true,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
