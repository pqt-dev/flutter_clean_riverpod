---
name: flutter-add-api
description: Thêm một endpoint / use case mới vào feature ĐÃ CÓ trong repo flutter_clean_riverpod (datasource → repository → use case → viewmodel). Dùng khi user nói "thêm API", "thêm endpoint", "thêm use case", "gọi thêm API cho feature X", "add method to repository". Không dùng để tạo cả feature mới (dùng flutter-new-feature).
---

# flutter-add-api

Placeholder: `X`/`x` = feature đã có, `fetchY` = tên method mới. Mẫu: Country feature.

## Trước khi làm
- Đọc `CLAUDE.md` và các file hiện có của feature. Cần: method + URL, params, sample JSON, error case. Thiếu: DỪNG và hỏi.
- Liệt kê file sẽ sửa/tạo, chờ duyệt.

## Các bước
1. **Endpoint** thêm hằng số path vào `lib/data/datasource/core/api_endpoint.dart`.
2. **Model** (nếu JSON mới) `lib/data/models/<feature>/y_model.dart` freezed + `fromJson`; **Entity** tương ứng ở `lib/domain/entities/`; **Mapper** thêm extension vào `lib/data/mappers/x_mapper.dart`. Mẫu: `country_model.dart`, `country_mapper.dart`.
3. **Datasource** thêm method vào `XDatasource` (abstract) và `XDatasourceRemote`, dùng `client.request(endpoint:, method: ApiMethod.get|post|put|patch|delete, decoder:, queryParameters:, data:)`. Mẫu: `country_datasource_remote.dart`.
4. **Repository** thêm method vào `XRepository` (domain, `Future<Result<T>>`) và `XRepositoryImpl` (switch sealed Result, map model → entity, Failure giữ nguyên). Mẫu: `country_repository_impl.dart`.
5. **UseCase** thêm method vào `XUseCase` (delegate repository). Mẫu: `country_use_case.dart`. Nếu use case là class mới: `@lazySingleton` + thêm provider vào `di_providers.dart`.
6. **State/ViewModel** nếu cần: mở rộng `XState`; xử lý trong `XViewmodel` bằng `ref.watch(xUseCaseProvider)` + switch Result. Thêm UI/route/l10n nếu brief yêu cầu.
7. **Chạy** `make build_runner` nếu đổi model/state/viewmodel/injectable; `make l10n` nếu đổi translations.
8. **Test** theo `flutter-write-tests`: cập nhật mock, mapper, repository (Success + Failure), use case, viewmodel.
9. **Verify** theo `flutter-verify`.

## Đừng làm
- Đừng `try/catch` trong datasource; `ApiClient.request` đã map lỗi qua `ExceptionMapper`.
- Đừng gọi `getIt` trong ViewModel; đừng gọi repository từ ViewModel.
- Đừng đổi chữ ký method đang dùng nếu không nằm trong phạm vi (sẽ làm vỡ test/caller).
- Đừng hardcode base URL/path ngoài `APIEndpoint`.
- Đừng sửa file generated; đừng thêm package mới; đừng refactor phần không liên quan.
