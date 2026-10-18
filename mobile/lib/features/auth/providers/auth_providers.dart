import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = AuthRepository();
  ref.onDispose(() => repo.dispose());
  return repo;
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _repo;

  CurrentUserNotifier(this._repo) : super(null);

  Future<bool> login(String email, String password) async {
    final user = await _repo.login(email, password);
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

  void logout() {
    state = null;
  }

  Future<void> updateCurrentProfile(UserModel updated) async {
    final result = await _repo.updateUserProfile(updated);
    state = result;
  }
}

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return CurrentUserNotifier(repo);
});

final userListProvider = StreamProvider<List<UserModel>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.watchUsers();
});
