# Templates — bản hiện thực của conventions

Thư mục này là bản hiện thực (dạng file mẫu) của `docs/conventions.md` cho cấu trúc, đặt tên và code style của feature mới; nguồn chuẩn duy nhất là `docs/conventions.md`. Feature Theme (local), nếu còn trong repo, chỉ là ví dụ sống. Thứ tự ưu tiên khi mâu thuẫn: docs/conventions.md > .claude/templates > skills > CLAUDE.md > code mẫu Theme.

Mỗi bộ template là một thư mục con mô phỏng đường dẫn đích (`lib/...`, `test/...`), file có đuôi `.tmpl`, kèm `SNIPPETS.md` cho phần sửa vào file dùng chung.

## Khi nào dùng bộ nào
| Bộ | Dùng khi | Vị trí presentation |
|---|---|---|
| `api-feature/` | Feature gọi API (có datasource, model, mapper, state, screen) | `presentation/features/<feature>/` |
| `local-feature/` | State cục bộ / lưu local, không gọi API (như Theme) | `presentation/<feature>/` (theo vị trí của Theme) |

Giả định của `local-feature/` (khác đi thì DỪNG và hỏi user):
- Value type là `enum` ở `domain/core/` và dùng `.name` để lưu.
- Lưu dạng string bằng `SharedPreferences`, key khai báo trong `StorageKeys` (`infrastructure/constants/storage_keys.dart`).
- Viewmodel đặt ở `presentation/<feature>/` (không phải `presentation/features/<feature>/`) và có thể trả về kiểu Flutter (Theme trả `ThemeMode`; chuyển đổi enum domain <-> kiểu Flutter nằm trong vùng custom của viewmodel).
- Không có datasource, state class, mapper, route, l10n riêng.

## Bảng token
Token dùng được cả trong NỘI DUNG lẫn TÊN file/thư mục.

Dùng chung:
| Token | Ý nghĩa | Ví dụ |
|---|---|---|
| `{{app_package}}` | Tên package, lấy từ `name:` trong `pubspec.yaml` | `my_app` |
| `{{feature}}` | Tên thư mục feature, snake_case, SỐ ÍT | `product`, `theme` |

`api-feature/`:
| Token | Ý nghĩa | Ví dụ |
|---|---|---|
| `{{Entity}}` | Tên entity PascalCase, số ít | `Product` |
| `{{entity}}` | Tên entity snake_case, số ít | `product` |
| `{{Entities}}` | PascalCase, số nhiều (tên Screen) | `Products` |
| `{{entities}}` | snake_case/camelCase, số nhiều (tên file screen, route, biến list) | `products` |
| `{{Nested}}` / `{{nested}}` | Tên nested model (chỉ ở file nested model) | `Name` / `name`, `Flag` / `flag` |

`local-feature/`:
| Token | Ý nghĩa | Ví dụ |
|---|---|---|
| `{{Feature}}` | Tên feature PascalCase | `Theme` |
| `{{featureCamel}}` | Tên feature camelCase (tên provider, tham số) | `theme` |
| `{{ValueType}}` | Tên enum value type ở domain, PascalCase | `AppThemeMode` |
| `{{value_type}}` | Tên file của value type, snake_case | `app_theme_mode` |
| `{{storageKey}}` | Tên hằng trong `StorageKeys`, camelCase | `themeModeKey` |
| `{{storage_key}}` | Giá trị chuỗi của key | `theme_mode_key` |

Quy tắc số ít / số nhiều: mọi file/class dùng `{{entity}}` / `{{Entity}}` (số ít) trừ Screen, dùng `{{entities}}` / `{{Entities}}` (số nhiều). Thư mục feature `{{feature}}` luôn số ít. (`datasource` số ít, `repositories` số nhiều: giữ nguyên như trong template.)

## Quy trình dùng
1. Chọn bộ: `api-feature` hay `local-feature` (xem bảng trên).
2. Render từng file: thay token trong TÊN file/thư mục lẫn NỘI DUNG, bỏ đuôi `.tmpl`, đặt vào đường dẫn đích (bỏ phần `api-feature/` hoặc `local-feature/` ở đầu).
3. Thay nội dung các vùng `// tmpl:custom-begin` ... `// tmpl:custom-end` bằng code của feature mới, rồi XÓA các dòng marker (giữ phần code).
4. Áp `SNIPPETS.md` vào file dùng chung có sẵn (endpoint, `di_providers.dart`, route, `storage_keys.dart`, l10n...). Không tạo file mới cho các phần này.
5. Chạy `make build_runner`; chạy `make l10n` nếu đổi `assets/translations/*.json`.
6. Giữ đủ file test đi kèm (xem bảng ánh xạ) và chỉnh vùng custom của test cho đúng feature.
7. Verify bằng skill `flutter-verify`; sau đó `grep -rn "tmpl:custom\|{{" lib test` phải rỗng.

## Ánh xạ template -> file đích
Cột trái là đường dẫn tương đối từ `.claude/templates/<bộ>/` (bỏ `.tmpl` khi render).

