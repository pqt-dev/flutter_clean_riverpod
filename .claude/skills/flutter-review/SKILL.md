---
name: flutter-review
description: Review diff theo quy ước của repo này (layer rule, naming, error handling, DI, l10n, generated, test). Dùng khi user nói "review", "kiểm tra diff", "check trước khi tạo PR", hoặc sau khi agent implement xong.
---

# flutter-review

Nguồn chuẩn: `docs/conventions.md` (mỗi rule có mã `<NHÓM>-<nn>` và nhãn `[lint]`/`[test]`/`[review]`). Thứ tự ưu tiên khi mâu thuẫn: docs/conventions.md > .claude/templates > skills > CLAUDE.md > code mẫu Theme.

## Các bước
1. **Lấy diff**: `git status` và `git diff` (cộng `git diff --staged` nếu có); đọc từng file đã đổi, không chỉ diff.
2. **Cổng máy**: chạy `fvm flutter analyze` và `fvm flutter test`. Mọi lỗi ở đây đã có mã rule (rule `[lint]` và `[test]`; thông báo của test kiến trúc có mã rule). Ghi lại lỗi kèm mã rule; chưa xanh thì chưa kết luận OK.
3. **Review rule `[review]`** của `docs/conventions.md` theo từng NHÓM: ARC, FIL, NAM, MET, VAR, IMP, CLS, API/LOC, ERR, DI, UI, L10N, TST, STY, GEN (và SCP/STP khi yêu cầu có thể nằm ngoài phạm vi). Chỉ cần đi qua các nhóm liên quan tới file đã đổi (vd: đổi viewmodel thì xét ARC, NAM, MET, VAR, CLS, ERR, DI, UI). Với mỗi nhóm, đọc các rule `[review]` của nhóm đó và đối chiếu diff.
4. **Ghi phát hiện**: mỗi phát hiện gồm `file:dòng`, mã rule, mức (must-fix / nên sửa / nit).
5. **Feature mới đúng template** (`.claude/templates/`, xem `README.md` ở đó):
   - [ ] Đủ file set theo template (api-feature: 4 loại test; local-feature: 3 loại test)
   - [ ] Tên file/class theo token (số ít/số nhiều đúng; Screen số nhiều)
   - [ ] Chỉ khác template ở vùng custom
   - [ ] Không còn dòng `tmpl:custom-*`, không còn `{{`
6. **Báo cáo**: danh sách vấn đề theo mức độ, kết luận (OK / cần sửa). Không tự sửa code trừ khi được yêu cầu.

## Đừng làm
- Đừng nit-pick style thuần format; formatter xử lý.
- Đừng yêu cầu sửa thứ nằm ngoài diff; chỉ ghi nhận nếu diff nhân rộng vấn đề đó.
- Đừng tự sửa code khi đang review; báo cáo rồi chờ quyết định.
- Đừng kết luận OK nếu chưa thấy kết quả `flutter-verify` (analyze + test xanh).
