---
name: flutter-verify
description: Chạy codegen, analyze, test và kiểm tra Definition of Done cho repo flutter_clean_riverpod. Dùng khi user nói "verify", "kiểm tra lại", "chạy analyze/test", "đã xong chưa", hoặc ngay sau khi implement xong một thay đổi, trước review/commit.
---

# flutter-verify

Dùng `fvm flutter` / `fvm dart`. CI dùng `make USE_FVM=false` (không FVM).

## Các bước
1. Xác định thay đổi có đụng: model/state/viewmodel/`@injectable`/`@GenerateNiceMocks` (cần build_runner) và `assets/translations/*.json` (cần l10n).
2. Codegen khi cần:
   - `make l10n` (sinh `lib/generated/locale_keys.g.dart`)
   - `make build_runner` (= `fvm dart run build_runner build -d`)
   - Cần cả pipeline (pub get, clean...): `make`.
3. Format: `fvm dart format <file đã đổi>` (formatter `trailing_commas: preserve`). Chỉ format file mình đã sửa.
4. Analyze: `fvm flutter analyze` — phải sạch (generated đã exclude).
5. Test: `fvm flutter test` (hoặc `fvm flutter test <file>` khi lặp nhanh, cuối cùng chạy toàn bộ).
6. Kiểm tra `git status`: không có file generated bị track/sửa, không có file ngoài phạm vi.
7. Đối chiếu Definition of Done bên dưới, báo kết quả (lệnh nào pass/fail, lỗi còn lại).

## Definition of Done
- [ ] `fvm flutter analyze` sạch
- [ ] `fvm flutter test` pass
- [ ] Đã chạy `make build_runner` / `make l10n` nếu cần
- [ ] Không sửa file generated
- [ ] Không import sai layer (domain không import flutter/dio/data/presentation; presentation không import data)
- [ ] Text qua l10n, đủ key ở 3 file JSON
- [ ] Lỗi trả `Result`, không throw ra ngoài datasource
- [ ] Không thêm package mới ngoài yêu cầu

## Đừng làm
- Đừng sửa tay `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`, `*.mocks.dart` để "qua" analyze; chạy lại build_runner.
- Đừng comment/xóa test hoặc hạ lint để pass; báo lỗi thật.
- Đừng chạy `make clean`/`make rename` hoặc `flutter clean` nếu không cần/không được yêu cầu.
- Đừng commit/push trong bước verify.
- Lỗi build_runner/analyze nằm ngoài phạm vi thay đổi: báo lại, đừng tự sửa lan rộng.
