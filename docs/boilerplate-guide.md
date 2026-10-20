# Dùng boilerplate cho project mới

Repo này là boilerplate: copy sang project mới, đổi tên project/app, giữ nguyên architecture, library, đường dẫn, naming và code style. Feature Country (API) và Theme (local) chỉ là ví dụ. Nguồn chuẩn của quy ước: `docs/conventions.md`. Thứ tự ưu tiên khi mâu thuẫn: docs/conventions.md > .claude/templates > skills > CLAUDE.md > code mẫu Country/Theme.

Mọi lệnh dưới đây chạy ở thư mục gốc của project mới, dùng FVM (`fvm flutter`, `fvm dart`).

## 1. Copy repo
```
rsync -a --exclude .git --exclude build --exclude .dart_tool /path/to/boilerplate/ /path/to/new_project/
cd /path/to/new_project && git init
```
- KHÔNG copy `.git` (lịch sử của boilerplate không đi theo).
- Những thứ đi theo và phải giữ nguyên: `.claude/` (skills, templates, hooks), `CLAUDE.md`, `docs/`, `test/architecture/` (test kiểm tra quy ước), `Makefile`, `analysis_options.yaml`, `.github/`, `.fvmrc`.
- `.fvm/` là symlink tới SDK trên máy; nếu hỏng thì chạy `fvm install` rồi `fvm use` theo `.fvmrc`.

## 2. Đổi tên project/app: `make rename`
```
make rename project_name=my_app package_name=com.company.myapp
```
Tham số (đều tùy chọn, truyền cái nào đổi cái đó):
| Tham số | Tác dụng |
|---|---|
| `project_name` | Đổi `name:` trong `pubspec.yaml` và mọi import `package:<tên cũ>/` trong `lib/`, `test/` |
| `package_name` | Đổi cả Android applicationId và iOS bundle id (qua `change_app_package_name`) |
| `android_package` | Chỉ đổi Android (dùng khi không truyền `package_name`) |
| `ios_bundle` | Chỉ đổi iOS (dùng khi không truyền `package_name`) |

Làm gì và không làm gì:
- Làm: sửa `pubspec.yaml`, import trong `lib/` và `test/`; khi truyền `project_name` thì tự sắp lại thứ tự import (`dart fix --apply --code=directives_ordering`, vì IMP-02 sắp theo alphabet nên tên package mới làm lệch thứ tự); đổi id Android/iOS; cuối cùng in `make info`.
- Không làm: không sửa `README.md`, tên hiển thị app (label Android/iOS), flavor, `baseUrl`, file `.iml`/`.idea`, `ios/Flutter/*` (file sinh ra, tự cập nhật khi build).
- `CLAUDE.md`, `docs/conventions.md`, `.claude/` đã trung tính theo tên package (chỉ ghi `package:<app_package>`, lấy từ `name:` trong `pubspec.yaml`) nên KHÔNG cần sửa.
- Chạy `make rename` TRƯỚC khi xóa Country hoặc sau đều được; sau đó chạy lại bước 4.
- Không cần sắp lại import bằng tay: `make rename` đã làm (khi có `project_name`).
- Kiểm tra: `make info`, `grep -rn "<tên_package_cũ>" lib test pubspec.yaml` phải rỗng (tên cũ là giá trị `name:` của boilerplate trước khi đổi).

## 3. Xóa feature ví dụ Country (giữ Theme)
Country là feature API ví dụ; project mới thường không cần. Theme là feature local đang phục vụ giao diện (chế độ sáng/tối, được `main.dart` dùng qua `themeViewmodelProvider`), nên GIỮ.

### 3.1 Xóa file/thư mục (đường dẫn từ gốc project)
lib:
```
rm -rf lib/data/datasource/country
rm -rf lib/data/models/country
rm -rf lib/data/repositories/country
rm -rf lib/domain/repositories/country
rm -rf lib/domain/use_cases/country
rm -rf lib/presentation/features/country
rm -f  lib/data/mappers/country_mapper.dart
rm -f  lib/domain/entities/country.dart
```
test:
```
rm -rf test/data/repositories/country
rm -rf test/domain/use_cases/country
rm -rf test/presentation/features/country
rm -f  test/data/mappers/country_mapper_test.dart
rmdir test/data/mappers
```
(Thư mục `test/data/mappers/` chỉ còn file của Country; xóa khi rỗng. Nếu project đã có mapper khác thì giữ lại.) Assets không có file riêng của Country.

File generated của Country (`*.g.dart`, `*.freezed.dart`, `*.mocks.dart`) nằm trong các thư mục trên nên đi theo; riêng `lib/generated/*`, `lib/infrastructure/di/injection.config.dart` sẽ được sinh lại ở bước 4. Để chắc chắn không còn file generated cũ:
```
find lib test \( -name '*.g.dart' -o -name '*.freezed.dart' -o -name '*.mocks.dart' -o -name '*.config.dart' \) -delete
rm -rf lib/generated
```
Các file này đã gitignore, xóa an toàn.

