---
name: flutter-new-feature
description: Tạo một feature mới theo vertical slice (domain → data → DI → presentation → route → l10n → test) bằng cách render `.claude/templates/` trong repo này. Dùng khi user nói "tạo feature", "thêm màn hình/module mới", "new feature", "add screen with API". Không dùng để thêm endpoint vào feature đã có (dùng flutter-add-api).
---

# flutter-new-feature

Pattern chuẩn nằm ở `.claude/templates/` (đọc `.claude/templates/README.md` trước: token, ánh xạ file, điều cấm). Đường dẫn bên dưới là tên tương đối từ `.claude/templates/`. Token: `X`/`{{Entity}}` = entity PascalCase, `x`/`{{entity}}` = snake_case, `<feature>`/`{{feature}}` = tên thư mục số ít.

## Trước khi làm
- Đọc `CLAUDE.md`, `.claude/templates/README.md` và `docs/conventions.md` (nhóm rule liên quan: FIL, NAM, CLS, UI, DI, TST). Cần đủ: endpoint + sample JSON (api-feature) hoặc kiểu giá trị + cách lưu (local-feature), UX màn hình, error case. Thiếu hoặc mơ hồ: DỪNG và hỏi.
- Template không phủ trường hợp (state khác, lưu trữ khác...): DỪNG và hỏi, không tự chế.
- Liệt kê file sẽ tạo theo layer, chờ duyệt.

## Các bước
0. **Chọn loại**: `api-feature` (gọi API, viewmodel ở `presentation/features/<feature>/`) hay `local-feature` (state/lưu local như Theme, viewmodel ở `presentation/<feature>/`). Với mỗi file bên dưới: render template (thay token trong tên file lẫn nội dung, bỏ `.tmpl`) → thay nội dung vùng `tmpl:custom` bằng code feature → XÓA dòng marker.

### api-feature
1. **Entity** render `api-feature/lib/domain/entities/{{entity}}.dart.tmpl` → `lib/domain/entities/x.dart` (freezed, field nullable, KHÔNG `fromJson`; nested entity nằm trong vùng custom).
2. **Repository (abstract)** render `api-feature/lib/domain/repositories/{{feature}}/{{entity}}_repository.dart.tmpl`.
3. **UseCase** render `api-feature/lib/domain/use_cases/{{feature}}/{{entity}}_use_case.dart.tmpl`.
4. **Endpoint** áp `api-feature/SNIPPETS.md` mục Endpoint vào `lib/data/datasource/core/api_endpoint.dart`.
5. **Model** render `api-feature/lib/data/models/{{feature}}/{{entity}}_model.dart.tmpl`; mỗi nested model render thêm `api-feature/lib/data/models/{{feature}}/{{entity}}_{{nested}}_model.dart.tmpl`.
6. **Mapper** render `api-feature/lib/data/mappers/{{entity}}_mapper.dart.tmpl` (nested extension trong vùng custom).
7. **Datasource** render `api-feature/lib/data/datasource/{{feature}}/{{entity}}_datasource.dart.tmpl` + `..._datasource_remote.dart.tmpl`.
8. **RepositoryImpl** render `api-feature/lib/data/repositories/{{feature}}/{{entity}}_repository_impl.dart.tmpl`.
9. **Chạy** `make build_runner`.
10. **DI bridge** áp `api-feature/SNIPPETS.md` mục Provider vào `lib/presentation/providers/di_providers.dart`.
11. **State** render `api-feature/lib/presentation/features/{{feature}}/{{entity}}_state.dart.tmpl`.
12. **ViewModel** render `api-feature/lib/presentation/features/{{feature}}/{{entity}}_viewmodel.dart.tmpl`.
13. **Screen** render `api-feature/lib/presentation/features/{{feature}}/{{entities}}_screen.dart.tmpl` (tên Screen số nhiều).
14. **Sub-widget** render `api-feature/lib/presentation/features/{{feature}}/widget/{{entity}}_item_view.dart.tmpl`.
15. **Route** áp `api-feature/SNIPPETS.md` mục Route vào `app_routes.dart` + `app_router.dart`.
16. **l10n** nếu có text mới: thêm key vào CẢ 3 file `assets/translations/{en-US,ja-JP,vi-VN}.json` (xem `api-feature/SNIPPETS.md` mục l10n), `make l10n`, dùng `LocaleKeys.xxx.tr()`.
17. **Tests** render đủ 4 file test của `api-feature/test/...` (mapper, repository impl, use case, viewmodel), chỉnh theo `flutter-write-tests`.

### local-feature
1. **Value type** render `local-feature/lib/domain/core/{{value_type}}.dart.tmpl` (enum, giả định dùng `.name`).
2. **Repository (abstract)** render `local-feature/lib/domain/repositories/{{feature}}/{{feature}}_repository.dart.tmpl`.
3. **UseCase** render `local-feature/lib/domain/use_cases/{{feature}}/{{feature}}_use_case.dart.tmpl`.
4. **Storage key** áp `local-feature/SNIPPETS.md` mục Storage key vào `lib/infrastructure/constants/storage_keys.dart`.
5. **RepositoryImpl** render `local-feature/lib/data/repositories/{{feature}}/{{feature}}_repository_impl.dart.tmpl` (`SharedPreferences`).
6. **Chạy** `make build_runner`.
7. **DI bridge** áp `local-feature/SNIPPETS.md` mục Provider vào `di_providers.dart`.
8. **ViewModel** render `local-feature/lib/presentation/{{feature}}/{{feature}}_viewmodel.dart.tmpl`; gắn vào app theo mục 3 của `local-feature/SNIPPETS.md`.
9. **Tests** render đủ 3 file test của `local-feature/test/...` (repository impl, use case, viewmodel).

### Cuối cùng (cả hai loại)
- **Verify** theo skill `flutter-verify` (gồm `grep -rn "tmpl:custom\|{{" lib test` phải rỗng); tự review bằng `flutter-review`.

## Đừng làm
- Đừng gọi `getIt` ngoài `di_providers.dart` (ARC-04); đừng gọi repository từ ViewModel (ARC-05); đừng import `data/` từ `presentation/` (ARC-02).
- Đừng `throw` trong datasource/repository; trả `Failure` (ERR-01).
- Đừng đặt mapper trong model (CLS-09), đừng thêm `fromJson` vào entity (MET-06).
- Đừng tạo thư mục sai tên: đúng là `datasource`, `repositories` (FIL-03).
- Đừng viết `XViewModel`, đúng `XViewmodel` (NAM-06); đừng hardcode text (L10N-01); đừng sửa file generated (GEN-01).
- Đừng đổi khung template ngoài vùng custom; đừng bỏ file test; đừng để sót dòng `tmpl:custom-*` hoặc `{{`.
- Đừng thêm package mới, đừng sửa code feature khác.