### api-feature
| Template | File đích |
|---|---|
| `lib/domain/entities/{{entity}}.dart.tmpl` | `lib/domain/entities/{{entity}}.dart` |
| `lib/domain/repositories/{{feature}}/{{entity}}_repository.dart.tmpl` | `lib/domain/repositories/{{feature}}/{{entity}}_repository.dart` |
| `lib/domain/use_cases/{{feature}}/{{entity}}_use_case.dart.tmpl` | `lib/domain/use_cases/{{feature}}/{{entity}}_use_case.dart` |
| `lib/data/models/{{feature}}/{{entity}}_model.dart.tmpl` | `lib/data/models/{{feature}}/{{entity}}_model.dart` |
| `lib/data/models/{{feature}}/{{entity}}_{{nested}}_model.dart.tmpl` | `lib/data/models/{{feature}}/{{entity}}_{{nested}}_model.dart` (dùng 1 lần cho mỗi nested model) |
| `lib/data/mappers/{{entity}}_mapper.dart.tmpl` | `lib/data/mappers/{{entity}}_mapper.dart` |
| `lib/data/datasource/{{feature}}/{{entity}}_datasource.dart.tmpl` | `lib/data/datasource/{{feature}}/{{entity}}_datasource.dart` |
| `lib/data/datasource/{{feature}}/{{entity}}_datasource_remote.dart.tmpl` | `lib/data/datasource/{{feature}}/{{entity}}_datasource_remote.dart` |
| `lib/data/repositories/{{feature}}/{{entity}}_repository_impl.dart.tmpl` | `lib/data/repositories/{{feature}}/{{entity}}_repository_impl.dart` |
| `lib/presentation/features/{{feature}}/{{entity}}_state.dart.tmpl` | `lib/presentation/features/{{feature}}/{{entity}}_state.dart` |
| `lib/presentation/features/{{feature}}/{{entity}}_viewmodel.dart.tmpl` | `lib/presentation/features/{{feature}}/{{entity}}_viewmodel.dart` |
| `lib/presentation/features/{{feature}}/{{entities}}_screen.dart.tmpl` | `lib/presentation/features/{{feature}}/{{entities}}_screen.dart` |
| `lib/presentation/features/{{feature}}/widget/{{entity}}_item_view.dart.tmpl` | `lib/presentation/features/{{feature}}/widget/{{entity}}_item_view.dart` |
| `test/data/mappers/{{entity}}_mapper_test.dart.tmpl` | `test/data/mappers/{{entity}}_mapper_test.dart` |
| `test/data/repositories/{{feature}}/{{entity}}_repository_impl_test.dart.tmpl` | `test/data/repositories/{{feature}}/{{entity}}_repository_impl_test.dart` |
| `test/domain/use_cases/{{feature}}/{{entity}}_use_case_test.dart.tmpl` | `test/domain/use_cases/{{feature}}/{{entity}}_use_case_test.dart` |
| `test/presentation/features/{{feature}}/{{entity}}_viewmodel_test.dart.tmpl` | `test/presentation/features/{{feature}}/{{entity}}_viewmodel_test.dart` |
| `SNIPPETS.md` | Chèn vào `api_endpoint.dart`, `di_providers.dart`, `app_routes.dart`, `app_router.dart`, l10n |

Nested entity (ví dụ `{{Entity}}Name`) và nested extension mapper nằm trong vùng custom của file entity và file mapper.

### local-feature
| Template | File đích |
|---|---|
| `lib/domain/core/{{value_type}}.dart.tmpl` | `lib/domain/core/{{value_type}}.dart` |
| `lib/domain/repositories/{{feature}}/{{feature}}_repository.dart.tmpl` | `lib/domain/repositories/{{feature}}/{{feature}}_repository.dart` |
| `lib/domain/use_cases/{{feature}}/{{feature}}_use_case.dart.tmpl` | `lib/domain/use_cases/{{feature}}/{{feature}}_use_case.dart` |
| `lib/data/repositories/{{feature}}/{{feature}}_repository_impl.dart.tmpl` | `lib/data/repositories/{{feature}}/{{feature}}_repository_impl.dart` |
| `lib/presentation/{{feature}}/{{feature}}_viewmodel.dart.tmpl` | `lib/presentation/{{feature}}/{{feature}}_viewmodel.dart` |
| `test/data/repositories/{{feature}}/{{feature}}_repository_impl_test.dart.tmpl` | `test/data/repositories/{{feature}}/{{feature}}_repository_impl_test.dart` |
| `test/domain/use_cases/{{feature}}/{{feature}}_use_case_test.dart.tmpl` | `test/domain/use_cases/{{feature}}/{{feature}}_use_case_test.dart` |
| `test/presentation/{{feature}}/{{feature}}_viewmodel_test.dart.tmpl` | `test/presentation/{{feature}}/{{feature}}_viewmodel_test.dart` |
| `SNIPPETS.md` | Chèn vào `di_providers.dart`, `storage_keys.dart`; gắn viewmodel vào app (mô tả trong SNIPPETS) |

## Điều cấm
- Đổi khung (cấu trúc, import, annotation, tên hàm/class cố định) NGOÀI vùng custom.
- Bỏ file test của feature (api-feature: 4 loại test; local-feature: 3 loại test).
- Đổi hậu tố tên file/class (`Screen`, `State`, `Viewmodel`, `UseCase`, `Repository`, `RepositoryImpl`, `Datasource`, `DatasourceRemote`, `Model`, `ItemView`).
- Để sót dòng `tmpl:custom-*` hoặc `{{` trong `lib/` và `test/`.
- Sửa file generated (`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`, `*.mocks.dart`).

## Ngoài phạm vi template
Template chưa phủ trường hợp (state khác, lưu trữ khác, không dùng `SharedPreferences`, value type không phải enum...): DỪNG và hỏi user, không tự chế.

## Bảo trì
Khi đổi pattern: sửa `docs/conventions.md` + template + các skill liên quan trong CÙNG PR.
