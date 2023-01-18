class UserModel {
  int age;
  String bio;
  String email;
  bool isEmailVerified;
  String personalImage;
  String userId;
  String userName;
  String personalImagePath;

  UserModel({
    required this.age,
    required this.bio,
    required this.email,
    required this.isEmailVerified,
    required this.personalImage,
    required this.userId,
    required this.userName,
    required this.personalImagePath,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      age: map['age'] as int,
      bio: map['bio'] as String,
      email: map['email'] as String,
      isEmailVerified: map['isEmailVerified'] as bool,
      personalImage: map['personalImage'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      personalImagePath: map['personalImagePath'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userId': userId,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'personalImage': personalImage,
      'bio': bio,
      'age': age,
      'personalImagePath': personalImagePath,
    };
  }
}
