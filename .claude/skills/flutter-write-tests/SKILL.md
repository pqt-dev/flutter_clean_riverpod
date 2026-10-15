---
name: flutter-write-tests
description: Viết unit test theo mẫu của repo flutter_clean_riverpod (mapper, exception mapper, repository impl, use case, ViewModel với Riverpod override). Dùng khi user nói "viết test", "thêm test", "tăng coverage", "test cho X", hoặc sau khi thêm feature/API cần test.
---

# flutter-write-tests

## Quy ước chung
- `test/` mirror `lib/`: `test/data/mappers/`, `test/data/repositories/<feature>/`, `test/data/failures/`, `test/domain/use_cases/<feature>/`, `test/presentation/...`.
- Tên file `x_test.dart`. Thư mục `test/data/repository` (số ít) là cũ/trùng: KHÔNG đặt test mới ở đó.
- Mock: `@GenerateNiceMocks([MockSpec<X>()])` + `import 'x_test.mocks.dart';`. `*.mocks.dart` gitignore, sinh bằng `make build_runner`.
- Result: gọi `provideDummy<Result<...>>(...)` trước `when(...)`.

## Các bước
1. Xác định loại test và file mẫu:

| Đối tượng | Mẫu |
|---|---|
| Mapper | `test/data/mappers/country_mapper_test.dart` (map đủ field + field null) |
| ExceptionMapper | `test/data/failures/exception_mapper_test.dart` (mỗi nhánh một test) |
| RepositoryImpl | `test/data/repositories/country/country_repository_impl_test.dart` |
| UseCase | `test/domain/use_cases/country/country_use_case_test.dart` |
| ViewModel | `test/presentation/home/country_viewmodel_test.dart`, `test/presentation/theme/theme_viewmodel_test.dart` |

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
- Đừng gọi network thật hoặc dùng GetIt trong test; dùng mock + override.
- Đừng sửa `*.mocks.dart`; đừng commit file mocks.
- Đừng sửa code trong `lib/` để test dễ hơn nếu không nằm trong phạm vi; báo lại thay vì tự sửa.
- Đừng sao chép thư mục cũ `test/data/repository`.
- Đừng viết test chỉ kiểm tra mock (không có assertion có ý nghĩa).
