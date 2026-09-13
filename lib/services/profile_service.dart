import 'package:flutter/foundation.dart';
import '../models/memorial_profile.dart';

/// Abstract contract for memorial profile management.
abstract class IProfileService {
  MemorialProfile get profile;
  Future<void> updateProfile(MemorialProfile updatedProfile);
}

/// In-memory reactive implementation for profile configuration.
class LocalProfileService extends ChangeNotifier implements IProfileService {
  MemorialProfile _profile = MemorialProfile.defaultProfile();

  @override
  MemorialProfile get profile => _profile;

  @override
  Future<void> updateProfile(MemorialProfile updatedProfile) async {
    _profile = updatedProfile;
    notifyListeners();
  }
}
