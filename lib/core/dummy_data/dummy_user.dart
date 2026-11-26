import '../../models/user_model.dart';

/// Pre-populated dummy user response matching FastAPI `/api/v1/users/me` response schema.
const Map<String, dynamic> dummyUserJson = {
  'id': 1,
  'name': 'Sara Ahmed',
  'email': 'sara@example.com',
  'age': 32,
  'gender': 'Female',
  'height_cm': 165.0,
  'weight_kg': 68.0,
  'diabetes_type': 'Type 2',
  'photo_url': null,
  'bmi': 25.0,
  'bmi_category': 'Overweight',
  'created_at': '2026-10-01T08:00:00Z',
};

/// Pre-parsed [UserModel] instance for mock operations and offline development.
final UserModel dummyUser = UserModel.fromJson(dummyUserJson);

/// DEVELOPMENT ONLY: password of the pre-seeded demo account
/// (`sara@example.com`) in `MockAuthService`.
const String dummyUserPassword = 'Sara@2026';
