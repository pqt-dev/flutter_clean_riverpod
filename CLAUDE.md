# CLAUDE.md

Flutter boilerplate, Clean Architecture + Riverpod + injectable/get_it. Package: xem `name:` trong `pubspec.yaml`. Dart ^3.10.
Quy trình đầy đủ: [docs/ai-workflow.md](docs/ai-workflow.md). Dùng cho project mới: [docs/boilerplate-guide.md](docs/boilerplate-guide.md).

## Bắt buộc đọc
- Trước khi tạo/sửa feature: đọc [docs/conventions.md](docs/conventions.md) (nguồn chuẩn, rule có mã `ARC-01`, `NAM-06`...). Khi tạo feature mới: đọc thêm [.claude/templates/README.md](.claude/templates/README.md).
- Thứ tự ưu tiên khi mâu thuẫn: docs/conventions.md > .claude/templates > skills > CLAUDE.md > code mẫu Theme.
- Theme (local) chỉ là ví dụ, có thể bị xóa.

## Nguyên tắc
- Đọc file này trước, thay đổi nhỏ và đúng phạm vi.
- Mơ hồ / thiếu thông tin / template không phủ trường hợp (STP-01): dừng và hỏi, không đoán.
- Không thêm package mới, không refactor ngoài phạm vi, không commit/push nếu chưa được yêu cầu.
- Dùng FVM: `fvm flutter`, `fvm dart` (Makefile có `USE_FVM`).

## Feature mới = đúng template
- Chọn `api-feature` (gọi API) hoặc `local-feature` (state/lưu local) trong `.claude/templates/`; sinh đủ file set gồm test.
- Chỉ thay vùng `tmpl:custom-begin/end` rồi xóa dòng marker; file dùng chung sửa theo `SNIPPETS.md`.

## Skills (`.claude/skills/`)
| Việc | Skill |
|---|---|
| Feature mới (domain→data→presentation→route→l10n→test) | `flutter-new-feature` |
| Thêm endpoint/use case vào feature có sẵn | `flutter-add-api` |
| Viết test | `flutter-write-tests` |
| Codegen/analyze/test + Definition of Done | `flutter-verify` |
| Review diff theo quy ước | `flutter-review` |

## Layer (`lib/`): hướng import
| Layer | Không được import | Rule |
|---|---|---|
| `domain/` | flutter, dio, data, presentation | ARC-01 |
| `data/` | presentation | ARC-03 |
| `presentation/` | data | ARC-02 |
| `infrastructure/` | (không giới hạn) | |

## Quy ước code (chi tiết và mã đầy đủ: docs/conventions.md)
- ViewModel chỉ phụ thuộc UseCase, không import repository: ARC-05.
- `getIt` chỉ dùng ở `presentation/providers/di_providers.dart`; ViewModel lấy use case bằng `ref.watch(xUseCaseProvider)`: ARC-04, DI-02, DI-04.
- Lỗi đi qua `Result<T>`/`AppError`, không throw ra ngoài datasource; không hiển thị `error.toString()`: ERR-01, ERR-06.
- Không `print`/`debugPrint`, dùng `LoggerService`: ARC-08.
- Tên: thư mục `datasource` (số ít), `repositories` (số nhiều), feature số ít: FIL-03; hậu tố class cố định: NAM-03; `Viewmodel` chữ m thường: NAM-06.
- Import dạng `package:<app_package>/...` cho mọi file, kể cả cùng thư mục (không import tương đối): IMP-01.
- Dấu nháy đơn `'` trong `lib/` và `test/`: STY-02.
- Text hiển thị qua `LocaleKeys.xxx.tr()` và thêm key vào CẢ 3 file `assets/translations/*.json` rồi `make l10n`: L10N-01, L10N-02.
- `test/` mirror đúng đường dẫn `lib/`: TST-01.
- Asset/màu qua flutter_gen, không viết đường dẫn/mã màu trực tiếp: GEN-04.

## Generated code và lệnh make
- `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`, `*.mocks.dart` đã gitignore: KHÔNG sửa tay (GEN-01).
- Sau khi đổi model/state/viewmodel/`@injectable`/`@GenerateNiceMocks`: `make build_runner`; sau khi đổi l10n: `make l10n` (GEN-03).
- `make` (all) = check_version, clean, pub_get, l10n, build_runner. Đổi tên project: `make rename` (xem boilerplate-guide).

## Git / CI
- `develop` là nhánh tích hợp; nhánh `feature/...`, `fix/...`, `update/...`; PR vào `develop` rồi `main`.
- CI chạy `make USE_FVM=false`, `Check format` (`dart format --output=none --set-exit-if-changed` trên file `.dart` đã track), `flutter analyze`, `flutter test`, build apk flavor develop.
- Commit message tiếng Anh, câu ngắn imperative hoặc prefix `refactor:`.

## Definition of Done
Xem skill `flutter-verify` (nguồn duy nhất).
