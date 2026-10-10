import 'package:flutter/foundation.dart';

/// Tăng giá trị này mỗi khi dữ liệu giao dịch thay đổi (thêm / sửa / xóa)
/// để các màn hình đang mở (Trang chủ, Giao dịch, Thống kê) tự tải lại dữ liệu.
final ValueNotifier<int> dataVersion = ValueNotifier<int>(0);

void notifyDataChanged() {
  dataVersion.value++;
}