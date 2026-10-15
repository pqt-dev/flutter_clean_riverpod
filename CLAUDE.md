# CLAUDE.md — flutter_clean_riverpod

Flutter, Clean Architecture + Riverpod + injectable/get_it. Package: `flutter_clean_riverpod`. Dart ^3.10.
Quy trình đầy đủ: [docs/ai-workflow.md](docs/ai-workflow.md). Feature mẫu: **Country**.

## Nguyên tắc
- Đọc file này trước, bám Country feature làm mẫu, thay đổi nhỏ và đúng phạm vi.
- Mơ hồ / thiếu thông tin: dừng và hỏi, không đoán.
- Không thêm package mới, không refactor ngoài phạm vi, không commit/push nếu chưa được yêu cầu.
- Dùng FVM: `fvm flutter`, `fvm dart` (Makefile có `USE_FVM`).

## Skills (`.claude/skills/`)
| Việc | Skill |
|---|---|
| Feature mới (domain→data→presentation→route→l10n→test) | `flutter-new-feature` |
| Thêm endpoint/use case vào feature có sẵn | `flutter-add-api` |
| Viết test | `flutter-write-tests` |
| Codegen/analyze/test + Definition of Done | `flutter-verify` |
| Review diff theo quy ước | `flutter-review` |

## Layer (`lib/`)
| Layer | Nội dung | Không được import |
|---|---|---|
| `domain/` | `core/` (Result, AppError), `entities/`, `repositories/<feature>/`, `use_cases/<feature>/` | flutter, dio, data, presentation |
| `data/` | `datasource/core/` (ApiClient, APIEndpoint), `datasource/<feature>/`, `models/<feature>/`, `mappers/`, `repositories/<feature>/`, `failures/exception_mapper.dart` | presentation |
| `infrastructure/` | `constants/`, `di/`, `services/` | — |
| `presentation/` | `features/<feature>/`, `features/widgets/`, `providers/di_providers.dart`, `router/`, `theme/`, `dialogs/`, `extensions/` | **data** |

- Thư mục tên `datasource` (số ít, dù README ghi `datasources`), `repositories` (số nhiều), feature số ít (`country`, `theme`).
- `Result<T>` sealed: `Success(value)` / `Failure(error)`. `AppError` sealed: `NetworkError`, `ServerError`, `AuthError`, `ParsingError`, `UnexpectedError`.
- Lỗi trả về qua `Result`, không throw ra ngoài datasource. `ApiClient.request` đã bắt exception qua `ExceptionMapper`.

## Naming
File `snake_case`, class `PascalCase`, hậu tố cố định:

| Loại | File → Class |
|---|---|
| Entity | `domain/entities/x.dart` → `X` (freezed, không `fromJson`, field nullable) |
| Repository | `x_repository.dart` → `XRepository` (abstract, trả `Future<Result<T>>`) |
| UseCase | `x_use_case.dart` → `XUseCase` (`@lazySingleton`) |
| Datasource | `x_datasource.dart` → `XDatasource`; `x_datasource_remote.dart` → `XDatasourceRemote` (`@LazySingleton(as: XDatasource)`) |
| Model | `x_model.dart` → `XModel` (freezed + json_serializable, có `fromJson`) |
| Mapper | `data/mappers/x_mapper.dart` → `extension XModelMapper on XModel { X toEntity() }` (file riêng, không đặt trong model) |
| RepositoryImpl | `x_repository_impl.dart` → `XRepositoryImpl` (`@LazySingleton(as: XRepository)`) |
| State | `x_state.dart` → `@freezed sealed class XState` (`.data(...)` → `XStateData`, `.error(AppError)` → `XStateError`) |
| ViewModel | `x_viewmodel.dart` → `XViewmodel` (chữ **m** thường) → provider `xViewmodelProvider` |
| Screen | `x_screen.dart` → `XScreen extends ConsumerWidget` |
| Sub-widget | `widget/x_item_view.dart` → `XItemView` |

## Quy tắc presentation
- ViewModel: `@riverpod class XViewmodel extends _$XViewmodel`, `FutureOr<XState> build()`, lấy use case bằng `ref.watch(xUseCaseProvider)`, `switch` trên `Result`.
- ViewModel không gọi `getIt`, không gọi repository (chỉ UseCase).
- `presentation/providers/di_providers.dart` là nơi DUY NHẤT trong presentation được gọi `getIt`: `final xUseCaseProvider = Provider<XUseCase>((ref) => getIt<XUseCase>());`
- Screen: `switch` trên `AsyncValue` (loading → `AppLoader`, data Data/Error, error → `ErrorView`); retry bằng `ref.invalidate(xViewmodelProvider)`.
- Widget dùng chung ở `features/widgets/` (AppButton, AppText, AppTextField, AppLoader, AppBarView, ErrorView); route khai báo ở `router/app_routes.dart` + `app_router.dart`.

## Import
- Xuyên layer: `package:flutter_clean_riverpod/...`. Trong cùng feature/thư mục code hiện có lẫn relative: bám style của file đang sửa.

## l10n / assets
- `easy_localization`; thêm key vào CẢ 3 file `assets/translations/{en-US,ja-JP,vi-VN}.json`, rồi `make l10n`; dùng `LocaleKeys.xxx.tr()`.
- Text mới bắt buộc qua l10n. Message lỗi hiển thị cho user qua extension `AppErrorL10n.localizedMessage` (`presentation/extensions/app_error_extension.dart`), không hiển thị `error.toString()`/`AppError.message` thô.
- Asset/màu qua flutter_gen (`assets.gen.dart`, `colors.gen.dart`; nguồn `assets/colors/colors.xml`).

## Generated code
- `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`, `*.mocks.dart` đã gitignore: KHÔNG sửa tay.
- Sau khi đổi model/state/viewmodel/`@injectable`/`@GenerateNiceMocks`: `make build_runner` (= `fvm dart run build_runner build -d`).
- `make` (all) = check_version, clean, pub_get, l10n, build_runner.

## Logging / Lint
- Dùng `LoggerService` (`infrastructure/services/logger_service.dart`), không `print`.
- Lint: flutter_lints; analyzer exclude generated; formatter `trailing_commas: preserve`.

## Test
- `test/` mirror `lib/`: `test/data/repositories/...`, `test/domain/use_cases/...`, `test/presentation/...`. Thư mục `test/data/repository` là cũ/trùng, không dùng cho test mới.
- Mockito `@GenerateNiceMocks` + `provideDummy<Result<...>>(...)`; ViewModel test dùng `ProviderContainer(overrides: [...])` + `addTearDown(container.dispose)`.
- Chi tiết: skill `flutter-write-tests`.

## Git
- `develop` là nhánh tích hợp; nhánh `feature/...`, `fix/...`, `update/...`; PR vào `develop` rồi `main`.
- CI chạy `make USE_FVM=false`, `flutter test`, build apk flavor develop.
- Commit message tiếng Anh, câu ngắn imperative hoặc prefix `refactor:`.

## Definition of Done
`fvm flutter analyze` sạch, `fvm flutter test` pass, đã chạy `make build_runner`/`make l10n` nếu cần, không sửa file generated, không import sai layer, text qua l10n. Chi tiết: skill `flutter-verify`.
