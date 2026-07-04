import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPhotosPermission() async {
  // Kiểm tra trạng thái hiện tại
  PermissionStatus status = await Permission.photos.status;

  if (status.isDenied) {
    // Nếu chưa cấp, yêu cầu người dùng cấp quyền
    status = await Permission.photos.request();
  }

  if (status.isPermanentlyDenied) {
    // Nếu người dùng chọn "Không bao giờ hỏi lại", mở app settings
    await openAppSettings();
    return false;
  }

  return status.isGranted;
}
