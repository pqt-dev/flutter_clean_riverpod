# SNIPPETS — thay đổi trong file dùng chung

Các đoạn dưới đây là code mẫu, dùng placeholder (token: `{{Entity}}`, `{{entity}}`, `{{Entities}}`, `{{entities}}`, `{{feature}}`, `{{app_package}}`; thêm `{{Nested}}`/`{{nested}}` chỉ ở template nested model). Chèn vào file đích có sẵn, KHÔNG tạo file mới.

## 1. Endpoint

- File đích: `lib/data/datasource/core/api_endpoint.dart`
- Vị trí: trong `class APIEndpoint`, sau các `static const String ...` hiện có.

```dart
  static const String all{{Entities}} = '/all';
```

Ghi chú: `'/all'` chỉ là path minh họa. Thay bằng path thật của API mới. `baseUrl` dùng chung, không đổi trừ khi API khác host.

## 2. Provider (DI bridge GetIt -> Riverpod)

- File đích: `lib/presentation/providers/di_providers.dart`
- Vị trí: (a) thêm import use case vào cụm import ở đầu file (giữ thứ tự alphabet); (b) thêm provider sau các provider hiện có. Đây là nơi DUY NHẤT trong presentation được gọi `getIt`.

```dart
import 'package:{{app_package}}/domain/use_cases/{{feature}}/{{entity}}_use_case.dart';
```

```dart
final {{entity}}UseCaseProvider = Provider<{{Entity}}UseCase>((ref) {
  return getIt<{{Entity}}UseCase>();
});
```

## 3. Route

Hai file `app_routes.dart` và `app_router.dart` đã có trong boilerplate (hiện chỉ có `AppRoutes.home = '/home'` và `GoRoute` của home dẫn tới `CounterScreen`). Route của feature mới là sub-route của `AppRoutes.home`, đặt trong `routes: [ ... ]` của `GoRoute(path: AppRoutes.home, ...)`; nếu `GoRoute` của home chưa có `routes:` thì thêm danh sách này.

### 3a. `lib/presentation/router/app_routes.dart`

Vị trí: trong `class AppRoutes`, sau các `static const` hiện có.

```dart
  static const {{entities}} = '/{{entities}}';
  static const {{entities}}InHome = '/home/{{entities}}';
```

### 3b. `lib/presentation/router/app_router.dart`

Import (đầu file, dạng package, giữ thứ tự alphabet theo `directives_ordering`):

```dart
import 'package:{{app_package}}/presentation/features/{{feature}}/{{entities}}_screen.dart';
```

Route: là sub-route của `AppRoutes.home` (trong `routes: [ ... ]` của `GoRoute(path: AppRoutes.home, ...)`; thêm `routes: [ ... ]` nếu chưa có):

```dart
          GoRoute(
            path: AppRoutes.{{entities}},
            builder: (context, state) => {{Entities}}Screen(),
          ),
```

Ngữ cảnh (ví dụ) để biết thụt lề/vị trí:

```dart
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const CounterScreen(),
        routes: [
          // <-- chèn GoRoute ở trên vào đây (thêm `routes: [...]` nếu chưa có)
        ],
      ),
    ],
```

Điều hướng tới màn hình (đặt trong màn hình nguồn điều hướng, tức màn hình đứng trước màn hình mới):

```dart
onPressed: () => context.push(AppRoutes.{{entities}}InHome),
```

Title của nút điều hướng phải qua l10n, không dùng chuỗi cứng. Ví dụ (key `go_to_products`):

```dart
AppButton(
  title: LocaleKeys.go_to_{{entities}}.tr(),
  onPressed: () => context.push(AppRoutes.{{entities}}InHome),
),
```

Key mới phải được thêm vào CẢ 3 file l10n (xem mục 4).

## 4. l10n (3 file)

- File đích: `assets/translations/en-US.json`, `assets/translations/ja-JP.json`, `assets/translations/vi-VN.json`

Màn hình của template chỉ dùng key có sẵn `LocaleKeys.error_unexpected` (đã có trong cả 3 file) và `AppErrorL10n.localizedMessage` cho lỗi, nên bản thân các file template không cần key mới.

Mọi text hiển thị mới (ví dụ title nút entry point ở mục 3b) bắt buộc qua l10n: thêm key vào CẢ 3 file (cùng key, cùng vị trí), chạy `make l10n`, dùng `LocaleKeys.<key>.tr()`. Tên key snake_case theo quy ước hiện có của file. Ví dụ:

```json
"go_to_products": "Go to list of products"
```

(en-US; ja-JP và vi-VN dùng cùng key `go_to_products` với bản dịch tương ứng.) Với feature mới, đặt key theo tên feature, ví dụ `go_to_{{entities}}`.
