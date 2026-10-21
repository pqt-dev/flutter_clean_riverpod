# Conventions — bộ rule chuẩn của feature

Tài liệu này là NGUỒN CHUẨN DUY NHẤT về cấu trúc, đặt tên và cách viết code của feature trong repo. Mục tiêu: 1000 feature thì 1000 cái giống hệt nhau, không cái nào khác cái nào. Template, test và skill phải bám theo tài liệu này; khi mâu thuẫn, tài liệu này thắng. Thứ tự ưu tiên: docs/conventions.md > .claude/templates > skills > CLAUDE.md > code mẫu Country/Theme.

## 1. Cách đọc tài liệu này

### 1.1 Mã rule
Mỗi rule có mã duy nhất dạng `<NHÓM>-<nn>` và nằm trên một dòng bắt đầu bằng `- **MÃ** [nhãn]`.

| Nhóm | Phạm vi |
|---|---|
| SCP | Phạm vi áp dụng của tài liệu |
| STP | Ca chưa được phủ, phải dừng và hỏi |
| ARC | Layer và import giữa các layer |
| FIL | File set của một feature, vị trí thư mục |
| NAM | Đặt tên file, class, enum, extension, provider, route, key |
| MET | Tên method và chữ ký theo layer |
| VAR | Tên field, tham số, biến cục bộ |
| IMP | Cách viết import, export, part |
| CLS | Cách khai báo class, annotation |
| API | Datasource gọi API |
| LOC | Feature state cục bộ (lưu local) |
| ERR | Xử lý lỗi, `Result` |
| DI | Dependency injection |
| UI | Screen, widget, state trên UI |
| L10N | Đa ngôn ngữ |
| TST | Test |
| STY | Code style, comment |
| GEN | File generated |

### 1.2 Nhãn cách kiểm
- `[lint]`: analyzer/lint kiểm được (lint nằm trong `flutter_lints` hoặc đã bật thêm trong `analysis_options.yaml`; phần rule mà lint không phủ được ghi chú ngay tại rule). Cổng: `fvm flutter analyze`. Ngoại lệ: STY-01 do cổng CI `Check format` (`dart format --output=none --set-exit-if-changed`) kiểm, không phải analyzer.
- `[test]`: test tự động kiểm được qua tên, vị trí, file set, import (`test/architecture/`). Cổng: `fvm flutter test`.
- `[review]`: cần người hoặc agent review diff.

Nhãn chỉ nói cách kiểm; rule vẫn bắt buộc dù hiện chưa có công cụ kiểm.

Ánh xạ nhóm rule `[test]` sang file thực thi (hàm kiểm tra `checkXxx` nằm ở `test/architecture/checks/`):

| File test | Rule |
|---|---|
| `test/architecture/layer_rules_test.dart` | ARC-01, ARC-02, ARC-03, ARC-04, ARC-05, ARC-08 |
| `test/architecture/feature_structure_test.dart` | FIL-01..FIL-10, TST-01, TST-02, TST-03, NAM-12, NAM-14, L10N-02, L10N-03, GEN-01 |
| `test/architecture/feature_content_test.dart` | NAM-03..NAM-10, MET-01, MET-05, MET-06, IMP-05, CLS-01, CLS-02, CLS-03, CLS-05..CLS-08, DI-01, GEN-02 |

Rule `[lint]` do `fvm flutter analyze` kiểm (lint tương ứng ghi ngay tại rule); rule `[review]` không có công cụ kiểm.

Khi test kiến trúc fail: thông báo vi phạm có mã rule (vd `FIL-05`); phải tra rule đó ở mục 4 và sửa CODE theo rule. Không được sửa hay nới test để qua; chỉ đổi rule khi user duyệt (mục 6).

### 1.3 Từ ngữ và token
- Chỉ dùng "phải" và "không được". Không có ngoại lệ ngầm: ngoại lệ được ghi ngay trong rule.
- Token (cùng bộ với `.claude/templates/README.md`): `{{app_package}}` (tên package trong `pubspec.yaml`), `{{feature}}` (thư mục feature, snake_case, số ít, vd: `country`), `{{Entity}}`/`{{entity}}` (số ít, vd: `Country`/`country`), `{{Entities}}`/`{{entities}}` (số nhiều, vd: `Countries`/`countries`), `{{Nested}}`/`{{nested}}` (entity lồng, vd: `Name`/`name`).
- Feature local: `{{Feature}}` (vd: `Theme`), `{{featureCamel}}` (vd: `theme`), `{{ValueType}}`/`{{value_type}}` (vd: `AppThemeMode`/`app_theme_mode`), `{{storageKey}}`/`{{storage_key}}` (vd: `themeModeKey`/`theme_mode_key`).
- Ví dụ trong rule là dạng rút gọn; không phải toàn bộ code.

### 1.4 Gặp ca chưa được phủ
Nếu yêu cầu rơi vào mục 9 hoặc tài liệu không có rule cho nó thì DỪNG và hỏi user. Không tự chế.

## 2. Giải phẫu một feature

### 2.1 Feature API (như Country): đủ 17 file

| # | Đường dẫn | Class | Vai trò |
|---|---|---|---|
| 1 | `lib/domain/entities/{{entity}}.dart` | `{{Entity}}`, `{{Entity}}{{Nested}}` | Entity chính và entity lồng, cùng một file |
| 2 | `lib/domain/repositories/{{feature}}/{{entity}}_repository.dart` | `{{Entity}}Repository` | Hợp đồng repository (abstract) |
| 3 | `lib/domain/use_cases/{{feature}}/{{entity}}_use_case.dart` | `{{Entity}}UseCase` | Use case, ủy quyền cho repository |
| 4 | `lib/data/models/{{feature}}/{{entity}}_model.dart` | `{{Entity}}Model` | Model JSON của entity chính |
| 5 | `lib/data/models/{{feature}}/{{entity}}_{{nested}}_model.dart` | `{{Entity}}{{Nested}}Model` | Model JSON của mỗi entity lồng (mỗi nested một file) |
| 6 | `lib/data/mappers/{{entity}}_mapper.dart` | `{{Entity}}ModelMapper`, `{{Entity}}{{Nested}}ModelMapper` | Extension `toEntity()`, đặt phẳng |
| 7 | `lib/data/datasource/{{feature}}/{{entity}}_datasource.dart` | `{{Entity}}Datasource` | Hợp đồng datasource (abstract) |
| 8 | `lib/data/datasource/{{feature}}/{{entity}}_datasource_remote.dart` | `{{Entity}}DatasourceRemote` | Gọi API qua `ApiClient` |
| 9 | `lib/data/repositories/{{feature}}/{{entity}}_repository_impl.dart` | `{{Entity}}RepositoryImpl` | Map `Result<Model>` sang `Result<Entity>` |
| 10 | `lib/presentation/features/{{feature}}/{{entity}}_state.dart` | `{{Entity}}State` | State freezed: `data` / `error` |
| 11 | `lib/presentation/features/{{feature}}/{{entity}}_viewmodel.dart` | `{{Entity}}Viewmodel` | Riverpod notifier, gọi use case trong `build()` |
| 12 | `lib/presentation/features/{{feature}}/{{entities}}_screen.dart` | `{{Entities}}Screen` | Màn hình danh sách |
| 13 | `lib/presentation/features/{{feature}}/widget/{{entity}}_item_view.dart` | `{{Entity}}ItemView` | Widget một phần tử danh sách |
| 14 | `test/data/mappers/{{entity}}_mapper_test.dart` | | Test mapper |
| 15 | `test/data/repositories/{{feature}}/{{entity}}_repository_impl_test.dart` | | Test repository impl |
| 16 | `test/domain/use_cases/{{feature}}/{{entity}}_use_case_test.dart` | | Test use case |
| 17 | `test/presentation/features/{{feature}}/{{entity}}_viewmodel_test.dart` | | Test viewmodel |

