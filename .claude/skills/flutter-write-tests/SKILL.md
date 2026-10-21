---
name: flutter-write-tests
description: Viết unit test theo mẫu của repo này (mapper, exception mapper, repository impl, use case, ViewModel với Riverpod override). Dùng khi user nói "viết test", "thêm test", "tăng coverage", "test cho X", hoặc sau khi thêm feature/API cần test.
---

# flutter-write-tests

Trước khi viết: đọc `docs/conventions.md` (nhóm rule liên quan: TST; thêm VAR-10 và DI-06 cho biến test và override).

## Quy ước chung
- `test/` mirror `lib/`: `test/data/mappers/`, `test/data/repositories/<feature>/`, `test/data/failures/`, `test/domain/use_cases/<feature>/`, `test/presentation/...`.
- Tên file `x_test.dart`.
- Mock: `@GenerateNiceMocks([MockSpec<X>()])` + `import 'x_test.mocks.dart';`. `*.mocks.dart` gitignore, sinh bằng `make build_runner`.
- Result: gọi `provideDummy<Result<...>>(...)` trước `when(...)`.

## Các bước
1. Xác định loại test và file mẫu (template tương đối từ `.claude/templates/`; test phải đủ như template: api-feature 4 loại, local-feature 3 loại):

| Đối tượng | Mẫu |
|---|---|
| Mapper | `api-feature/test/data/mappers/{{entity}}_mapper_test.dart.tmpl` (map đủ field + field null) |
| ExceptionMapper | `test/data/failures/exception_mapper_test.dart` (mỗi nhánh một test) |
| RepositoryImpl | `api-feature/test/data/repositories/{{feature}}/{{entity}}_repository_impl_test.dart.tmpl`; local: `local-feature/test/data/repositories/{{feature}}/{{feature}}_repository_impl_test.dart.tmpl` |
| UseCase | `api-feature/test/domain/use_cases/{{feature}}/{{entity}}_use_case_test.dart.tmpl`; local: `local-feature/test/domain/use_cases/{{feature}}/{{feature}}_use_case_test.dart.tmpl` |
| ViewModel | `api-feature/test/presentation/features/{{feature}}/{{entity}}_viewmodel_test.dart.tmpl`; local: `local-feature/test/presentation/{{feature}}/{{feature}}_viewmodel_test.dart.tmpl` |

2. **Repository**: mock datasource. Cover: Success map đúng entity (từng field), Success rỗng, Failure truyền nguyên error (NetworkError, ServerError...), `verify(...).called(1)`.
3. **UseCase**: mock repository; test delegate Success và Failure.
4. **Mapper**: test `toEntity()` đủ field và field null.
5. **ExceptionMapper**: một test cho mỗi nhánh DioException (connection*/timeout → NetworkError, 401/403 → AuthError, còn lại → ServerError kèm statusCode), FormatException → ParsingError, khác → UnexpectedError.
6. **ViewModel**: mock UseCase, dùng
   ```dart
   final container = ProviderContainer(
     overrides: [xUseCaseProvider.overrideWithValue(mockUseCase)],
   );
   addTearDown(container.dispose);
   final state = await container.read(xViewmodelProvider.future);
   ```
   Cover `XStateData` khi Success và `XStateError` khi Failure.
7. Chạy `make build_runner` (sinh mocks) rồi `fvm flutter test <file>`, cuối cùng `fvm flutter test`.

## Đừng làm
- Đừng gọi network thật hoặc dùng GetIt trong test; dùng mock + override (TST-18, DI-06).
- Đừng sửa `*.mocks.dart`; đừng commit file mocks.
- Đừng sửa code trong `lib/` để test dễ hơn nếu không nằm trong phạm vi; báo lại thay vì tự sửa.
- Đừng viết test chỉ kiểm tra mock (không có assertion có ý nghĩa).
