---
name: flutter-verify
description: Chạy codegen, analyze, test và kiểm tra Definition of Done cho repo này. Dùng khi user nói "verify", "kiểm tra lại", "chạy analyze/test", "đã xong chưa", hoặc ngay sau khi implement xong một thay đổi, trước review/commit.
---

# flutter-verify

Dùng `fvm flutter` / `fvm dart`. CI dùng `make USE_FVM=false` (không FVM).

Đọc `docs/conventions.md` mục 1.2 (nhóm rule liên quan: cổng máy, tức rule `[lint]` do `fvm flutter analyze` kiểm và rule `[test]` do `fvm flutter test` kiểm). Test kiến trúc (`test/architecture/`) là cổng cho rule `[test]`; thông báo lỗi có mã rule (vd `FIL-05`): tra mã đó trong `docs/conventions.md` và sửa CODE theo rule, KHÔNG sửa/nới test.

## Các bước
1. Xác định thay đổi có đụng: model/state/viewmodel/`@injectable`/`@GenerateNiceMocks` (cần build_runner) và `assets/translations/*.json` (cần l10n).
2. Codegen khi cần:
   - `make l10n` (sinh `lib/generated/locale_keys.g.dart`)
   - `make build_runner` (= `fvm dart run build_runner build -d`)
   - Cần cả pipeline (pub get, clean...): `make`.
3. Format: `fvm dart format <file đã đổi>` (formatter `trailing_commas: preserve`). Chỉ format file mình đã sửa. Kiểm an toàn như CI (không ghi file): `fvm dart format --output=none --set-exit-if-changed <file>` hoặc `lib test` (bỏ file generated). CẢNH BÁO: lệnh `dart format` không có `--output=none` sẽ GHI ĐÈ file; không chạy lên thư mục khi chỉ cần kiểm.
4. Analyze: `fvm flutter analyze` — phải sạch (generated đã exclude).
5. Test: `fvm flutter test` (hoặc `fvm flutter test <file>` khi lặp nhanh, cuối cùng chạy toàn bộ).
6. Kiểm tra `git status`: không có file generated bị track/sửa, không có file ngoài phạm vi.
7. Nếu có feature mới từ template: `grep -rn "tmpl:custom\|{{" lib test` phải không còn kết quả.
8. Đối chiếu Definition of Done bên dưới, báo kết quả (lệnh nào pass/fail, lỗi còn lại).

## Definition of Done
- [ ] `fvm flutter analyze` sạch
- [ ] `fvm flutter test` pass
- [ ] Đã chạy `make build_runner` / `make l10n` nếu cần
- [ ] Không sửa file generated
- [ ] Không import sai layer (domain không import flutter/dio/data/presentation; presentation không import data). Đã có test máy kiểm tra trong `fvm flutter test` (`test/architecture/layer_rules_test.dart`: ARC-01..05, ARC-08). Test fail thì sửa code theo mã rule, KHÔNG sửa/nới test
- [ ] Text qua l10n, đủ key ở 3 file JSON
- [ ] Lỗi trả `Result`, không throw ra ngoài datasource
- [ ] Không thêm package mới ngoài yêu cầu

Ghi chú: hook project (`.claude/settings.json` → `.claude/hooks/`) chặn sửa tay file generated, hỏi trước khi sửa `pubspec.yaml`, và tự format file `.dart`. CI chạy `flutter analyze` + `flutter test`.

## Đừng làm
- Đừng sửa tay `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`, `*.mocks.dart` để "qua" analyze; chạy lại build_runner.
- Đừng comment/xóa test hoặc hạ lint để pass; báo lỗi thật.
- Đừng chạy `make clean`/`make rename` hoặc `flutter clean` nếu không cần/không được yêu cầu.
- Đừng commit/push trong bước verify.
- Đừng bỏ qua kết quả `grep -rn "tmpl:custom\|{{" lib test`: còn dòng marker hoặc `{{` nghĩa là render template chưa xong.
- Lỗi build_runner/analyze nằm ngoài phạm vi thay đổi: báo lại, đừng tự sửa lan rộng.
