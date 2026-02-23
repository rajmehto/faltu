class ApiResponse<T> {
  final T? data;
  final String? message;
  final int statusCode;
  final bool success;
  final Map<String, dynamic>? pagination;

  ApiResponse._({
    this.data,
    this.message,
    required this.statusCode,
    required this.success,
    this.pagination,
  });

  factory ApiResponse.success({
    T? data,
    String? message,
    required int statusCode,
    Map<String, dynamic>? pagination,
  }) {
    return ApiResponse._(
      data: data,
      message: message,
      statusCode: statusCode,
      success: true,
      pagination: pagination,
    );
  }

  factory ApiResponse.error({
    String? message,
    required int statusCode,
  }) {
    return ApiResponse._(
      message: message,
      statusCode: statusCode,
      success: false,
    );
  }

  bool get hasData => data != null;
  bool get hasPagination => pagination != null;
}

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return PaginatedResponse(
      items: (json['items'] as List).map(fromJson).toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      hasMore: json['hasMore'] ?? false,
    );
  }
}
