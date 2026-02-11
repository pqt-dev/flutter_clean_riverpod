USE_FVM := true

ifeq ($(USE_FVM),true)
	FLUTTER := fvm flutter
	DART := fvm dart
else
	FLUTTER := flutter
	DART := dart
endif

GREEN := \033[0;32m
BLUE := \033[0;34m
RED := \033[0;31m
NC := \033[0m

.PHONY: all check_version clean pub_get l10n build_runner rename info

all: check_version clean pub_get l10n build_runner
	@echo "$(GREEN)🎉 All tasks completed successfully!$(NC)"

check_version:
	@echo "$(BLUE)🔍 Checking Dart SDK version from pubspec.yaml...$(NC)"
	@REQUIRED_DART_VERSION=$$(sed -n '/^environment:/,/^[^ ]/p' pubspec.yaml \
		| grep -E 'sdk:' \
		| grep -v 'flutter' \
		| sed -E 's/.*\^?([0-9]+\.[0-9]+\.[0-9]+).*/\1/'); \
	if [ -z "$$REQUIRED_DART_VERSION" ]; then \
		echo "$(RED)❌ Cannot detect Dart SDK version from pubspec.yaml$(NC)"; \
		exit 1; \
	fi; \
	echo "$(GREEN)✔ Required Dart SDK: >= $$REQUIRED_DART_VERSION$(NC)"; \
	CURRENT_DART_VERSION=$$($(FLUTTER) --version \
		| grep 'Dart' \
		| sed -E 's/.*Dart ([0-9]+\.[0-9]+\.[0-9]+).*/\1/'); \
	echo "$(GREEN)✔ Current Dart SDK: $$CURRENT_DART_VERSION$(NC)"; \
	if [ "$$(printf '%s\n' "$$REQUIRED_DART_VERSION" "$$CURRENT_DART_VERSION" | sort -V | head -n1)" != "$$REQUIRED_DART_VERSION" ]; then \
		echo "$(RED)❌ Dart SDK >= $$REQUIRED_DART_VERSION is required$(NC)"; \
		exit 1; \
	fi; \
	echo "$(GREEN)🎉 Dart SDK version check passed$(NC)"

clean:
	@echo "$(BLUE)🚀 flutter clean$(NC)"
	@$(FLUTTER) clean

pub_get:
	@echo "$(BLUE)🚀 flutter pub get$(NC)"
	@$(FLUTTER) pub get

l10n:
	@echo "$(BLUE)🚀 easy_localization generate$(NC)"
	@$(DART) run easy_localization:generate -S assets/translations
	@$(DART) run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart

build_runner:
	@echo "$(BLUE)🚀 build_runner$(NC)"
	@$(DART) run build_runner build -d

rename:
	@echo "$(BLUE)📛 Detecting old project name...$(NC)"
	@OLD_PROJECT_NAME=$$(grep '^name:' pubspec.yaml | awk '{print $$2}'); \
	OLD_ANDROID_APPLICATION_ID=$$(grep -R "applicationId" android/app 2>/dev/null \
    		| sed -E 's/.*applicationId[ ="]+([^"]+).*/\1/' \
    		| head -n 1); \
	OLD_IOS_BUNDLE_ID=$$(grep -R "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj \
    		| sed -E 's/.*= ([^;]+);/\1/' \
    		| head -n 1); \
	if [ -z "$$OLD_PROJECT_NAME" ]; then \
		echo "$(RED)❌ Cannot detect old project name$(NC)"; \
		exit 1; \
	fi; \
	echo "$(GREEN)✔ Old PROJECT name: $$OLD_PROJECT_NAME$(NC)"; \
	echo "$(GREEN)✔ Old PACKAGE name (Android): $$OLD_ANDROID_APPLICATION_ID$(NC)"; \
	echo "$(GREEN)✔ Old BUNDLE ID (iOS): $$OLD_IOS_BUNDLE_ID$(NC)"; \
	\
	if [ -n "$(project_name)" ]; then \
		echo "$(BLUE)✏️ Updating project name → $(project_name)$(NC)"; \
		sed -i '' "s/^name: $$OLD_PROJECT_NAME$$/name: $(project_name)/" pubspec.yaml; \
		grep -rl "package:$$OLD_PROJECT_NAME/" lib test 2>/dev/null \
		| xargs sed -i '' "s/package:$$OLD_PROJECT_NAME\//package:$(project_name)\//g" || true; \
	fi; \
	\
    if [ -n "$(package_name)" ]; then \
    	echo "$(BLUE)📦🍎 Changing package name (Android + iOS) → $(package_name)$(NC)"; \
    	$(DART) run change_app_package_name:main $(package_name); \
    else \
		if [ -n "$(android_package)" ]; then \
			echo "$(BLUE)📦 Changing Android package → $(android_package)$(NC)"; \
			$(DART) run change_app_package_name:main $(android_package) --android; \
		fi; \
			\
		if [ -n "$(ios_bundle)" ]; then \
			echo "$(BLUE)🍎 Changing iOS bundle → $(ios_bundle)$(NC)"; \
			$(DART) run change_app_package_name:main $(ios_bundle) --ios;\
		fi; \
	fi;
	@$(MAKE) info
	@echo "$(GREEN)🎉 Rename completed successfully!$(NC)"

info:
	@echo "$(BLUE)📋 Detecting current project information...$(NC)"
	@PROJECT_NAME=$$(grep '^name:' pubspec.yaml | awk '{print $$2}'); \
	ANDROID_PACKAGE=$$(grep -R "applicationId" android/app 2>/dev/null \
		| sed -E 's/.*applicationId[ ="]+([^"]+).*/\1/' \
		| head -n 1); \
	IOS_BUNDLE=$$(grep -R "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj 2>/dev/null \
		| sed -E 's/.*= ([^;]+);/\1/' \
		| head -n 1); \
	\
	echo "$(GREEN)✔ Project name      : $$PROJECT_NAME$(NC)"; \
	echo "$(GREEN)✔ Android package   : $$ANDROID_PACKAGE$(NC)"; \
	echo "$(GREEN)✔ iOS bundle id     : $$IOS_BUNDLE$(NC)"