Sửa vào file dùng chung (không tạo file mới):
- `lib/data/datasource/core/api_endpoint.dart`: thêm `APIEndpoint.all{{Entities}}`.
- `lib/presentation/providers/di_providers.dart`: thêm `{{entity}}UseCaseProvider`.
- `lib/presentation/router/app_routes.dart`: thêm `{{entities}}` và `{{entities}}InHome`.
- `lib/presentation/router/app_router.dart`: thêm `GoRoute` của `{{Entities}}Screen`.
- `assets/translations/{en-US,ja-JP,vi-VN}.json`: chỉ khi feature có text hiển thị mới.

File generated đi kèm (không sửa tay): `{{entity}}.freezed.dart`, `{{entity}}_model.freezed.dart`/`.g.dart`, `{{entity}}_{{nested}}_model.freezed.dart`/`.g.dart`, `{{entity}}_state.freezed.dart`, `{{entity}}_viewmodel.g.dart`, `*_test.mocks.dart`, `injection.config.dart`.

### 2.2 Feature local (như Theme): đủ 8 file

| # | Đường dẫn | Class | Vai trò |
|---|---|---|---|
| 1 | `lib/domain/core/{{value_type}}.dart` | `{{ValueType}}` | Enum giá trị của domain |
| 2 | `lib/domain/repositories/{{feature}}/{{feature}}_repository.dart` | `{{Feature}}Repository` | Hợp đồng repository (abstract) |
| 3 | `lib/domain/use_cases/{{feature}}/{{feature}}_use_case.dart` | `{{Feature}}UseCase` | Use case, ủy quyền cho repository |
| 4 | `lib/data/repositories/{{feature}}/{{feature}}_repository_impl.dart` | `{{Feature}}RepositoryImpl` | Đọc/ghi `SharedPreferences` |
| 5 | `lib/presentation/{{feature}}/{{feature}}_viewmodel.dart` | `{{Feature}}Viewmodel` | Riverpod notifier, đổi qua lại enum domain và kiểu Flutter |
| 6 | `test/data/repositories/{{feature}}/{{feature}}_repository_impl_test.dart` | | Test repository impl |
| 7 | `test/domain/use_cases/{{feature}}/{{feature}}_use_case_test.dart` | | Test use case |
| 8 | `test/presentation/{{feature}}/{{feature}}_viewmodel_test.dart` | | Test viewmodel |

Sửa vào file dùng chung: `lib/infrastructure/constants/storage_keys.dart` (thêm `{{storageKey}}`), `lib/presentation/providers/di_providers.dart` (thêm `{{featureCamel}}UseCaseProvider`), `lib/main.dart` hoặc screen dùng state (gắn `{{featureCamel}}ViewmodelProvider`).

Feature local không có: datasource, model, mapper, entity, state class, screen, route, l10n riêng. Các file `app_theme.dart`, `app_theme_extension.dart` trong `presentation/theme/` là file giao diện, không thuộc file set feature local.

## 3. Bảng tổng hợp quy tắc đặt tên

| Loại | File | Class / tên |
|---|---|---|
| Entity | `domain/entities/{{entity}}.dart` | `{{Entity}}`, lồng: `{{Entity}}{{Nested}}` |
| Repository | `domain/repositories/{{feature}}/{{entity}}_repository.dart` | `{{Entity}}Repository` |
| UseCase | `domain/use_cases/{{feature}}/{{entity}}_use_case.dart` | `{{Entity}}UseCase` |
| Model | `data/models/{{feature}}/{{entity}}_model.dart` | `{{Entity}}Model` |
| Model lồng | `data/models/{{feature}}/{{entity}}_{{nested}}_model.dart` | `{{Entity}}{{Nested}}Model` |
| Mapper | `data/mappers/{{entity}}_mapper.dart` | `{{Entity}}ModelMapper`, `{{Entity}}{{Nested}}ModelMapper` |
| Datasource | `data/datasource/{{feature}}/{{entity}}_datasource.dart` | `{{Entity}}Datasource` |
| Datasource remote | `data/datasource/{{feature}}/{{entity}}_datasource_remote.dart` | `{{Entity}}DatasourceRemote` |
| RepositoryImpl | `data/repositories/{{feature}}/{{entity}}_repository_impl.dart` | `{{Entity}}RepositoryImpl` |
| State | `presentation/features/{{feature}}/{{entity}}_state.dart` | `{{Entity}}State`, `{{Entity}}StateData`, `{{Entity}}StateError` |
| Viewmodel | `presentation/features/{{feature}}/{{entity}}_viewmodel.dart` | `{{Entity}}Viewmodel`; provider `{{entity}}ViewmodelProvider` |
| Screen | `presentation/features/{{feature}}/{{entities}}_screen.dart` | `{{Entities}}Screen` |
| Item view | `presentation/features/{{feature}}/widget/{{entity}}_item_view.dart` | `{{Entity}}ItemView` |
| Provider DI | `presentation/providers/di_providers.dart` | `{{entity}}UseCaseProvider` |
| Endpoint | `data/datasource/core/api_endpoint.dart` | `APIEndpoint.all{{Entities}}` |
| Route | `presentation/router/app_routes.dart` | `AppRoutes.{{entities}}`, `AppRoutes.{{entities}}InHome` |
| Enum local | `domain/core/{{value_type}}.dart` | `{{ValueType}}` |
| Viewmodel local | `presentation/{{feature}}/{{feature}}_viewmodel.dart` | `{{Feature}}Viewmodel`; provider `{{featureCamel}}ViewmodelProvider` |
| Provider DI local | `presentation/providers/di_providers.dart` | `{{featureCamel}}UseCaseProvider` |
| Storage key | `infrastructure/constants/storage_keys.dart` | `StorageKeys.{{storageKey}}` (giá trị `{{storage_key}}`) |
| Test | mirror `lib/`, thêm `_test` | `{{tên_file}}_test.dart`; mock `{{tên_file}}_test.mocks.dart`; class mock `Mock{{Class}}` |

