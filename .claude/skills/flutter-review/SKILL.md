---
name: flutter-review
description: Review diff theo quy ước của repo flutter_clean_riverpod (layer rule, naming, error handling, DI, l10n, generated, test). Dùng khi user nói "review", "kiểm tra diff", "check trước khi tạo PR", hoặc sau khi agent implement xong.
---

# flutter-review

## Các bước
1. Lấy diff: `git status` và `git diff` (cộng `git diff --staged` nếu có); đọc từng file đã đổi, không chỉ diff.
2. Đi qua checklist dưới, ghi mỗi vấn đề kèm `file:dòng`, mức độ (must-fix / nên sửa / nit).
3. Đối chiếu với Country feature: `lib/domain/**/country*`, `lib/data/**/country*`, `lib/presentation/features/country/`.
4. Báo cáo: danh sách vấn đề theo mức độ, kết luận (OK / cần sửa). Không tự sửa code trừ khi được yêu cầu.

## Checklist
**Layer rule**
- [ ] `domain/` không import flutter, dio, `data/`, `presentation/`
- [ ] `presentation/` không import `data/`
- [ ] `getIt` chỉ xuất hiện trong `presentation/providers/di_providers.dart` (trong presentation)
- [ ] ViewModel chỉ dùng UseCase qua `ref.watch(xUseCaseProvider)`, không gọi repository

**Naming & vị trí**
- [ ] File snake_case, hậu tố đúng: Screen, State, Viewmodel (m thường), UseCase, Repository, RepositoryImpl, Datasource, DatasourceRemote, Model, ItemView
- [ ] Thư mục: `datasource` (số ít), `repositories`, feature số ít
- [ ] Mapper ở `data/mappers/x_mapper.dart` dạng extension `toEntity()`, không nằm trong model
- [ ] Entity freezed, không `fromJson`, field nullable; Model có `fromJson`

**Error handling**
- [ ] Trả `Result<T>`; không `throw` ra ngoài datasource/repository
- [ ] RepositoryImpl switch sealed Result; Failure truyền nguyên `AppError`
- [ ] ViewModel xử lý cả Success và Failure → `XStateData` / `XStateError`
- [ ] Screen xử lý AsyncLoading, Data, Error (state), AsyncError; có retry `ref.invalidate(...)`

**DI**
- [ ] `@lazySingleton` (UseCase), `@LazySingleton(as: ...)` (Remote, RepositoryImpl)
- [ ] Provider mới đã thêm vào `di_providers.dart`

**l10n / UI**
- [ ] Không hardcode text; key có đủ ở 3 file `en-US`, `ja-JP`, `vi-VN`
- [ ] Dùng widget chung ở `features/widgets/` khi có; route khai báo ở `app_routes.dart` + `app_router.dart`

**Generated / phạm vi**
- [ ] Không sửa tay file generated; không commit `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`, `*.mocks.dart`
- [ ] Không thêm package mới (`pubspec.yaml`/`pubspec.lock`) ngoài yêu cầu
- [ ] Không refactor/format ngoài phạm vi; không `print` (dùng `LoggerService`)
- [ ] Import `package:flutter_clean_riverpod/...` xuyên layer; bám style file hiện có

**Test**
- [ ] Có test tương ứng theo `flutter-write-tests`; đặt đúng thư mục mirror `lib/`
- [ ] Repository test cover Success map đúng + Failure giữ nguyên error
- [ ] ViewModel test dùng `ProviderContainer` override + `addTearDown(container.dispose)`

## Đừng làm
- Đừng nit-pick style thuần format; formatter xử lý.
- Đừng yêu cầu sửa thứ nằm ngoài diff — chỉ ghi nhận nếu diff nhân rộng vấn đề đó.
- Đừng tự sửa code khi đang review; báo cáo rồi chờ quyết định.
- Đừng kết luận OK nếu chưa chạy/đã thấy kết quả `flutter-verify`.
