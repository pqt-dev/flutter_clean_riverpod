# =========================
# Config
# =========================
REQUIRED_FLUTTER_VERSION := 3.29.1
USE_FVM := true

ifeq ($(USE_FVM),true)
	FLUTTER := fvm flutter
	DART := fvm dart
else
	FLUTTER := flutter
	DART := dart
endif

# =========================
# Utils
# =========================
GREEN := \033[0;32m
BLUE := \033[0;34m
RED := \033[0;31m
NC := \033[0m

# =========================
# Targets
# =========================
.PHONY: all check_version clean pub_get l10n build_runner

all: check_version clean pub_get l10n build_runner
	@echo "$(GREEN)🎉 All tasks completed successfully!$(NC)"

# -------------------------
# Version check
# -------------------------
check_version:
	@echo "$(BLUE)🔍 Checking Flutter version...$(NC)"
	@current_version=`$(FLUTTER) --version | head -n 1 | sed -E 's/.*Flutter ([0-9]+\.[0-9]+\.[0-9]+).*/\1/'`; \
	if [ -z "$$current_version" ]; then \
		echo "$(RED)❌ Cannot detect Flutter version$(NC)"; exit 1; \
	fi; \
	required="$(REQUIRED_FLUTTER_VERSION)"; \
	if [ "$$(printf '%s\n' "$$required" "$$current_version" | sort -V | head -n1)" != "$$required" ]; then \
		echo "$(RED)❌ Flutter $$required is required. You have $$current_version$(NC)"; \
		exit 1; \
	fi; \
	echo "$(GREEN)✔ Correct Flutter version: $$current_version$(NC)"

# -------------------------
# Tasks
# -------------------------
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