| Loại tên | Mẫu |
|---|---|
| Method lấy danh sách (datasource, repository, use case) | `fetchAll{{Entities}}` |
| Method của feature local (repository, use case) | `fetch`, `save` |
| Method viewmodel local | `set{{Feature}}` |
| Method mapper | `toEntity` |
| Field repository trong use case | `repository` |
| Field datasource trong repository impl | `remoteDatasource` |
| Field `ApiClient` trong datasource remote | `client` |
| Field `SharedPreferences` trong repository impl local | `preferences` |
| Biến use case trong viewmodel | `useCase` |
| Biến kết quả trong viewmodel | `result` |
| Biến state trong screen | `state` |
| Field danh sách trong state | `{{entities}}` |
| Tham số của item view | `data` |

## 4. Rule theo nhóm

### 4.1 SCP — phạm vi

- **SCP-01** [review] Tài liệu này chỉ phủ hai ca: feature lấy danh sách qua API (như Country) và feature state cục bộ lưu local (như Theme). Mọi ca khác phải DỪNG và hỏi user (xem mục 9).

### 4.2 ARC — layer và import giữa layer

- **ARC-01** [test] File trong `lib/domain/` không được import `package:flutter/`, `package:dio/`, `lib/data/` hay `lib/presentation/`. Test: `test/architecture/layer_rules_test.dart`.
- **ARC-02** [test] File trong `lib/presentation/` không được import bất kỳ file nào trong `lib/data/`.
- **ARC-03** [test] File trong `lib/data/` không được import file trong `lib/presentation/` Test: `test/architecture/layer_rules_test.dart`.
- **ARC-04** [test] Trong `lib/presentation/`, chỉ `providers/di_providers.dart` được dùng `getIt`.
- **ARC-05** [test] File `*_viewmodel.dart` không được import file trong `lib/domain/repositories/`; viewmodel chỉ phụ thuộc UseCase.
- **ARC-06** [review] Use case chỉ phụ thuộc repository abstract ở `domain/repositories/`; repository impl chỉ phụ thuộc datasource abstract (`{{Entity}}Datasource`), không phụ thuộc `{{Entity}}DatasourceRemote`.
- **ARC-07** [review] Screen và widget không được gọi use case, repository hay datasource; chỉ viewmodel được gọi use case.
- **ARC-08** [test] Code trong `lib/` không được dùng `print`/`debugPrint`; phải dùng `LoggerService` (`infrastructure/services/logger_service.dart`).
- **ARC-09** [review] Feature code không được gọi `LoggerService`; chỉ `ApiClient` ghi log lỗi.

### 4.3 FIL — file set và vị trí

- **FIL-01** [test] Feature API phải có đủ 17 file của bảng 2.1, không thiếu, không thừa (không kể file generated).
- **FIL-02** [test] Feature local phải có đủ 8 file của bảng 2.2, không thiếu, không thừa.
- **FIL-03** [test] Tên thư mục phải đúng: `datasource` (số ít), `repositories` (số nhiều), `use_cases`, `entities`, `models`, `mappers`, `widget` (số ít, trong feature); thư mục `{{feature}}` luôn số ít. Vd: `data/datasource/country/`, `data/repositories/country/`.
- **FIL-04** [test] Cùng một `{{feature}}` phải dùng đúng tên thư mục đó ở `domain/repositories`, `domain/use_cases`, `data/models`, `data/datasource`, `data/repositories`, `test/` tương ứng.
- **FIL-05** [test] Entity chính và mọi entity lồng của nó phải nằm chung MỘT file `domain/entities/{{entity}}.dart`; không được đặt vào thư mục con theo feature. Vd: `Country`, `CountryName`, `CountryFlag` cùng trong `country.dart`.
- **FIL-06** [test] Model phải mỗi class một file: model chính ở `{{entity}}_model.dart`, mỗi model lồng ở file riêng `{{entity}}_{{nested}}_model.dart`, cùng thư mục `data/models/{{feature}}/`.
- **FIL-07** [test] Mapper phải đặt phẳng ở `data/mappers/{{entity}}_mapper.dart`, không được tạo thư mục con theo feature; mapper của model lồng nằm chung file với mapper của model chính.
- **FIL-08** [test] Feature API đặt presentation ở `presentation/features/{{feature}}/`; feature local đặt ở `presentation/{{feature}}/`. Widget con của feature API phải ở `presentation/features/{{feature}}/widget/`.
- **FIL-09** [test] Enum giá trị của feature local phải ở `domain/core/{{value_type}}.dart`.
- **FIL-10** [test] Hằng endpoint phải ở `data/datasource/core/api_endpoint.dart`, storage key ở `infrastructure/constants/storage_keys.dart`, route ở `presentation/router/app_routes.dart`, provider DI ở `presentation/providers/di_providers.dart`. Không được tạo file mới cho các phần này.
- **FIL-11** [review] Mỗi file trong layer domain/data/presentation của feature chỉ được chứa các class nêu ở bảng 2.1/2.2 cho file đó; không được thêm class phụ vào file khác.
- **FIL-12** [review] Không được tạo file hay thư mục ngoài bảng 2.1/2.2; không được dùng barrel file.

### 4.4 NAM — đặt tên

- **NAM-01** [lint] Tên file phải là `snake_case` (lint `file_names`). Vd: `country_repository_impl.dart`.
- **NAM-02** [lint] Tên class, enum, extension phải là `PascalCase`; tên method, biến, tham số phải là `camelCase`; tên enum value phải là `lowerCamelCase` (lint `camel_case_types`, `camel_case_extensions`, `non_constant_identifier_names`, `constant_identifier_names`, có trong `flutter_lints`).
- **NAM-03** [test] Tên class phải đúng cột "Class" của bảng 2.1/2.2, hậu tố cố định: `Repository`, `RepositoryImpl`, `UseCase`, `Datasource`, `DatasourceRemote`, `Model`, `ModelMapper`, `State`, `Viewmodel`, `Screen`, `ItemView`. Không được đổi hậu tố.
- **NAM-04** [test] Tên entity lồng phải là `{{Entity}}{{Nested}}` (entity), `{{Entity}}{{Nested}}Model` (model), `{{Entity}}{{Nested}}ModelMapper` (extension). Vd: `CountryName`, `CountryNameModel`, `CountryNameModelMapper`.
- **NAM-05** [test] Entity không được có hậu tố (không `Entity`, không `Dto`).
- **NAM-06** [test] Viewmodel phải viết `Viewmodel` (chữ m thường); không được viết `ViewModel`. Provider sinh ra phải là `{{entity}}ViewmodelProvider` (local: `{{featureCamel}}ViewmodelProvider`).
- **NAM-07** [test] Tên file Screen phải dùng số nhiều (`{{entities}}_screen.dart` → `{{Entities}}Screen`); mọi file/class khác của feature API dùng số ít `{{entity}}`.
- **NAM-08** [test] Tên provider DI phải là `{{entity}}UseCaseProvider` (local: `{{featureCamel}}UseCaseProvider`); mỗi use case đúng một provider.
- **NAM-09** [test] Hằng endpoint phải là `APIEndpoint.all{{Entities}}` (class `APIEndpoint`, `API` viết hoa). Vd: `APIEndpoint.allCountries`.
- **NAM-10** [test] Hằng route phải là cặp `AppRoutes.{{entities}} = '/{{entities}}'` và `AppRoutes.{{entities}}InHome = '/home/{{entities}}'`. Vd: `countries`, `countriesInHome`.
- **NAM-11** [review] Tên storage key phải là camelCase kết thúc bằng `Key`, giá trị chuỗi là snake_case của chính tên đó. Vd: `themeModeKey = 'theme_mode_key'`. (Tạm thời v1: chỉ rút từ một ví dụ duy nhất là Theme; cần ví dụ thứ hai để xác nhận.)
- **NAM-12** [test] Tên file test phải là tên file nguồn cộng `_test` (xem TST-01); file mock sinh ra là `{{tên_file}}_test.mocks.dart`; class mock là `Mock{{Class}}`. Vd: `MockCountryDatasource`.
- **NAM-13** [review] Không được đặt tên abstract class bằng tiền tố `I`, `Abstract` hay hậu tố `Interface`/`Base`. Vd: `CountryRepository`, không phải `ICountryRepository`.
- **NAM-14** [test] Tên key l10n phải là `snake_case`, phẳng (không lồng). Vd: `error_retry`.
- **NAM-15** [review] Tên tham số và biến phải là từ đầy đủ; chỉ được viết tắt `e` cho tham số lambda của `map` trong repository impl và `_` cho tham số bị bỏ qua.

