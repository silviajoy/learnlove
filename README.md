# Impariamo Reading App (scaffold)

This repository contains a minimal scaffold for the Children Reading App: domain models, Hive adapters, repository interfaces, and a ProfileBloc skeleton.

Next steps:
- Run `flutter pub get` to fetch dependencies
- Implement UI screens and wire BLoCs into widgets

FVM (Flutter Version Manager)
-----------------------------

This project includes a `.fvmrc` pinned to the `stable` channel to help teams use a consistent Flutter SDK.

Install FVM (if not installed):

```bash
dart pub global activate fvm
```

Use FVM to install the configured SDK and run the app:

```bash
cd /Users/silviajoy/Documents/personal/Progettini/ImpariAMO
fvm install
fvm use
fvm flutter pub get
fvm flutter run
```

You can also run commands via `fvm flutter` to ensure the pinned SDK is used.

Notes:
- `.fvmrc` contains the channel or version used by the project. Replace `stable` with a specific version (for example `3.7.12`) if you prefer a fixed SDK.
- The repo commits `.fvmrc` so collaborators will use the same Flutter channel when using FVM.
