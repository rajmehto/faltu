import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/dio_interceptors.dart';
import '../../services/auth_service.dart';
import '../../services/agora_service.dart';
import '../../services/socket_service.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import '../../services/payment_service.dart';
import '../../services/storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/datasources/stream_remote_datasource.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/datasources/gift_remote_datasource.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/stream_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/gift_repository_impl.dart';
import '../../data/repositories/wallet_repository_impl.dart';

class DependencyInjection {
  static Future<void> init() async {
    _registerNetworking();
    _registerServices();
    _registerDataSources();
    _registerRepositories();
  }

  static void _registerNetworking() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.addAll([
      AuthInterceptor(),
      RetryInterceptor(dio: dio),
      LoggingInterceptor(),
    ]);

    Get.put<Dio>(dio, permanent: true);
    Get.put<ApiClient>(ApiClient(dio), permanent: true);
  }

  static void _registerServices() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<AgoraService>(AgoraService(), permanent: true);
    Get.put<SocketService>(SocketService(), permanent: true);
    Get.put<AnalyticsService>(AnalyticsService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<PaymentService>(PaymentService(), permanent: true);
    Get.put<StorageService>(StorageService(), permanent: true);
  }

  static void _registerDataSources() {
    Get.put<AuthRemoteDataSource>(
      AuthRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<UserRemoteDataSource>(
      UserRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<StreamRemoteDataSource>(
      StreamRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<ChatRemoteDataSource>(
      ChatRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<GiftRemoteDataSource>(
      GiftRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<WalletRemoteDataSource>(
      WalletRemoteDataSource(Get.find<ApiClient>()),
      permanent: true,
    );
  }

  static void _registerRepositories() {
    Get.put<AuthRepositoryImpl>(
      AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
      permanent: true,
    );
    Get.put<UserRepositoryImpl>(
      UserRepositoryImpl(Get.find<UserRemoteDataSource>()),
      permanent: true,
    );
    Get.put<StreamRepositoryImpl>(
      StreamRepositoryImpl(Get.find<StreamRemoteDataSource>()),
      permanent: true,
    );
    Get.put<ChatRepositoryImpl>(
      ChatRepositoryImpl(Get.find<ChatRemoteDataSource>()),
      permanent: true,
    );
    Get.put<GiftRepositoryImpl>(
      GiftRepositoryImpl(Get.find<GiftRemoteDataSource>()),
      permanent: true,
    );
    Get.put<WalletRepositoryImpl>(
      WalletRepositoryImpl(Get.find<WalletRemoteDataSource>()),
      permanent: true,
    );
  }
}
