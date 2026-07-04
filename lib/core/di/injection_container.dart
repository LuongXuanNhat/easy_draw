import 'package:get_it/get_it.dart';
import '../../data/datasources/isar_datasource.dart';
import '../../presentation/bloc/canvas/canvas_bloc.dart';

// Biến toàn cục sl (Service Locator) để gọi các dependency
final sl = GetIt.instance;

Future<void> initDI() async {
  // 1. Data sources
  // Đăng ký dạng Singleton: Chỉ tạo 1 instance duy nhất trong suốt vòng đời app
  sl.registerLazySingleton<IsarDataSource>(() => IsarDataSource());

  // Khởi tạo Database ngay khi app mở lên
  await sl<IsarDataSource>().initDB();

  // 2. BLoC
  // Đăng ký dạng Factory: Mỗi lần gọi sẽ tạo ra một instance BLoC mới
  // Điều này rất quan trọng để không bị dính state cũ khi đóng/mở lại màn hình vẽ
  sl.registerFactory<CanvasBloc>(() => CanvasBloc());
}