### 4.5 MET — tên method và chữ ký

- **MET-01** [test] Method lấy danh sách phải tên `fetchAll{{Entities}}` ở CẢ ba layer: datasource, repository, use case. Vd: `fetchAllCountries`.
- **MET-02** [review] Chữ ký datasource: `Future<Result<List<{{Entity}}Model>>> fetchAll{{Entities}}()`; chữ ký repository và use case: `Future<Result<List<{{Entity}}>>> fetchAll{{Entities}}()`. Không có tham số khi feature chỉ lấy toàn bộ danh sách.
- **MET-03** [review] Thân method của use case phải là đúng một câu lệnh `return repository.fetchAll{{Entities}}();` (method khai báo `async`, không `await`).
- **MET-04** [review] Mọi method trả `Future` ở use case, repository impl, datasource remote phải khai báo `async` và có `@override` khi triển khai abstract.
- **MET-05** [test] Mapper phải có đúng một method `{{Entity}} toEntity()`, không tham số, thân dạng `return {{Entity}}(...)` ánh xạ từng field cùng tên; model lồng được map bằng `field?.toEntity()`.
- **MET-06** [test] `fromJson` chỉ được có ở Model, khai báo `factory {{Entity}}Model.fromJson(Map<String, dynamic> json) => _${{Entity}}ModelFromJson(json);`. Entity không được có `fromJson`/`toJson`.
- **MET-07** [review] `build()` của viewmodel feature API phải có chữ ký `FutureOr<{{Entity}}State> build() async`; viewmodel feature API không được có method public nào khác.
- **MET-08** [review] Chữ ký repository/use case feature local: `Future<{{ValueType}}> fetch()` và `Future<void> save({{ValueType}} {{featureCamel}})`.
- **MET-09** [review] Viewmodel feature local phải có `build()` trả `FutureOr<T>` gọi `useCase.fetch()` và đúng một method ghi `Future<void> set{{Feature}}(T {{featureCamel}})`: chuyển kiểu, `await useCase.save(...)`, rồi gán `state = AsyncData(...)`. Vd: `setTheme(ThemeMode theme)`. (Tạm thời v1: chỉ rút từ một ví dụ duy nhất là Theme; cần ví dụ thứ hai để xác nhận.)
- **MET-10** [review] Hàm đổi kiểu giữa enum domain và kiểu Flutter trong viewmodel local phải là method private tên `_to{{Target}}` dùng `switch` expression không có nhánh mặc định. Vd: `_toThemeMode`, `_toAppThemeMode`. (Tạm thời v1: chỉ rút từ một ví dụ duy nhất là Theme; cần ví dụ thứ hai để xác nhận.)
- **MET-11** [review] Screen phải khai báo `Widget build(BuildContext context, WidgetRef ref)`; item view khai báo `Widget build(BuildContext context)`.
- **MET-12** [review] Constructor của use case, repository impl, datasource remote phải nhận đúng một tham số positional `this.<field>`; không dùng tham số named.
- **MET-13** [review] Trong repository (abstract và impl) và use case của feature local, `fetch` phải khai báo TRƯỚC `save`.

### 4.6 VAR — tên field, tham số, biến

- **VAR-01** [review] Field inject phải đặt theo vai trò: use case có `final {{Entity}}Repository repository;`, repository impl có `final {{Entity}}Datasource remoteDatasource;`, datasource remote có `final ApiClient client;`, repository impl local có `final SharedPreferences preferences;`. Field phải `final`, public, kiểu là abstract (trừ `ApiClient`, `SharedPreferences`).
- **VAR-02** [review] Trong class injectable, field phải khai báo trước constructor; trong widget, constructor phải khai báo trước field.
- **VAR-03** [review] Trong `build()` của viewmodel feature API, biến phải đặt tên `useCase` (`ref.watch({{entity}}UseCaseProvider)`) và `result` (`await useCase.fetchAll{{Entities}}()`). Trong viewmodel local, `useCase` giữ nguyên tên.
- **VAR-04** [review] Field danh sách của state phải tên `{{entities}}`, kiểu `List<{{Entity}}>`, `@Default([])`; variant lỗi nhận một tham số positional `AppError error`.
- **VAR-05** [review] Trong screen, biến phải là `final state = ref.watch({{entity}}ViewmodelProvider);`; destructure danh sách bằng `:final {{entities}}`, lỗi bằng `:final error`.
- **VAR-06** [review] Item view phải có tham số `required this.data` và field `final {{Entity}} data;`.
- **VAR-07** [review] Trong viewmodel phải destructure `Success(:final value)` và `Failure(:final error)`; trong repository impl phải viết `Success(value: final models)` và `Failure(error: final error)`.
- **VAR-08** [review] Mọi field của entity và model phải nullable (`?`), tên trùng khớp JSON key và trùng nhau giữa entity và model. Vd: `String? region`.
- **VAR-09** [review] Literal kích thước kiểu `double` phải viết có `.0` (`24.0`, `8.0`); số nguyên chỉ dùng cho tham số kiểu `int` (`crossAxisCount: 2`).
- **VAR-10** [review] Biến test phải khai báo `late` ở đầu `main()` và gán trong `setUp`: mock datasource `datasource`, subject repository `repository`, mock repository `repository`, subject use case `useCase`, mock use case trong viewmodel test `{{entity}}UseCase` (local: `{{featureCamel}}UseCase`). Container không khai báo `late`: mỗi test viết `final container = createContainer();` (TST-20).

### 4.7 IMP — import, export, part

