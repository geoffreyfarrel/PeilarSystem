# Data Model: Landing Page

## Entities

### `PromoBanner`
- `id` (String)
- `imageUrl` (String)
- `targetRoute` (String)

### `FeatureItem`
- `id` (String)
- `title` (String)
- `iconData` (IconData or String URL)
- `targetRoute` (String)
- `requiresAuth` (bool)

### `FeatureCategory`
- `id` (String)
- `title` (String)
- `items` (List<FeatureItem>)
