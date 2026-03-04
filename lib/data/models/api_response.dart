// lib/core/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  
  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });
  
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
      statusCode: json['statusCode'],
    );
  }
}