- **IMP-01** [lint] Mọi import trong `lib/` và `test/` phải ở dạng `package:{{app_package}}/...`, kể cả file cùng thư mục hoặc cùng feature; không được import tương đối (lint `always_use_package_imports`, đã bật trong `analysis_options.yaml`; lint chỉ kiểm file trong `lib/`, import tương đối trong `test/` kiểm khi review). Ngoại lệ: trong `test/`, import file nằm trong `test/` (helper `test/architecture/support`, `test/architecture/checks`, file `*.mocks.dart`) phải dùng đường dẫn tương đối vì `package:` không trỏ được vào `test/`; import file trong `lib/` vẫn phải dùng `package:`. Với file mock sinh ra, viết `import '{{tên_file}}_test.mocks.dart';`.
- **IMP-02** [lint] Thứ tự import: khối `dart:` trước, một dòng trống, rồi MỘT khối `package:` duy nhất (gồm cả package của app) sắp theo thứ tự alphabet của URI, không có dòng trống giữa các package (lint `directives_ordering`, đã bật trong `analysis_options.yaml`; lint không kiểm dòng trống giữa các khối, phần đó kiểm khi review). Trong test, import file mock đứng sau một dòng trống ở cuối.
- **IMP-03** [lint] Không được có import thừa (`unused_import`, cảnh báo mặc định của analyzer) và không được dùng `as`, `show`, `hide` trong import của code do tay viết (lint không kiểm `as`/`show`/`hide`, phần đó kiểm khi review).
- **IMP-04** [review] Không được dùng `export` trong code feature.
- **IMP-05** [test] `part` phải đặt sau khối import, cách một dòng trống, chỉ ghi tên file. Thứ tự: `part '{{tên_file}}.freezed.dart';` rồi `part '{{tên_file}}.g.dart';`.
- **IMP-06** [review] File generated chỉ được import qua `part`, ngoại lệ: `package:{{app_package}}/generated/locale_keys.g.dart` (`LocaleKeys`), `*.mocks.dart` trong test (IMP-01) và `injection.config.dart` trong `injection.dart`.

### 4.8 CLS — khai báo class và annotation

- **CLS-01** [test] Entity phải khai báo `@freezed abstract class {{Entity}} with _${{Entity}}` có `const factory {{Entity}}({ ...fields }) = _{{Entity}};`, chỉ `part '{{entity}}.freezed.dart';`, không `fromJson`. Entity lồng khai báo cùng kiểu trong cùng file.
- **CLS-02** [test] Model phải khai báo `@freezed abstract class {{Entity}}Model with _${{Entity}}Model`, `const factory` gán `= _{{Entity}}Model;`, có hai `part` (`.freezed.dart`, `.g.dart`) và factory `fromJson` (MET-06). Field kiểu entity lồng phải là model lồng tương ứng.
- **CLS-03** [test] State phải khai báo `@freezed sealed class {{Entity}}State with _${{Entity}}State` với đúng hai factory: `const factory {{Entity}}State.data({@Default([]) List<{{Entity}}> {{entities}}}) = {{Entity}}StateData;` và `const factory {{Entity}}State.error(AppError error) = {{Entity}}StateError;`; chỉ `part '..._state.freezed.dart';`.
- **CLS-04** [review] Repository và datasource abstract phải là `abstract class` thuần, không annotation.
- **CLS-05** [test] Datasource remote phải là `@LazySingleton(as: {{Entity}}Datasource) class {{Entity}}DatasourceRemote implements {{Entity}}Datasource`; repository impl phải là `@LazySingleton(as: {{Entity}}Repository) class {{Entity}}RepositoryImpl implements {{Entity}}Repository`. Dùng `implements`, không dùng `extends`.
- **CLS-06** [test] Use case phải là `@lazySingleton class {{Entity}}UseCase` (class thường, không abstract).
- **CLS-07** [test] Viewmodel phải khai báo `@riverpod class {{Entity}}Viewmodel extends _${{Entity}}Viewmodel` (viết liền), `@override build()`, `part '{{entity}}_viewmodel.g.dart';`, import `package:riverpod_annotation/riverpod_annotation.dart`. `@riverpod` không có tham số.
- **CLS-08** [test] Screen phải là `class {{Entities}}Screen extends ConsumerWidget` với `const {{Entities}}Screen({super.key});`. Item view phải là `extends StatelessWidget` với `const {{Entity}}ItemView({super.key, required this.data});`.
- **CLS-09** [review] Mapper phải là `extension {{Entity}}ModelMapper on {{Entity}}Model`; không được đặt `toEntity` trong model hay entity.
- **CLS-10** [review] Enum giá trị local phải là `enum` thuần, chỉ chứa các giá trị, không có member khác.
- **CLS-11** [lint] Constructor phải `const` ở mọi nơi lint yêu cầu (lint `prefer_const_constructors`, đã bật trong `flutter_lints`); `super.key` đứng đầu danh sách tham số; tham số bắt buộc dùng `required` (lint không kiểm `super.key` đứng đầu và `required`, phần đó kiểm khi review).
- **CLS-12** [review] Class feature không được dùng `final class`, `base`, `sealed` ngoài `sealed class` của State; field phải `final`.

### 4.9 API — datasource gọi API

- **API-01** [review] Hằng endpoint phải khai báo trong `APIEndpoint` dạng `static const String all{{Entities}} = '<path tương đối>';`; không được lặp lại base URL ở nơi khác.
- **API-02** [review] Datasource remote phải gọi API chỉ qua `client.request(...)` của `ApiClient`; không được dùng `Dio` trực tiếp.
- **API-03** [review] Thân `fetchAll{{Entities}}` phải là `return client.request(endpoint: APIEndpoint.all{{Entities}}, method: ApiMethod.get, ..., decoder: ...);` theo thứ tự tham số `endpoint`, `method`, `queryParameters` (nếu có), `decoder`.
- **API-04** [review] `decoder` phải đúng dạng `(data) => (data as List<dynamic>).map((element) => {{Entity}}Model.fromJson(element)).toList()`.
- **API-05** [review] Datasource remote không được `try/catch`, không được `throw`, không được bóc `Result`: phải trả thẳng kết quả của `client.request`.
- **API-06** [review] `queryParameters` chỉ được chứa giá trị thật sự dùng; nếu có danh sách `fields` thì mỗi phần tử phải ứng với một field của model. (Lý do: field thừa làm response nặng và gây hiểu nhầm model.)

### 4.10 LOC — feature local

- **LOC-01** [review] Value type của feature local phải là `enum` ở `domain/core/` (FIL-09); lưu bằng `SharedPreferences` dạng string qua `{{featureCamel}}.name`, key lấy từ `StorageKeys.{{storageKey}}`. (Tạm thời v1: chỉ rút từ một ví dụ duy nhất là Theme; cần ví dụ thứ hai để xác nhận.)
- **LOC-02** [review] `fetch()` của repository impl local phải trả về giá trị mặc định cụ thể của enum khi chưa có giá trị lưu hoặc giá trị lưu không hợp lệ. Vd: Theme trả `AppThemeMode.system`. (Tạm thời v1: chỉ rút từ một ví dụ duy nhất là Theme; cần ví dụ thứ hai để xác nhận.)
- **LOC-03** [review] Repository impl local phải nhận `SharedPreferences` qua constructor; không được gọi `SharedPreferences.getInstance()` trong feature. (Tạm thời v1: chỉ rút từ một ví dụ duy nhất là Theme; cần ví dụ thứ hai để xác nhận.)
- **LOC-04** [review] Feature local không được dùng `Result`/`AppError` (xem ERR-08), không có datasource, không có state class: viewmodel trả thẳng giá trị. (Tạm thời v1: chỉ rút từ một ví dụ duy nhất là Theme; cần ví dụ thứ hai để xác nhận.)
- **LOC-05** [review] Nơi dùng state local phải đọc bằng `ref.watch({{featureCamel}}ViewmodelProvider)` (kết quả `AsyncValue`) với giá trị dự phòng khi chưa có dữ liệu. Vd: `themeMode.value ?? ThemeMode.system`. (Tạm thời v1: chỉ rút từ một ví dụ duy nhất là Theme; cần ví dụ thứ hai để xác nhận.)

