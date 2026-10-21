# Dùng boilerplate cho project mới

Repo này là boilerplate: copy sang project mới, đổi tên project/app, giữ nguyên architecture, library, đường dẫn, naming và code style. Feature Theme (local) chỉ là ví dụ. Nguồn chuẩn của quy ước: `docs/conventions.md`. Thứ tự ưu tiên khi mâu thuẫn: docs/conventions.md > .claude/templates > skills > CLAUDE.md > code mẫu Theme.

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
- Sau `make rename`, chạy lại bước 3 (sinh code).
- Không cần sắp lại import bằng tay: `make rename` đã làm (khi có `project_name`).
- Kiểm tra: `make info`, `grep -rn "<tên_package_cũ>" lib test pubspec.yaml` phải rỗng (tên cũ là giá trị `name:` của boilerplate trước khi đổi).

## 3. Sinh code
```
make                 # check_version, clean, pub_get, l10n, build_runner
```
Hoặc từng bước: `fvm flutter pub get`, `make l10n`, `make build_runner`. Sau mỗi lần đổi model/state/viewmodel/`@injectable`/`@GenerateNiceMocks` chạy `make build_runner`; sau khi đổi `assets/translations/*.json` chạy `make l10n`.

## 4. Kiểm tra
```
fvm flutter analyze    # phải "No issues found!"
fvm flutter test       # phải "All tests passed!"
```
- Test kiến trúc `test/architecture/` tự pass khi project không có feature nào (hoặc chỉ có feature API/local), không cần sửa test. Các test này kiểm tra rule của `docs/conventions.md` trên code thật và trên fixture giả lập.
- Đủ Definition of Done: skill `flutter-verify`.

## 5. Tạo feature đầu tiên
Dùng skill `flutter-new-feature` (render từ `.claude/templates/`):
- `api-feature`: feature gọi API (có datasource, model, mapper, state, screen).
- `local-feature`: state cục bộ/lưu local (như Theme).
Thêm endpoint vào feature có sẵn: skill `flutter-add-api`. Template không phủ trường hợp: dừng và hỏi (rule STP trong `docs/conventions.md`). Quy trình đầy đủ: `docs/ai-workflow.md`.

## 6. Cập nhật giá trị phụ thuộc app
- `README.md`: viết lại cho project mới (hiện là README của boilerplate).
- `pubspec.yaml`: `description`, `version`.
- Tên hiển thị app: Android (`android/app/src/main/AndroidManifest.xml`, `@string/app_name`) và iOS (`ios/Runner/Info.plist`, `CFBundleDisplayName`).
- Bundle id/application id: kiểm tra bằng `make info`; flavor (`develop`/`stg`...) trong `android/app/build.gradle*` và scheme iOS.
- `baseUrl` trong `lib/data/datasource/core/api_endpoint.dart` (phân nhánh theo `appFlavor`).
- CI trong `.github/workflows/` (tên nhánh, flavor, version Flutter).
- Icon, splash, màu (`assets/colors/colors.xml`), rồi `make build_runner` để sinh lại `colors.gen.dart`.
