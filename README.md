# 🦅 Flutter Clean Riverpod Boilerplate

A lightweight, scalable Flutter starter template implementing **Clean Architecture** with **Riverpod** for state management.

## 🎯 Features

- **Architecture**: Clean separation of concerns
- **Riverpod State Management**: Efficient and type-safe state management solution
- **Dark/Light Theme**: Built-in theme support
- **Localization**: Multi-language support
- **Routing**: Declarative routing with go_router

## 📚 Packages & Tools

| Category         | Package                                                                               | Purpose                                                                                                                   |
|------------------|---------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|
| State Management | [flutter_riverpod](https://pub.dev/packages/riverpod)                                 | Reactive state management                                                                                                 |
| Navigation       | [go_router](https://pub.dev/packages/go_router)                                       | Declarative routing                                                                                                       |
| Local storage    | [shared_preferences](https://pub.dev/packages/shared_preferences)                     | Local key-value storage                                                                                                   |
| Network          | [dio](https://pub.dev/packages/dio)                                                   | HTTP client                                                                                                               |
| Localization     | [easy_localization](https://pub.dev/packages/easy_localization)                       | Internationalization                                                                                                      |
| Service locator  | [get_it](https://pub.dev/packages/get_it)                                             | Allows to decouple the interface from a concrete implementation and to access the concrete implementation from everywhere |
| Utilities        |                                                                                       |                                                                                                                           |
|                  | [build_runner](https://pub.dev/packages/build_runner)                                 | A build system for Dart code generation and modular compilation                                                           |
|                  | [freezed](https://pub.dev/packages/freezed)                                           | Code generation for immutable classes                                                                                     |
|                  | [adaptive_dialog](https://pub.dev/packages/adaptive_dialog)                           | Show alert dialog or modal action sheet adaptively according to platform.                                                 |
|                  | [cached_network_image](https://pub.dev/packages/cached_network_image)                 | Load and cache network images                                                                                             |
|                  | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)   | Displaying and scheduling local notifications                                                                             |
|                  | [flutter_gen](https://pub.dev/packages/flutter_gen)                                   | Generator for your assets, fonts, colors,                                                                                 |
|                  | [injectable](https://pub.dev/packages/injectable)                                     | Injectable is a convenient code generator for get_it. Inspired by Angular DI, Guice DI and inject.dart.                   |
|                  | [flutter_spinkit](https://pub.dev/packages/flutter_spinkit)                           | A collection of loading indicators animated with flutter.                                                                 |

## 🏗 Project Structure

```
lib
├── infrastructure/    # Foundational code, shared across the app.
│   ├── constants/     # Global constants (Locale, storage keys, date formats, etc.).
│   ├── di/            # Dependency injection setup using GetIt.
│   └── services/      # Shared utility services (e.g., InternetConnectionService).
│
├── data/
│   ├── datasources/   # Abstract sources for local (DB, SharedPreferences) and remote (API) data.
│   ├── failures/      # Exception Mappers ensuring proper error handling (Exception -> AppError).
│   ├── mappers/       # Mappers to transform Data Models to Domain Entities.
│   ├── models/        # Data Transfer Objects (DTOs) with fromJson/toJson methods.
│   └── repositories/  # Implementation of Domain Repositories.
│
├── domain/
│   ├── core/          # Core Domain Logic (Result type, AppError definitions).
│   ├── entities/      # Pure business objects (Plain Dart Objects).
│   ├── repositories/  # Interfaces (Contracts) for repositories.
│   └── use_cases/     # Application Business Rules (Interactors).
│
├── presentation/
│   ├── features/      # Screens and ViewModels, grouped by feature (e.g., home, search, settings).
│   ├── router/        # GoRouter configuration and route definitions.
│   ├── theme/         # App theme configuration (colors, styles, fonts) and Theme ViewModel.
│   └── dialogs/       # Reusable custom dialogs.
│
└── main.dart          # The entry point of the application.
```



## 🚀 Getting Started

> [!NOTE]
> Prerequisite: This project uses FVM (Flutter Version Manager). Ensure you have FVM installed or remove fvm from the commands below if using a standard Flutter install.

> [!WARNING]
> Warning: Note: The `make` command is primarily tested on macOS and may not work correctly on Linux or Windows.


### 1. Customization

> [!NOTE]
> This project uses [change_app_package_name](https://pub.dev/packages/change_app_package_name) internally to update Android and iOS application identifiers.

#### Rename Flutter project & application package (Recommended)

This project provides a `make rename` command to **rename both**:
- the **Flutter project name** (`pubspec.yaml`)
- the **application package identifiers** (Android & iOS)

in a single step.

Run:

```bash
make rename project_name=new_project_name package_name=com.new.both.name
```

What this command does?

✅ Update project name in pubspec.yaml

✅ Update all Dart imports
(package:old_project_name/... → package:new_project_name/...)

✅ Change Android applicationId

✅ Change iOS bundle identifier

✅ Move Android MainActivity to the correct package directory

#### Clean Old Project Traces (Important)

After renaming the project, you might still find traces of the old project name in cache files or IDE configurations. To completely wipe them out and ensure a clean workspace, run this command:

```bash
make clean_cache
```

> [!NOTE]
> *The `.idea` folder and `.iml` files will automatically be regenerated with the new project name the next time you open the project in your IDE.*

#### OPTIONAL:

**Rename only the project name and update all Dart imports**

```bash
make rename project_name=new_project_name
```

**Rename only the Android package name**

```bash
make rename android_package=com.new.package.name
```

**Rename only the iOS bundle identifier**

```bash
make rename ios_bundle=com.new.bundle.id
```

**Rename Android and iOS using the same package name**

```bash
make rename package_name=com.new.both.name
```

### 2. Setup
You can set up the project in two ways. Using Makefile is recommended for simplicity.

**Option 1: Using Makefile (Recommended)**

This command will clean the project, get dependencies, and run code generation all at once.

- All in one terminal: clean, get packages, generate necessary classes/files:

   ```bash
   make
   ```

- To run a specific task:

    ```bash
    make clean         # Clean project
    make pub_get       # Get dependencies
    make l10n          # Generate localization files
    make build_runner  # Generate Freezed/JsonSerializable files
    ```

**Option 2: Manual Setup**

If you prefer to run commands manually, follow these steps in order:

- Clean the project:

   ```bash
   fvm flutter clean
  ```

- Get dependencies:

   ```bash
   fvm flutter pub get
   ```

- Generate localization files:

   ```bash
   fvm dart run easy_localization:generate -S assets/translations && fvm dart run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart
   ```

- Generate auto-generated files (such as `*.freezed.dart` , `*.g.dart` ...):

   ```bash
   fvm dart run build_runner build -d
   ```
## 🧪 Testing
- Run unit test:

    ```bash
    fvm flutter test
    ```

- Generate Coverage Report (HTML):

    ```bash
    fvm flutter test --coverage && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
    ```

   ---