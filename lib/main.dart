import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/services/app_settings_service.dart';
import 'presentation/pages/drawing_page.dart';
import 'presentation/bloc/canvas/canvas_bloc.dart';

void main() async {
  // Bắt buộc phải có dòng này khi có các hàm async (như initDB) trước runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo GetIt và Isar Database
  await initDI();

  // Tải cài đặt từ SharedPreferences
  await AppSettingsService.instance.load();

  runApp(const EasyDrawApp());
}

class EasyDrawApp extends StatelessWidget {
  const EasyDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Easy Draw',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          // Bọc DrawingPage bằng MultiBlocProvider và lấy CanvasBloc từ GetIt (sl)
          home: MultiBlocProvider(
            providers: [BlocProvider<CanvasBloc>(create: (_) => sl<CanvasBloc>())],
            child: const DrawingPage(),
          ),
        );
      },
    );
  }
}