### 4.11 ERR — xử lý lỗi

- **ERR-01** [review] Lỗi của feature API phải đi qua `Result<T>` (`Success(value)` / `Failure(AppError)`); không được `throw` ra khỏi datasource, repository, use case, viewmodel.
- **ERR-02** [review] Datasource, repository impl, use case, viewmodel không được `try/catch`; `ApiClient.request` đã bắt exception qua `ExceptionMapper`.
- **ERR-03** [review] `AppError` chỉ có 5 loại: `NetworkError`, `ServerError`, `AuthError`, `ParsingError`, `UnexpectedError`. Không được thêm loại mới trong feature.
- **ERR-04** [review] Repository impl phải đổi `Result<List<Model>>` sang `Result<List<Entity>>` bằng `switch` expression đầy đủ hai nhánh: `Success` map `models.map((e) => e.toEntity()).toList()`, `Failure` chuyển tiếp nguyên `error`.
- **ERR-05** [review] Viewmodel phải dùng `switch` statement trên `Result`: `case Success(:final value): return {{Entity}}State.data({{entities}}: value);` và `case Failure(:final error): return {{Entity}}State.error(error);`. Viewmodel không được trả `AsyncError` chủ động.
- **ERR-06** [review] Text lỗi hiển thị cho user phải lấy từ `error.localizedMessage` (extension `AppErrorL10n`); không được hiển thị `error.toString()` hay `AppError.message`.
- **ERR-07** [review] Khi thêm loại `AppError` (nếu được user cho phép) phải thêm nhánh vào `AppErrorL10n` và key trong cả 3 file l10n.
- **ERR-08** [review] Feature local trả giá trị trực tiếp, không dùng `Result`.

### 4.12 DI — dependency injection

- **DI-01** [test] Use case phải có `@lazySingleton`; datasource remote và repository impl phải có `@LazySingleton(as: <abstract>)`. Class feature không được dùng `@singleton` hay `@injectable`.
- **DI-02** [review] Mỗi use case phải có đúng một provider trong `di_providers.dart`, thân dạng khối: `final {{entity}}UseCaseProvider = Provider<{{Entity}}UseCase>((ref) { return getIt<{{Entity}}UseCase>(); });`.
- **DI-03** [review] Không được tạo provider cho repository hay datasource.
- **DI-04** [review] Viewmodel phải lấy use case bằng `ref.watch({{entity}}UseCaseProvider)`, không dùng `ref.read`, không dùng `getIt`.
- **DI-05** [review] Dependency phải được inject qua constructor với kiểu abstract (trừ `ApiClient`, `SharedPreferences`).
- **DI-06** [review] Test viewmodel phải thay use case bằng mock qua `{{entity}}UseCaseProvider.overrideWithValue(mock)` trong `ProviderContainer(overrides: [...])`; không được gọi `getIt` trong test.

### 4.13 UI — screen, widget, state

- **UI-01** [review] Screen phải có khung: `final state = ref.watch({{entity}}ViewmodelProvider); return Scaffold(body: SafeArea(child: switch (state) { ... }));`.
- **UI-02** [review] `switch (state)` phải có đúng 4 nhánh theo thứ tự: (1) `AsyncLoading<{{Entity}}State>() => AppLoader()`; (2) `AsyncData<{{Entity}}State>(value: {{Entity}}StateData(:final {{entities}})) =>` nội dung danh sách; (3) `AsyncData<{{Entity}}State>(value: {{Entity}}StateError(:final error)) => ErrorView(message: error.localizedMessage, onRetry: () => ref.invalidate({{entity}}ViewmodelProvider))`; (4) `AsyncError<{{Entity}}State>(:final error) => ErrorView(message: error is AppError ? error.localizedMessage : LocaleKeys.error_unexpected.tr(), onRetry: ...)`.
- **UI-03** [review] Retry phải là `ref.invalidate({{entity}}ViewmodelProvider)`; screen không được dùng `ref.read` hay gọi method của viewmodel.
- **UI-04** [review] Danh sách phải dựng bằng constructor `.builder` với `itemBuilder: (context, index) => {{Entity}}ItemView(data: {{entities}}[index])` và `itemCount: {{entities}}.length`.
- **UI-05** [review] Item view phải là `StatelessWidget` nhận đúng một entity, không đọc provider, không dùng `ref`.
- **UI-06** [review] Phải dùng widget dùng chung ở `presentation/features/widgets/` thay vì tự dựng lại: `AppLoader` (loading), `ErrorView` (lỗi), `AppText` (text), `AppButton` (nút), `AppTextField` (nhập liệu), `AppBarView` (app bar).
- **UI-07** [review] UI phải dùng tên đầy đủ của enum/constructor có tên, không dùng dot shorthand. Vd: `EdgeInsets.symmetric(horizontal: 24.0)`, `TextAlign.center`, `MainAxisAlignment.center`, `FontWeight.w600`; không viết `.symmetric(...)`, `.center`. (Không có lint hay test kiểm rule này; chỉ kiểm khi review.)
- **UI-08** [review] Màu trong feature UI phải lấy từ theme (`Theme.of(context)` hoặc `context.color(Palette.x)`); không được viết `Colors.x` hay `Color(0x...)` trong feature.
- **UI-09** [review] Text hiển thị cho user phải qua `AppText(text: ...)` (hoặc widget dùng chung); khi dữ liệu null thì giá trị dự phòng của text hiển thị phải đúng chuỗi `'--'` (dùng `??`). Vd: `data.name?.common ?? '--'`. (Lý do: một ký hiệu "không có dữ liệu" duy nhất cho mọi màn hình; `'--'` là ký hiệu, không phải câu chữ, do đó không qua l10n.)
- **UI-10** [review] Điều hướng tới màn hình phải dùng `context.push(AppRoutes.{{entities}}InHome)`; không được viết chuỗi path trực tiếp.
- **UI-11** [review] Route của screen phải là `GoRoute(path: AppRoutes.{{entities}}, builder: (context, state) => {{Entities}}Screen())` đặt trong `routes` của `GoRoute(path: AppRoutes.home, ...)`.
- **UI-12** [review] Lề ngang nội dung và khoảng cách giữa các phần tử lưới/lề lớn phải là `24.0`. Vd: `EdgeInsets.symmetric(horizontal: 24.0)`, `mainAxisSpacing: 24.0`.
- **UI-13** [review] Khi chưa có đặc tả cho thao tác chạm vào item thì item view không được khai báo `onTap` rỗng hay `InkWell` trống; thao tác chạm thuộc mục 9.

