/// Represents an AIMS-Diabetes user profile as stored and returned by FastAPI.
///
/// Corresponds to the backend User schema (`/api/v1/auth/*` and `/api/v1/users/me`).
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.diabetesType,
    this.photoUrl,
    this.bmi,
    this.bmiCategory,
    this.createdAt,
  });

  /// Unique database identifier for the user.
  final int id;

  /// Full display name of the user.
  final String name;

  /// User email address (used for login and notifications).
  final String email;

  /// Age in years (nullable until filled in profile).
  final int? age;

  /// Biological gender: e.g. "Male", "Female", "Other".
  final String? gender;

  /// Height in centimeters (used for BMI calculation).
  final double? heightCm;

  /// Weight in kilograms (used for BMI calculation).
  final double? weightKg;

  /// Diagnosed diabetes type: e.g. "Type 1", "Type 2", "Prediabetes", "Gestational".
  final String? diabetesType;

  /// URL or path to user avatar.
  final String? photoUrl;

  /// Body Mass Index (computed server-side: weightKg / (heightM^2)).
  final double? bmi;

  /// BMI classification: e.g. "Underweight", "Normal", "Overweight", "Obese".
  final String? bmiCategory;

  /// Account creation timestamp (UTC).
  final DateTime? createdAt;

  /// Deserializes a [UserModel] from backend JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      diabetesType: json['diabetes_type'] as String?,
      photoUrl: json['photo_url'] as String?,
      bmi: (json['bmi'] as num?)?.toDouble(),
      bmiCategory: json['bmi_category'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
    );
  }

  /// Serializes the [UserModel] into JSON matching FastAPI schema conventions.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (age != null) 'age': age,
    if (gender != null) 'gender': gender,
    if (heightCm != null) 'height_cm': heightCm,
    if (weightKg != null) 'weight_kg': weightKg,
    if (diabetesType != null) 'diabetes_type': diabetesType,
    if (photoUrl != null) 'photo_url': photoUrl,
    if (bmi != null) 'bmi': bmi,
    if (bmiCategory != null) 'bmi_category': bmiCategory,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };

  /// Returns a copy of this [UserModel] with updated fields.
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? diabetesType,
    String? photoUrl,
    double? bmi,
    String? bmiCategory,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      diabetesType: diabetesType ?? this.diabetesType,
      photoUrl: photoUrl ?? this.photoUrl,
      bmi: bmi ?? this.bmi,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
