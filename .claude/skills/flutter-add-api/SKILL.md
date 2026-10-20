---
name: flutter-add-api
description: Thêm một endpoint / use case mới vào feature ĐÃ CÓ trong repo này (datasource → repository → use case → viewmodel). Dùng khi user nói "thêm API", "thêm endpoint", "thêm use case", "gọi thêm API cho feature X", "add method to repository". Không dùng để tạo cả feature mới (dùng flutter-new-feature).
---

# flutter-add-api

Placeholder: `X`/`x` = feature đã có, `fetchY` = tên method mới. Mẫu: template `api-feature` trong `.claude/templates/` (tên tương đối bên dưới); feature đã có phải giữ đúng pattern đó.

## Trước khi làm
- Đọc `CLAUDE.md`, `docs/conventions.md` (nhóm rule liên quan: MET, API, ERR, DI, TST) và các file hiện có của feature. Cần: method + URL, params, sample JSON, error case. Thiếu: DỪNG và hỏi.
- Liệt kê file sẽ sửa/tạo, chờ duyệt.

## Các bước
1. **Endpoint** thêm hằng số path vào `lib/data/datasource/core/api_endpoint.dart` (mẫu: mục Endpoint trong `api-feature/SNIPPETS.md`).
2. **Model** (nếu JSON mới) `lib/data/models/<feature>/y_model.dart` freezed + `fromJson`; **Entity** tương ứng ở `lib/domain/entities/`; **Mapper** thêm extension vào `lib/data/mappers/x_mapper.dart`. Mẫu: `api-feature/lib/data/models/{{feature}}/{{entity}}_model.dart.tmpl`, `api-feature/lib/data/mappers/{{entity}}_mapper.dart.tmpl`.
3. **Datasource** thêm method vào `XDatasource` (abstract) và `XDatasourceRemote`, dùng `client.request(endpoint:, method: ApiMethod.get|post|put|patch|delete, decoder:, queryParameters:, data:)`. Mẫu: `api-feature/lib/data/datasource/{{feature}}/{{entity}}_datasource_remote.dart.tmpl`.
4. **Repository** thêm method vào `XRepository` (domain, `Future<Result<T>>`) và `XRepositoryImpl` (switch sealed Result, map model → entity, Failure giữ nguyên). Mẫu: `api-feature/lib/data/repositories/{{feature}}/{{entity}}_repository_impl.dart.tmpl`.
5. **UseCase** thêm method vào `XUseCase` (delegate repository). Mẫu: `api-feature/lib/domain/use_cases/{{feature}}/{{entity}}_use_case.dart.tmpl`. Nếu use case là class mới: `@lazySingleton` + thêm provider vào `di_providers.dart`.
6. **State/ViewModel** nếu cần: mở rộng `XState`; xử lý trong `XViewmodel` bằng `ref.watch(xUseCaseProvider)` + switch Result. Thêm UI/route/l10n nếu brief yêu cầu.
7. **Chạy** `make build_runner` nếu đổi model/state/viewmodel/injectable; `make l10n` nếu đổi translations.
8. **Test** theo `flutter-write-tests` (mẫu: `api-feature/test/...`): cập nhật mock, mapper, repository (Success + Failure), use case, viewmodel.
9. **Verify** theo `flutter-verify`.

## Đừng làm
- Template không phủ trường hợp (state khác, nguồn dữ liệu khác...): DỪNG và hỏi.
- Đừng `try/catch` trong datasource (API-05, ERR-02); `ApiClient.request` đã map lỗi qua `ExceptionMapper`.
- Đừng gọi `getIt` trong ViewModel (DI-04, ARC-04); đừng gọi repository từ ViewModel (ARC-05).
- Đừng đổi chữ ký method đang dùng nếu không nằm trong phạm vi (sẽ làm vỡ test/caller).
- Đừng hardcode base URL/path ngoài `APIEndpoint` (API-01, FIL-10).
- Đừng sửa file generated; đừng thêm package mới; đừng refactor phần không liên quan.