### 4.14 L10N — đa ngôn ngữ

- **L10N-01** [review] Mọi văn bản hiển thị cho user phải qua `LocaleKeys.<key>.tr()` (import `package:easy_localization/easy_localization.dart` và `package:{{app_package}}/generated/locale_keys.g.dart`), kể cả title nút, hint, tooltip. Không được hardcode chuỗi hiển thị.
- **L10N-02** [test] Key mới phải thêm vào CẢ 3 file `assets/translations/en-US.json`, `ja-JP.json`, `vi-VN.json` với cùng tên key; sau đó chạy `make l10n`.
- **L10N-03** [test] `.tr()` và `LocaleKeys` chỉ được dùng trong `lib/presentation/`.
- **L10N-04** [review] Chuỗi kỹ thuật không hiển thị (log, key, route path, JSON key, storage key) không được qua l10n. Giá trị dự phòng `'--'` (UI-09) không qua l10n.

### 4.15 TST — test

- **TST-01** [test] `test/` phải mirror ĐÚNG đường dẫn `lib/`: thay `lib/` bằng `test/`, thêm hậu tố `_test.dart`. Vd: `lib/presentation/features/country/country_viewmodel.dart` → `test/presentation/features/country/country_viewmodel_test.dart`; `lib/presentation/theme/theme_viewmodel.dart` → `test/presentation/theme/theme_viewmodel_test.dart`.
- **TST-02** [test] Feature API phải có đủ 4 file test (mapper, repository impl, use case, viewmodel); feature local phải có đủ 3 (repository impl, use case, viewmodel). Không có file test cho datasource remote, screen, item view, state trong phạm vi hiện tại.
- **TST-03** [test] Mỗi file test phải có `void main()`; test cần mock phải khai báo `@GenerateNiceMocks([MockSpec<T>()])` ngay trên `void main()` và `import '{{tên_file}}_test.mocks.dart';`.
- **TST-04** [review] Chỉ mock phụ thuộc trực tiếp: test repository impl mock `{{Entity}}Datasource`; test use case mock `{{Entity}}Repository`; test viewmodel mock `{{Entity}}UseCase`; test mapper không mock.
- **TST-05** [review] Biến `late` phải ở đầu `main()` (VAR-10); mock và subject phải được tạo trong `setUp(() { ... })`.
- **TST-06** [review] Test trả `Result` phải gọi `provideDummy<Result<T>>(value)` trước `when(...)`, với `T` đúng kiểu trả về của method được mock.
- **TST-07** [review] Stub phải viết `when(mock.method()).thenAnswer((_) async => value)`; trong test repository impl và test use case, test thành công đầu tiên của mỗi method phải có `verify(mock.method()).called(1)`.
- **TST-08** [review] Mỗi test phải chia ba khối arrange / act / assert, cách nhau một dòng trống.
- **TST-09** [review] Test repository impl phải có `group('fetchAll{{Entities}}', ...)` (một group cho mỗi method, tên group là tên method); test mapper phải có một `group` cho mỗi extension, tên group là tên extension (`'{{Entity}}ModelMapper'`).
- **TST-10** [review] Tên test case phải bằng tiếng Anh, bắt đầu chữ thường. Test mapper bắt đầu bằng `toEntity()`; các test nhánh kết quả của repository impl (TST-12) bắt đầu bằng `returns Success ...` hoặc `returns Failure with {{ErrorType}} ...`.
- **TST-11** [review] Test mapper feature API phải gồm tối thiểu: map đủ field, field null, model lồng một phần; mỗi mapper lồng có test map đủ và test null.
- **TST-12** [review] Test repository impl feature API phải gồm tối thiểu: Success có map entity, Success danh sách rỗng, Failure `NetworkError`, Failure `ServerError(statusCode: 500)`.
- **TST-13** [review] Test use case feature API phải gồm tối thiểu: Success và Failure (`NetworkError`), mỗi test có `verify(...).called(1)`.
- **TST-14** [review] Test viewmodel feature API phải gồm tối thiểu: state `{{Entity}}StateData` khi use case thành công, state `{{Entity}}StateError` khi use case thất bại (`same(error)`).
- **TST-15** [review] Test viewmodel phải tạo container qua helper `createContainer()` (TST-20) dùng `ProviderContainer(overrides: [...])` (DI-06), gọi `addTearDown(container.dispose)`, và đọc bằng `container.read({{entity}}ViewmodelProvider.future)`.
- **TST-16** [review] Assertion phải dùng matcher chuẩn: `equals` cho giá trị, `isA<T>()` cho kiểu, `isNull`, `isEmpty`, `hasLength`, `contains`.
- **TST-17** [review] Test repository impl local phải dùng `SharedPreferences.setMockInitialValues({...})` rồi `await SharedPreferences.getInstance()`, và viết key dạng chuỗi literal (không import `StorageKeys`).
- **TST-18** [review] Test không được gọi mạng thật và không được dùng `getIt`.
- **TST-19** [review] Test use case phải có một `group` cho mỗi method của use case, tên group là tên method (vd: `group('fetch', ...)`, `group('save', ...)`; feature API: `group('fetchAll{{Entities}}', ...)`); mọi test case của method đó phải nằm trong group.
- **TST-20** [review] Test viewmodel phải khai báo trong `main()`, sau `setUp`, helper `ProviderContainer createContainer()` với thân `return ProviderContainer(overrides: [{{entity}}UseCaseProvider.overrideWithValue(mock)]);` (local: `{{featureCamel}}UseCaseProvider`). Mỗi test case phải viết `final container = createContainer();` rồi ngay sau đó `addTearDown(container.dispose);`.
- **TST-21** [review] Test case của viewmodel phải nằm trong `group` theo hành vi: `group('build (initial fetch)', ...)` cho `build()` và một `group` có tên là tên method public cho mỗi method của viewmodel (vd: `group('setTheme', ...)`). Test case của `build()` đặt tên dạng `returns <giá trị state> when use case returns <giá trị use case>`, đọc kết quả bằng `container.read(...future)` rồi `expect(result, equals(...))`; test đầu tiên của group `build (initial fetch)` có thêm `verify(<mock>.fetch()).called(1)`. Test case của method ghi đặt tên dạng `saves <giá trị> and updates state`, gọi method qua `container.read(...notifier)`, dùng `verify(<mock>.save(...)).called(1)` cho lời gọi use case và kiểm state bằng `expect(<state>.value, equals(...))`.

### 4.16 STY — style và comment

