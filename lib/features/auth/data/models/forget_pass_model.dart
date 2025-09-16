class ForgetPasswordModel {
  final String message;

  ForgetPasswordModel({required this.message});

  factory ForgetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordModel(
      message: json['message'] as String,
    );
  }
}
