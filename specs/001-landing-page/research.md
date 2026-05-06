# Research: Landing Page

**Decision**: Use `go_router` for navigation.
**Rationale**: Flutter's recommended declarative routing package. Essential for handling deep links and clean navigation architecture when tapping on features that might require authentication redirects.
**Alternatives considered**: Standard `Navigator 2.0` (too verbose), `auto_route` (relies on code generation, violating bare-minimum principle).

**Decision**: Use standard Flutter Material widgets as "bootstrap" placeholders.
**Rationale**: Avoids adding third-party UI libraries just for placeholders, adhering to Principle I (Bare Minimum Dependencies).
**Alternatives considered**: Importing bootstrap-like UI packages.
