# homeservice

Flutter application for a home services client experience.

## Project Structure

```text
lib/
  controllers/       Screen/business flow controllers
  core/
    api/             API endpoints and constants
    storage/         Local storage helpers
    utils/           Shared utility helpers
  models/            Data models
  services/          API and persistence services
  views/screens/     UI screens grouped by feature

assets/images/
  auth/              Login, OTP, and password images
  branding/          App logos
  empty_states/      Empty and no-result illustrations
  feedback/          Success and review images
  flags/             Locale flags
  illustrations/     General app illustrations
  onboarding/        Onboarding images
  profile/           Profile/account illustrations
  services/          Service category images
  support/           Support illustrations

```

## Common Commands

```bash
flutter pub get
flutter analyze
flutter run
```
