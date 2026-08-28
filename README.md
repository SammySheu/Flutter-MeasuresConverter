# Measures Converter — Flutter

A cross-platform Flutter app that converts values between metric and imperial units (distance, weight, volume).

```
Assignment1/
├── measures_converter/          Flutter project
│   ├── lib/main.dart            App source (single file, fully commented)
│   ├── pubspec.yaml             Project manifest
│   └── android/app/src/main/AndroidManifest.xml
├── SETUP.md                     Full environment manual (macOS, deep-dive)
├── REPORT.md                    Assignment report
└── README.md                    You are here
```

---

## Prerequisites

| Tool | macOS | Linux |
|---|---|---|
| Flutter SDK ≥ 3.0 | required | required |
| Xcode 15+ | required (iOS) | **not available** — iOS builds are macOS-only |
| Android Studio | optional (Android) | required (Android) |
| Git | required | required |

Linux users can build & run **Android** and **desktop Linux** targets, but not iOS. That's an Apple restriction, not a Flutter one.

---

## macOS setup

### 1. Install Flutter and native toolchains

```bash
brew install --cask flutter
brew install --cask android-studio     # optional, only for Android runs
sudo gem install cocoapods             # required for iOS

# One-time Xcode configuration
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license                # scroll, then type "agree"
sudo xcodebuild -runFirstLaunch

# Xcode 15+ ships without iOS Simulator runtimes — download separately
xcodebuild -downloadPlatform iOS
```

### 2. Verify

```bash
flutter doctor
```

Expect `[✓]` on Flutter and Xcode. Android will be `[!]` unless you completed the optional Android Studio step (see below).

### 3. Run on the iOS Simulator

```bash
flutter emulators --launch apple_ios_simulator
# wait ~10 seconds for the iPhone window to appear
cd measures_converter
flutter pub get
flutter run
```

If `flutter run` shows multiple devices, type the number of the iPhone.

---

## Linux setup

### 1. Install Flutter

Pick one — snap is simpler, tarball gives more control:

```bash
# Option A — snap (Ubuntu, Fedora, most distros)
sudo snap install flutter --classic

# Option B — manual tarball
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_stable.tar.xz
tar xf flutter_linux_stable.tar.xz -C ~/
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 2. Install Android Studio (required for Android runs)

```bash
sudo snap install android-studio --classic
```

Launch it once, complete the setup wizard (installs Android SDK), then:

- **Tools → Device Manager → Create Device** → pick a Pixel model → download a system image → finish.
- Accept licenses from terminal:
  ```bash
  flutter doctor --android-licenses    # press y at each prompt
  ```

### 3. Enable KVM for emulator hardware acceleration

The Android emulator crawls without it. On Ubuntu/Debian:

```bash
sudo apt install qemu-kvm libvirt-daemon-system
sudo usermod -aG kvm $USER
# log out and back in, then verify:
kvm-ok        # or: ls -l /dev/kvm
```

On Fedora: `sudo dnf install @virtualization`.

### 4. (Optional) Enable Linux desktop target

Flutter can also run the app as a native Linux desktop window:

```bash
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
flutter config --enable-linux-desktop
```

### 5. Verify

```bash
flutter doctor
```

Expect `[✓]` on Flutter and Android toolchain. Xcode will be `[✗]` — that's expected on Linux; ignore it.

### 6. Run on the Android emulator

```bash
# List emulators registered with your Android SDK
flutter emulators

# Boot one (use the id shown by the previous command)
flutter emulators --launch Pixel_10

# Wait ~30 seconds for the phone to finish booting
cd measures_converter
flutter pub get
flutter run
```

### 7. (Alternative) Run as a Linux desktop window

Skip the emulator entirely:

```bash
cd measures_converter
flutter run -d linux
```

---

## Common commands (both platforms)

| Command | What it does |
|---|---|
| `flutter doctor` | Environment health check |
| `flutter devices` | List *booted / connected* devices |
| `flutter emulators` | List *registered but not necessarily running* emulators |
| `flutter emulators --launch <id>` | Boot an emulator |
| `flutter pub get` | Install project dependencies (run inside `measures_converter/`) |
| `flutter run` | Compile & launch the app |
| `flutter run -d <device-id>` | Launch on a specific device |
| `r` (during `flutter run`) | Hot reload — reflect code changes instantly |
| `R` (during `flutter run`) | Hot restart — reset state, keep session |
| `q` (during `flutter run`) | Quit |

`flutter emulators` vs `flutter devices` trips everyone up once: **emulators are registered devices that may or may not be running; `flutter devices` only shows what's currently booted.** Always launch the emulator first.

---

## Using the app

1. Enter a numeric value in the **Value** field.
2. Pick a source unit under **From**.
3. Pick a target unit under **To**.
4. Tap **Convert**.

The result appears under the button, e.g. `100.0 meters are 328.084 feet`.

Supported units:

- **Distance** — meters, feet, miles, kilometers
- **Weight** — kilograms, pounds
- **Volume** — liters, US gallons

Cross-family conversions (e.g. meters → kilograms) are physically undefined and produce a "not supported" message.

---

## Further reading

- [Flutter documentation](https://docs.flutter.dev)
- [Effective Dart style guide](https://dart.dev/effective-dart)
