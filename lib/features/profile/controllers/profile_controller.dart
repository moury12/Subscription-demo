import '../models/profile_model.dart';

class ProfileController {
  const ProfileController();

  ProfileModel get model => const ProfileModel(name: 'Jhon Deo', tagline: 'Fitness Enthusiast');
}
