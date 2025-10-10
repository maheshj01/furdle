# NOTE: THESE commands are good during development and QA releases.
# DO NOT USE THIS FOR MAKING A PRODUCTION RELEASE
current_dir := $(shell 'pwd')
# Set the path to your Flutter SDK
FLUTTER := $(shell which flutter)
DART := $(shell which dart)

FLUTTER_VERSION := 3.35.4

start-devtools:
	$(FLUTTER) pub global run devtools

emulator: start-emu

format:
	$(DART) format --line-length 100 .

lint:
	$(FLUTTER) analyze

format-lint: format lint

run:
	$(FLUTTER) run $(if $(RELEASE),--release,)

# make update_version VERSION=0.4.0+14
update_version:
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make update_version VERSION=x.y.z+build"; \
		exit 1; \
	fi
	@echo "Updating version to $(VERSION)..."
	sed -i '' "s/^version: .*/version: $(VERSION)/" pubspec.yaml
	sed -i '' "s|static const String appVersion = '.*';|static const String appVersion = '$(VERSION)';|" lib/constants/const.dart
	@echo "Version updated successfully!"
	@echo "Updated files:"
	@echo "  - pubspec.yaml"
	@echo "  - lib/constants/const.dart"

# make release VERSION=3.36.8+360636
release: $(if $(VERSION),update_version,) release_ios release_android

release_ios:
	$(FLUTTER) build ipa

release_android:
	$(FLUTTER) build appbundle

release_apk:
	$(FLUTTER) build apk \
		$(if $(split),--split-per-abi,)

# Create a release for shorebird
shorebird_release_android:
	shorebird release android --flutter-version=$(FLUTTER_VERSION)

shorebird_release_ios: update_submodules generate
	shorebird release ios \
		--flutter-version=$(FLUTTER_VERSION)

shorebird_release: shorebird_release_android shorebird_release_ios

shorebird_patch_android:
	shorebird patch android

shorebird_patch_ios:
	shorebird patch ios --flutter-version=$(FLUTTER_VERSION)

shorebird_patch: shorebird_patch_android shorebird_patch_ios

generate:

clean: clean_ios clean_android format

clean_ios:
	$(FLUTTER) clean && rm -rf ios/Podfile.lock && rm -rf Pods && $(FLUTTER) pub get && cd ios && pod install && cd ..

clean_android:
	$(FLUTTER) clean && rm -rf android/app/build && $(FLUTTER) pub get && cd android && ./gradlew clean && cd ..