- **STY-01** [lint] Code phải giữ nguyên đầu ra của `fvm dart format` với `trailing_commas: preserve` (cấu hình trong `analysis_options.yaml`); không được định dạng tay khác formatter. Kiểm bằng cổng CI `Check format` (không phải analyzer): `files=$(git ls-files 'lib/*.dart' 'test/*.dart'); [ -z "$files" ] || dart format --output=none --set-exit-if-changed $files`. Chỉ kiểm file `.dart` đã track, không kiểm file generated. Lệnh kiểm PHẢI có `--output=none`, thiếu thì `dart format` GHI ĐÈ file. Hook `.claude/hooks/format-dart.sh` tự format file `.dart` agent vừa sửa.
- **STY-02** [lint] Mọi file trong `lib/` và `test/` (gồm `infrastructure/constants`) phải dùng dấu nháy đơn `'`, không có ngoại lệ (lint `prefer_single_quotes`, đã bật trong `analysis_options.yaml`).
- **STY-03** [review] Method trong domain, data, presentation của feature phải dùng thân khối `{ return ...; }`; chỉ callback/lambda được dùng `=>`.
- **STY-04** [review] Không được viết comment `//` trong code feature (domain, data, presentation) đã commit. Đo thực tế: trong `lib/` không có comment `//` nào ngoài `// TODO`.
- **STY-05** [review] Doc comment `///` trong code feature chỉ được có ở: abstract datasource (2 dòng: `/// Abstract interface for {{entity}} data source.` và `/// Enables swapping between remote and local implementations.`), enum giá trị local (1-2 dòng nêu mục đích), và đầu `di_providers.dart`. Các class còn lại (repository, use case, viewmodel, screen, widget) không có doc comment.
- **STY-06** [review] Comment (nếu có, ở test hoặc doc comment cho phép ở STY-05) phải bằng tiếng Anh.
- **STY-07** [review] Không được để `// TODO` trong code feature đã commit; việc chưa làm phải ghi ở task, hoặc hỏi user nếu thuộc mục 9.
- **STY-08** [lint] Không được khai báo field, tham số, biến, import không dùng (`unused_field`, `unused_element`, `unused_local_variable`, `unused_import`).
- **STY-09** [review] Không được thêm package mới khi chưa hỏi user.
- **STY-10** [lint] `fvm flutter analyze` phải sạch trước khi hoàn thành.
- **STY-11** [review] Danh sách và argument nhiều dòng phải kết thúc bằng dấu phẩy cuối.

### 4.17 GEN — file generated

- **GEN-01** [test] Không được sửa tay `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`, `*.mocks.dart`; các file này đã được gitignore và không được commit.
- **GEN-02** [test] `part` phải khớp annotation: `@freezed` cần `.freezed.dart`; `@freezed` có `fromJson` cần thêm `.g.dart`; `@riverpod` cần `.g.dart`.
- **GEN-03** [review] Sau khi đổi model, state, viewmodel, annotation injectable hoặc `@GenerateNiceMocks` phải chạy `make build_runner`; sau khi đổi file l10n phải chạy `make l10n`.
- **GEN-04** [review] Asset và màu phải lấy qua flutter_gen (`assets.gen.dart`, `colors.gen.dart`), không viết đường dẫn asset hay mã màu trực tiếp.

## 5. Ánh xạ nhanh quyết định thiết kế sang rule

| Quyết định | Rule |
|---|---|
| Phạm vi v1 chỉ list-fetch API và local state | SCP-01 |
| Import `package:`, thứ tự import | IMP-01, IMP-02 |
| Method `fetchAll{{Entities}}` xuyên 3 layer, `APIEndpoint.all{{Entities}}` | MET-01, NAM-09 |
| Entity chung một file, Model mỗi class một file | FIL-05, FIL-06 |
| Tên field inject theo vai trò | VAR-01 |
| `test/` mirror đúng đường dẫn `lib/` | TST-01 |
| Không dot shorthand | UI-07 |
| Không TODO, text qua l10n, fallback `'--'`, không field thừa | STY-07, L10N-01, UI-09, STY-08, API-06 |
| Mapper đặt phẳng | FIL-07, CLS-09, MET-05 |
| Mọi file `lib/` và `test/` dùng nháy đơn, không ngoại lệ | STY-02 |
| Cấu trúc test use case và viewmodel theo mẫu Theme (group, `createContainer()`) | TST-19, TST-20, TST-21, TST-15, VAR-10 |
| Thứ tự method feature local: `fetch` trước `save` | MET-13 |
| Rule rút từ một ví dụ duy nhất (Theme) đánh dấu tạm thời v1 | NAM-11, MET-09, MET-10, LOC-01..LOC-05 |
| Code lệch rule thì sửa code; đổi rule chỉ khi user duyệt | Mục 6 |

## 6. Nơi code hiện tại lệch rule

Code mẫu Country/Theme được căn chỉnh theo tài liệu này. Khi phát hiện code lệch rule, phải sửa code theo rule; chỉ được đổi rule khi user duyệt.

## 7. Bảo trì tài liệu

- Rule mới phải có mã duy nhất, một nhãn `[lint]`/`[test]`/`[review]`, và chỉ dùng "phải"/"không được".
- Khi đổi rule phải cập nhật template, test, skill liên quan trong cùng thay đổi.

## 8. Thứ tự áp dụng khi có mâu thuẫn

docs/conventions.md > .claude/templates > skills > CLAUDE.md > code mẫu Country/Theme.

## 9. Chưa được phủ — DỪNG và hỏi

- **STP-01** [review] Gặp bất kỳ ca nào dưới đây thì phải DỪNG và hỏi user; không được tự chế cấu trúc, tên hay luồng xử lý.

Các ca chưa được phủ (Country/Theme không minh họa):
- Màn hình chi tiết (detail), điều hướng từ item sang màn hình khác, truyền tham số route.
- Create, update, delete; method HTTP khác `GET` (POST, PUT, PATCH, DELETE); request có body.
- Phân trang, load more, pull to refresh, tìm kiếm, lọc, sắp xếp.
- Form, validation, `AppTextField` có `validator`, state nhập liệu.
- Query params hoặc path params do UI truyền xuống (hiện `fetchAll{{Entities}}` không có tham số).
- Auth: token, header xác thực, refresh token, phân quyền, xử lý `AuthError` bằng điều hướng.
- Caching, offline, lưu danh sách xuống local.
- Nhiều datasource trong một feature (local + remote), datasource local.
- Nhiều viewmodel hoặc nhiều screen trong một feature; viewmodel có tham số (family).
- State loại khác (state có nhiều field, `loading`/`empty` tường minh, state phi sealed).
- Value type local không phải enum, lưu local không dùng `SharedPreferences` hay không phải string.
- Entity có JSON key khác tên field (snake_case JSON, `@JsonKey`, converter), response không phải `List`, response lồng object.
- API trả danh sách rỗng cần màn hình trạng thái rỗng (empty state).
- Key l10n riêng của feature (tiền tố, đặt tên) và text mới trên UI.
- Màn hình không thuộc feature API/local (home, search, favourite, setting, main_home).
- Widget dùng chung mới, extension helper mới, đặt tên file và class extension.
- Đặt tên hằng số hạ tầng mới ngoài `StorageKeys`.
- Thêm loại `AppError`, thêm service hạ tầng, thay đổi `ApiClient`.
- Test cho datasource remote, screen, item view; test tích hợp.
- Sắp xếp thứ tự method trong abstract repository, use case, impl khi feature có nhiều method.
- Giá trị dự phòng cho dữ liệu null không phải text hiển thị (vd: URL ảnh).
