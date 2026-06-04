# Peilar Superapp Development Guide

## Language & Localization

### Bilingual Support Rule
All displayed text in the app **must be bilingual** with support for **English (en)** and **Chinese (zh)**.

- **Central language file**: `lib/features/landing/presentation/providers/language_provider.dart`
- **Language enum**: `AppLanguage` with two values:
  - `AppLanguage.zh` - Chinese (Traditional)
  - `AppLanguage.en` - English
- **Default language**: Chinese (`AppLanguage.zh`)
- **String provider**: Use `appTextProvider` to access localized strings based on current language

### Adding New Strings
When adding new user-facing text:

1. Add the key-value pair to **both** `AppLanguage.zh` and `AppLanguage.en` maps in `appText` const
2. Maintain alphabetical order and logical grouping within each language section
3. Never hardcode strings in components—always reference the `appTextProvider`
4. Test both language variants before submitting

### Accessing Strings in Components
```dart
// In widgets, watch the language provider:
final texts = ref.watch(appTextProvider);
Text(texts['your_key_here']!)

// Or directly access the current language:
final language = ref.watch(languageProvider);
```

### Example: Adding a New Feature String
```dart
// In appText map:
AppLanguage.zh: {
  // ... existing entries ...
  'newFeature': '新功能名稱',
},
AppLanguage.en: {
  // ... existing entries ...
  'newFeature': 'New Feature Name',
},
```

## Color Palette (REQUIRED)

All UI components across the entire project **must** use only the following colors:

| Role | Hex |
|------|-----|
| Primary | `#0079BF` |
| Secondary | `#C6006E` |
| Accent 1 | `#EDA944` |
| Accent 2 | `#0E9A33` |
| Neutral | `#F7F7F7` |

- Never introduce colors outside this palette without explicit approval
- Use the Primary color (`#0079BF`) for main actions, headers, and interactive elements
- Use the Secondary color (`#C6006E`) for highlights, badges, and secondary actions
- Use Accent colors (`#EDA944`, `#0E9A33`) sparingly for status indicators or decorative elements
- Use the Neutral color (`#F7F7F7`) for backgrounds and surface areas

## Development Workflow

### Testing & Linting
Before committing any changes:
- **Always run tests** to ensure code correctness
- **Always run linting** to maintain code quality and style consistency
- Both tests and linting must pass before commits are created

### Commit Message Standards
- **Commit messages are determined by Claude** based on the changes made
- Follow conventional commit format: `<type>: <description>`
  - `feat:` - New feature
  - `fix:` - Bug fix
  - `refactor:` - Code refactoring without feature/bug changes
  - `docs:` - Documentation updates
  - `style:` - Code style changes (formatting, etc.)
  - `test:` - Test additions or updates
  - `chore:` - Build process, dependencies, or tooling changes
- Keep descriptions concise and imperative (e.g., "add QR scanner" not "added QR scanner")
- Include relevant context or issue references when applicable

## Project Structure

- **Frontend**: Flutter (Dart)
- **State Management**: Riverpod
- **Features**: Landing page, Student Authentication, Travel AI, Washing Machine, Bebe support
