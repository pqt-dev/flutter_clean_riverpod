---
name: flutter-new-feature
description: Tạo một feature mới theo vertical slice (domain → data → DI → presentation → route → l10n → test) trong repo flutter_clean_riverpod. Dùng khi user nói "tạo feature", "thêm màn hình/module mới", "new feature", "add screen with API". Không dùng để thêm endpoint vào feature đã có (dùng flutter-add-api).
---

# flutter-new-feature

Placeholder: `X` = tên entity PascalCase, `x` = snake_case, `<feature>` = tên thư mục số ít. Mẫu: Country feature.

## Trước khi làm
- Đọc `CLAUDE.md`. Cần đủ: endpoint + sample JSON, UX màn hình, error case. Thiếu hoặc mơ hồ: DỪNG và hỏi.
- Liệt kê file sẽ tạo theo layer, chờ duyệt.

## Các bước
1. **Entity** `lib/domain/entities/x.dart` — freezed `abstract class X with _$X`, field nullable, KHÔNG `fromJson`. Mẫu: `lib/domain/entities/country.dart`.
2. **Repository (abstract)** `lib/domain/repositories/<feature>/x_repository.dart` — `Future<Result<T>>`. Mẫu: `country_repository.dart`.
3. **UseCase** `lib/domain/use_cases/<feature>/x_use_case.dart` — `@lazySingleton`, inject repository qua constructor. Mẫu: `country_use_case.dart`.
4. **Endpoint** thêm hằng số path vào `lib/data/datasource/core/api_endpoint.dart` (`APIEndpoint`).
5. **Model** `lib/data/models/<feature>/x_model.dart` — freezed + json_serializable, `part 'x_model.freezed.dart'; part 'x_model.g.dart';`, có `fromJson`. Mẫu: `country_model.dart`.
6. **Mapper** `lib/data/mappers/x_mapper.dart` — `extension XModelMapper on XModel { X toEntity() }` (nested model có extension riêng). Mẫu: `country_mapper.dart`.
7. **Datasource** `lib/data/datasource/<feature>/x_datasource.dart` (abstract) + `x_datasource_remote.dart` (`@LazySingleton(as: XDatasource)`, dùng `client.request(endpoint:, method: ApiMethod.get, decoder:)`). Mẫu: `country_datasource*.dart`.
8. **RepositoryImpl** `lib/data/repositories/<feature>/x_repository_impl.dart` — `@LazySingleton(as: XRepository)`, `switch` sealed `Result` map model → entity, Failure truyền nguyên error. Mẫu: `country_repository_impl.dart`.
9. **Chạy** `make build_runner` (sinh freezed/json/injection.config).
10. **DI bridge** thêm vào `lib/presentation/providers/di_providers.dart`: `final xUseCaseProvider = Provider<XUseCase>((ref) => getIt<XUseCase>());`
11. **State** `lib/presentation/features/<feature>/x_state.dart` — `@freezed sealed class XState` với `.data(...)` → `XStateData`, `.error(AppError)` → `XStateError`. Mẫu: `country_state.dart`.
12. **ViewModel** `x_viewmodel.dart` — `@riverpod class XViewmodel extends _$XViewmodel`, `FutureOr<XState> build()`, `ref.watch(xUseCaseProvider)`, `switch` Result. Mẫu: `country_viewmodel.dart`.
13. **Screen** `x_screen.dart` — `XScreen extends ConsumerWidget`, `switch` AsyncValue (AsyncLoading → `AppLoader`, AsyncData Data/Error, AsyncError → `ErrorView`), retry `ref.invalidate(xViewmodelProvider)`. Mẫu: `countries_screen.dart`.
14. **Sub-widget** `widget/x_item_view.dart` → `XItemView`; dùng widget chung `features/widgets/` (AppText, AppLoader...). Mẫu: `country/widget/country_item_view.dart`.
15. **Route** thêm hằng số vào `lib/presentation/router/app_routes.dart` + `GoRoute` trong `app_router.dart`.
16. **l10n** thêm key vào CẢ 3 file `assets/translations/{en-US,ja-JP,vi-VN}.json`, chạy `make l10n`, dùng `LocaleKeys.xxx.tr()`.
17. **Tests** theo skill `flutter-write-tests` (mapper, repository impl, use case, viewmodel).
18. **Verify** theo skill `flutter-verify`; tự review bằng `flutter-review`.

## Đừng làm
- Đừng gọi `getIt` ngoài `di_providers.dart`; đừng gọi repository từ ViewModel.
- Đừng import `data/` từ `presentation/`; domain không import flutter/dio.
- Đừng `throw` trong datasource/repository; trả `Failure`.
- Đừng đặt mapper trong model, đừng thêm `fromJson` vào entity.
- Đừng tạo thư mục `datasources`/`repository`; đúng là `datasource`, `repositories`.
- Đừng viết `XViewModel` (đúng `XViewmodel`); đừng hardcode text; đừng sửa file generated.
- Đừng thêm package mới, đừng sửa code feature khác (kể cả Country).
