# Quy trình làm việc với AI Agent

Luật ngắn gọn agent luôn đọc: [CLAUDE.md](../CLAUDE.md). Tài liệu này mô tả quy trình end-to-end.

## 1. Nguyên tắc
- Agent đọc `CLAUDE.md` trước khi làm.
- Bám Country feature làm mẫu (`lib/**/country/`, `test/**/country*`).
- Thay đổi nhỏ, đúng phạm vi. Mơ hồ thì dừng và hỏi.

## 2. Vòng đời task
`Brief → Plan → Implement → Verify → Review → Commit/PR`

### 2.1 Brief (người giao việc điền)
```
Mục tiêu:
API / endpoint: <method> <url>
Sample JSON response:
Màn hình / UX: (list, detail, loading, empty, error, route)
Error case: (network, 401/403, 5xx, parse lỗi, rỗng)
Acceptance criteria:
- [ ] ...
```

### 2.2 Plan
- Agent liệt kê file sẽ tạo/sửa theo layer (domain / data / infrastructure / presentation / route / l10n / test).
- Chờ người giao việc duyệt rồi mới code.

### 2.3 Implement (thứ tự)
1. domain: entity → repository (abstract) → use case
2. data: model → mapper → datasource (abstract + remote) → repository impl; endpoint trong `APIEndpoint`
3. infrastructure (DI): annotation injectable, `make build_runner`; thêm `xUseCaseProvider` vào `di_providers.dart`
4. presentation: state → viewmodel → screen → widget
5. route (`app_routes.dart`, `app_router.dart`) + l10n (3 file JSON, `make l10n`)
6. test (mirror cấu trúc `lib/`)

### 2.4 Verify
Skill `flutter-verify`.

### 2.5 Review
Skill `flutter-review` trên diff.

### 2.6 Commit/PR
- Chỉ commit khi được yêu cầu. Message tiếng Anh, ngắn, imperative (hoặc prefix `refactor:`).
- Nhánh `feature/...`, `fix/...`, `update/...`; PR vào `develop`, sau đó `develop` → `main`.
- CI: `make USE_FVM=false`, `flutter test`, build apk flavor develop.

## 3. Tôi muốn… → dùng skill nào
| Tôi muốn… | Skill |
|---|---|
| Tạo feature mới nguyên vertical slice | `flutter-new-feature` |
| Thêm endpoint / use case vào feature có sẵn | `flutter-add-api` |
| Viết / bổ sung test | `flutter-write-tests` |
| Chạy codegen, analyze, test, kiểm tra DoD | `flutter-verify` |
| Review diff trước khi tạo PR | `flutter-review` |

## 4. Phân vai orchestrator / subagent (gợi ý tùy chọn, không bắt buộc)
| Vai | Việc |
|---|---|
| Orchestrator | Làm rõ yêu cầu, thiết kế, giao việc, review kết quả |
| `coder-sonnet` | Việc cơ học theo pattern có sẵn (thêm API, mapper, test theo mẫu) |
| `coder-opus` | Logic phức tạp, quyết định thiết kế, debug khó. **Cần user đồng ý trước khi dùng** |

- Subagent gặp điểm mơ hồ thì trả câu hỏi về, orchestrator hỏi user rồi giao lại với thông tin bổ sung.

## 5. Template prompt giao việc
```
Mục tiêu: <1-2 câu>
Spec:
- Input/Output: ...
- Endpoint + sample JSON: ...
- Edge case / error case: ...
- Nhất quán với: Country feature (đường dẫn file mẫu)
Skill áp dụng: <flutter-new-feature | flutter-add-api | ...>
Phạm vi: chỉ tạo/sửa <danh sách file/layer>. Không đụng chỗ khác.
Acceptance criteria:
- [ ] ...
- [ ] fvm flutter analyze sạch, fvm flutter test pass
Nếu có điểm mơ hồ: DỪNG và hỏi, không đoán.
Báo cáo: danh sách file đã đổi + tóm tắt thay đổi.
```

## 6. Definition of Done
- [ ] `fvm flutter analyze` sạch
- [ ] `fvm flutter test` pass
- [ ] Đã chạy `make build_runner` / `make l10n` nếu đổi model/state/viewmodel/injectable/l10n/mocks
- [ ] Không sửa file generated (`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`, `*.mocks.dart`)
- [ ] Không import sai layer (domain không import data/presentation/flutter/dio; presentation không import data)
- [ ] Text hiển thị qua l10n (3 file JSON đủ key)
- [ ] Lỗi trả `Result`/`Failure`, không throw ra ngoài datasource
- [ ] Không thêm package mới ngoài yêu cầu

## 7. Anti-pattern hay gặp của AI trong repo này
| Sai | Đúng |
|---|---|
| Gọi `getIt` trong ViewModel/Screen | `ref.watch(xUseCaseProvider)`; `getIt` chỉ ở `di_providers.dart` |
| Import `data/` từ `presentation/` | Đi qua UseCase/entity ở domain |
| ViewModel gọi repository | Chỉ gọi UseCase |
| `throw` thay vì `Failure` | Trả `Failure(AppError)` |
| Hardcode string trên UI | `LocaleKeys.xxx.tr()` + 3 file JSON |
| Sửa `*.g.dart`, `*.freezed.dart`, `*.config.dart` | `make build_runner` |
| Thêm package mới không hỏi | Hỏi trước |
| Đặt `toEntity()` trong model | Extension trong `data/mappers/x_mapper.dart` |
| Tạo thư mục `datasources` / `repository` | `datasource` (số ít), `repositories` (số nhiều) |
| Đặt `fromJson` cho entity | `fromJson` chỉ ở `XModel` |
| Viết `XViewModel` | `XViewmodel` (m thường) |
| `print` | `LoggerService` |
| Refactor/format ngoài phạm vi | Chỉ sửa đúng yêu cầu |

## 8. Bảo trì
- Quy ước đổi (layer, naming, lệnh, cấu trúc thư mục) thì cập nhật `CLAUDE.md` + các `SKILL.md` liên quan trong CÙNG PR.
- Khi Country feature (file mẫu) đổi tên/vị trí, cập nhật đường dẫn trong skills.
