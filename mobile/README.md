# Tutta Mobile App

Flutter application for the Tutta rental marketplace.

## Getting Started

### Prerequisites

- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`
- Android Studio or VS Code with Flutter extension

### Setup

```bash
cd mobile
flutter pub get
flutter run
```

### Project Structure

```
mobile/
├── lib/
│   ├── main.dart                   # App entry point
│   ├── app/
│   │   └── app.dart                # Root widget (MaterialApp.router)
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_assets.dart     # Asset path constants
│   │   │   └── app_strings.dart    # String constants
│   │   ├── router/
│   │   │   ├── app_router.dart     # go_router configuration
│   │   │   └── app_routes.dart     # Route path constants
│   │   └── theme/
│   │       ├── app_colors.dart     # Color palette
│   │       ├── app_text_styles.dart# Typography
│   │       └── app_theme.dart      # Light & dark ThemeData
│   ├── features/
│   │   ├── auth/
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           ├── splash_page.dart
│   │   │           ├── login_page.dart
│   │   │           └── register_page.dart
│   │   ├── home/
│   │   │   └── presentation/pages/home_page.dart
│   │   ├── listings/
│   │   │   └── presentation/pages/
│   │   │       ├── listings_search_page.dart
│   │   │       └── listing_detail_page.dart
│   │   ├── booking/
│   │   │   └── presentation/pages/bookings_page.dart
│   │   └── profile/
│   │       └── presentation/pages/profile_page.dart
│   └── shared/
│       └── widgets/
│           ├── main_shell.dart      # Bottom nav shell
│           ├── tutta_button.dart    # Reusable button
│           ├── tutta_text_field.dart# Reusable text field
│           └── state_widgets.dart  # Error/empty state widgets
├── test/
│   └── widget_test.dart
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── pubspec.yaml
└── analysis_options.yaml
```

## Architecture

The project follows a **feature-first** folder structure with clean separation:

- **`core/`** – App-wide infrastructure (theme, router, constants)
- **`features/`** – Feature modules, each containing `data`, `domain`, and `presentation` layers
- **`shared/`** – Reusable widgets and utilities used across features

## Navigation

Navigation uses [go_router](https://pub.dev/packages/go_router) with a `ShellRoute` for the main bottom navigation shell.

Key routes:
| Route | Description |
|-------|-------------|
| `/` | Splash screen |
| `/login` | Login page |
| `/register` | Registration page |
| `/home` | Home feed (shell) |
| `/search` | Listings search (shell) |
| `/bookings` | My bookings (shell) |
| `/profile` | User profile (shell) |
| `/listings/:id` | Listing detail |

## Theme

The app supports both **light** and **dark** themes defined in `lib/core/theme/`:

- `AppColors` – Color palette
- `AppTextStyles` – Inter font typography scale
- `AppTheme` – Material 3 `ThemeData` for light and dark modes

## Running Tests

```bash
flutter test
```
