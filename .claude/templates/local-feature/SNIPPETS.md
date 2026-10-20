# SNIPPETS — feature cục bộ (không gọi API)

Bộ template mô phỏng feature **Theme** (state cục bộ, lưu bằng `SharedPreferences`). Token: `{{Feature}}` (Pascal), `{{feature}}` (snake số ít), `{{featureCamel}}` (camelCase), `{{app_package}}`, `{{ValueType}}` / `{{value_type}}` (value type ở domain), `{{storageKey}}` / `{{storage_key}}` (hằng trong `StorageKeys`).

Phần chèn vào file dùng chung có sẵn (KHÔNG tạo file mới). Template không có datasource, state class, mapper, route, l10n.

## 1. Provider (DI bridge GetIt -> Riverpod)

- File đích: `lib/presentation/providers/di_providers.dart`
- Vị trí: (a) thêm import use case vào cụm import đầu file (giữ thứ tự alphabet); (b) thêm provider sau các provider hiện có.

```dart
import 'package:{{app_package}}/domain/use_cases/{{feature}}/{{feature}}_use_case.dart';
```

```dart
final {{featureCamel}}UseCaseProvider = Provider<{{Feature}}UseCase>((ref) {
  return getIt<{{Feature}}UseCase>();
});
```

## 2. Storage key

- File đích: `lib/infrastructure/constants/storage_keys.dart`
- Vị trí: trong `class StorageKeys`, sau các `static const` hiện có.

```dart
  static const {{storageKey}} = '{{storage_key}}';
```

Dùng nháy đơn, theo quy ước của repo.

## 3. Gắn viewmodel vào app (mô tả, không phải template)

Theme gắn trong `lib/main.dart`: widget gốc `MyApp extends ConsumerWidget` gọi `ref.watch(themeViewmodelProvider)` rồi dùng `themeMode.value ?? ThemeMode.system` cho `MaterialApp.router(themeMode: ...)`; import `package:{{app_package}}/presentation/theme/theme_viewmodel.dart`. Feature cục bộ mới: tại nơi cần dùng state, `ref.watch({{featureCamel}}ViewmodelProvider)` (kết quả là `AsyncValue`), và gọi thay đổi qua `ref.read({{featureCamel}}ViewmodelProvider.notifier)`. Nếu giá trị cần áp dụng toàn app (như Theme) thì gắn ở widget gốc trong `main.dart`; nếu không thì ở screen liên quan.

## 4. Sau khi copy

1. Xóa mọi dòng `// tmpl:custom-begin` / `// tmpl:custom-end` (giữ nội dung giữa chúng, sửa lại cho đúng feature mới: enum/value type, logic fetch/save, mapping trong viewmodel, dữ liệu test, import `package:flutter/material.dart` nếu không cần).
2. Bỏ đuôi `.tmpl`, thay token trong tên file và nội dung.
3. Chỉnh `{{ValueType}}` (file `lib/domain/core/{{value_type}}.dart`) cho đúng giá trị của feature.
4. Chạy `make build_runner` (sinh `*.g.dart`, `*.mocks.dart`, `injection.config.dart`).
5. Chạy `fvm flutter analyze` và `fvm flutter test`.