### 3.2 Sửa file dùng chung
| File | Việc làm |
|---|---|
| `lib/data/datasource/core/api_endpoint.dart` | Xóa dòng `static const String allCountries = '/all';`. Giữ class `APIEndpoint` và `baseUrl`; đổi `baseUrl` (hiện trỏ `restcountries.com`) sang API của project, xem bước 7 |
| `lib/presentation/providers/di_providers.dart` | Xóa import `domain/use_cases/country/country_use_case.dart` và provider `countryUseCaseProvider`. Giữ `themeUseCaseProvider` |
| `lib/presentation/router/app_routes.dart` | Xóa `countries` và `countriesInHome` |
| `lib/presentation/router/app_router.dart` | Xóa import `countries_screen.dart` và `GoRoute(path: AppRoutes.countries, ...)` lồng trong route `home` (bỏ luôn khối `routes: [...]` của nó) |
| `lib/presentation/features/home/home_screen.dart` | Màn hình chỉ có nút `LocaleKeys.go_to_countries` đẩy sang `AppRoutes.countriesInHome`: PHẢI bỏ nút này (hoặc thay bằng nút dẫn tới màn hình mới của project). Bỏ import `app_button.dart`, `app_routes.dart`, `go_router`, `easy_localization`, `locale_keys.g.dart` nếu không còn dùng. Tối thiểu để build: `return const Scaffold(body: SafeArea(child: SizedBox.shrink()));` rồi thay bằng nội dung thật khi có feature đầu tiên |
| `assets/translations/en-US.json`, `ja-JP.json`, `vi-VN.json` | Xóa key `go_to_countries` ở CẢ 3 file (đây là key cuối; nhớ bỏ dấu phẩy ở dòng trước nó để JSON hợp lệ) |

Kiểm tra sót: `grep -rniE "country|countries" lib test assets` chỉ được còn `restcountries.com` trong `baseUrl` của `api_endpoint.dart` (đổi ở bước 7) và kết quả trong `test/architecture/` (fixture giả lập có tên Country, dùng package `sample_app`, không phải code thật) và file generated (sẽ bị sinh lại). Dòng nào khác còn lại là sót.

Ghi chú:
- Các file kiến trúc (`FIL-10`...) chỉ yêu cầu `api_endpoint.dart`/`app_routes.dart` tồn tại khi có API feature; vẫn nên giữ hai file này để feature API sau dùng (theo `SNIPPETS.md`).
- `ApiClient`, `ExceptionMapper`, `Result`, `AppError` là hạ tầng dùng chung, KHÔNG xóa.

## 4. Sinh code
```
make                 # check_version, clean, pub_get, l10n, build_runner
```
Hoặc từng bước: `fvm flutter pub get`, `make l10n`, `make build_runner`. Sau mỗi lần đổi model/state/viewmodel/`@injectable`/`@GenerateNiceMocks` chạy `make build_runner`; sau khi đổi `assets/translations/*.json` chạy `make l10n`.

## 5. Kiểm tra
```
fvm flutter analyze    # phải "No issues found!"
fvm flutter test       # phải "All tests passed!"
```
- Test kiến trúc `test/architecture/` tự pass khi project không có feature nào (hoặc chỉ có feature API/local), không cần sửa test. Các test này kiểm tra rule của `docs/conventions.md` trên code thật và trên fixture giả lập.
- Số test giảm vì bỏ test của Country (ở lần kiểm chứng: 312 xuống 295).
- Đủ Definition of Done: skill `flutter-verify`.

## 6. Tạo feature đầu tiên
Dùng skill `flutter-new-feature` (render từ `.claude/templates/`):
- `api-feature`: feature gọi API (có datasource, model, mapper, state, screen).
- `local-feature`: state cục bộ/lưu local (như Theme).
Thêm endpoint vào feature có sẵn: skill `flutter-add-api`. Template không phủ trường hợp: dừng và hỏi (rule STP trong `docs/conventions.md`). Quy trình đầy đủ: `docs/ai-workflow.md`.

## 7. Cập nhật giá trị phụ thuộc app
- `README.md`: viết lại cho project mới (hiện là README của boilerplate).
- `pubspec.yaml`: `description`, `version`.
- Tên hiển thị app: Android (`android/app/src/main/AndroidManifest.xml`, `@string/app_name`) và iOS (`ios/Runner/Info.plist`, `CFBundleDisplayName`).
- Bundle id/application id: kiểm tra bằng `make info`; flavor (`develop`/`stg`...) trong `android/app/build.gradle*` và scheme iOS.
- `baseUrl` trong `lib/data/datasource/core/api_endpoint.dart` (phân nhánh theo `appFlavor`).
- CI trong `.github/workflows/` (tên nhánh, flavor, version Flutter).
- Icon, splash, màu (`assets/colors/colors.xml`), rồi `make build_runner` để sinh lại `colors.gen.dart`.
