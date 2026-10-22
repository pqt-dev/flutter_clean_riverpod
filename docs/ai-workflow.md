# Quy trình làm việc với AI Agent

Luật ngắn gọn agent luôn đọc: [CLAUDE.md](../CLAUDE.md). Quy ước chi tiết (nguồn chuẩn): [conventions.md](conventions.md). Dùng boilerplate cho project mới: [boilerplate-guide.md](boilerplate-guide.md). Tài liệu này mô tả quy trình end-to-end.

## 1. Nguyên tắc
- Agent đọc `CLAUDE.md` trước khi làm; trước khi tạo/sửa feature đọc thêm `docs/conventions.md` (nguồn chuẩn duy nhất của quy ước, rule có mã).
- Thứ tự ưu tiên khi mâu thuẫn: docs/conventions.md > .claude/templates > skills > CLAUDE.md > code mẫu Theme.
- Bám template trong `.claude/templates/` (bản hiện thực của conventions.md; xem `README.md` ở đó); feature Theme nếu còn chỉ là ví dụ.
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
5. route (`app_routes.dart`, `app_router.dart`; áp snippet vào cả hai file, thêm `routes: [...]` vào `GoRoute` của home nếu chưa có) + l10n (3 file JSON, `make l10n`)
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

Bắt đầu project mới từ boilerplate này (đổi tên, tạo feature đầu tiên): xem [boilerplate-guide.md](boilerplate-guide.md).

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
- Nhất quán với: template `.claude/templates/<api-feature|local-feature>`
Skill áp dụng: <flutter-new-feature | flutter-add-api | ...>
Phạm vi: chỉ tạo/sửa <danh sách file/layer>. Không đụng chỗ khác.
Acceptance criteria:
- [ ] ...
- [ ] fvm flutter analyze sạch, fvm flutter test pass
Nếu có điểm mơ hồ: DỪNG và hỏi, không đoán.
Báo cáo: danh sách file đã đổi + tóm tắt thay đổi.
```

## 6. Definition of Done
Checklist đầy đủ nằm ở skill `flutter-verify` (nguồn duy nhất). Khi đổi DoD chỉ cần sửa ở đó.

## 7. Anti-pattern hay gặp của AI trong repo này
| Sai | Đúng | Rule |
|---|---|---|
| Gọi `getIt` trong ViewModel/Screen | `ref.watch(xUseCaseProvider)`; `getIt` chỉ ở `di_providers.dart` | ARC-04, DI-04 |
| Import `data/` từ `presentation/` | Đi qua UseCase/entity ở domain | ARC-02 |
| ViewModel gọi repository | Chỉ gọi UseCase | ARC-05 |
| `throw` thay vì `Failure` | Trả `Failure(AppError)` | ERR-01 |
| Hardcode string trên UI | `LocaleKeys.xxx.tr()` + 3 file JSON | L10N-01, L10N-02 |
| Sửa `*.g.dart`, `*.freezed.dart`, `*.config.dart` | `make build_runner` | GEN-01, GEN-03 |
| Thêm package mới không hỏi | Hỏi trước | (CLAUDE.md) |
| Đặt `toEntity()` trong model | Extension trong `data/mappers/x_mapper.dart` | CLS-09, FIL-07 |
| Tạo thư mục `datasources` / `repository` | `datasource` (số ít), `repositories` (số nhiều) | FIL-03 |
| Đặt `fromJson` cho entity | `fromJson` chỉ ở `XModel` | MET-06 |
| Viết `XViewModel` | `XViewmodel` (m thường) | NAM-06 |
| `print` | `LoggerService` | ARC-08 |
| Refactor/format ngoài phạm vi | Chỉ sửa đúng yêu cầu | (CLAUDE.md) |
| Tự chế cấu trúc/đặt tên khác template | Render từ template; ca chưa phủ thì dừng và hỏi | STP-01, FIL-12 |
| Bỏ file test của feature | Đủ 4 loại test như template (local: 3) | TST-02 |

## 8. Bảo trì
- Nguồn chuẩn là `docs/conventions.md`; template là bản hiện thực của nó. Thứ tự ưu tiên khi mâu thuẫn: docs/conventions.md > .claude/templates > skills > CLAUDE.md > code mẫu Theme.
- Sửa quy ước (layer, naming, code style, cấu trúc thư mục) thì sửa `docs/conventions.md` + template + skill liên quan trong CÙNG PR; `CLAUDE.md` chỉ cập nhật khi đổi lệnh, bảng skill hoặc mã rule được trích dẫn.
- DoD chỉ sửa ở skill `flutter-verify`; không chép lại checklist vào `CLAUDE.md` hay tài liệu này.
