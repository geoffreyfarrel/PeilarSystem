<!--
Sync Impact Report:
- Version change: 1.0.0 -> 1.1.0
- Modified principles: N/A
- Added sections: Design & Assets
- Removed sections: None
- Templates requiring updates:
  - .specify/templates/plan-template.md (✅ no update needed)
  - .specify/templates/spec-template.md (✅ no update needed)
  - .specify/templates/tasks-template.md (✅ no update needed)
- Follow-up TODOs: Fill [FIGMA_UI_URL] when design is ready.
-->

# peilar_superapp Constitution

## Core Principles

### I. Bare Minimum Dependencies

Libraries are added only when strictly necessary. Flutter's built-in widgets and utilities are prioritized over third-party solutions to reduce bloat, build times, and maintenance overhead.

### II. Clean Architecture

The application must strictly separate concerns. Use presentation, domain, and data layers to ensure code is testable, maintainable, and decoupled from external frameworks or UI.

### III. Simple State Management

State management should be straightforward and scaled only when necessary. Start with simple solutions like Provider or Riverpod; avoid complex abstractions for simple UI states.

### IV. Test-Driven Core

Core business logic and domain entities must be fully unit-tested. Tests should be written alongside or before feature implementation.

### V. Strict Quality Controls

Code formatting and strict linting rules are enforced. CI/CD pipelines should block merges that violate style guidelines or fail tests.

### VI. Readability and Functional Programming

Code must be readable and maintainable. Favor functional programming patterns where appropriate.

### VII. PWA (Progressive Web App)

Support PWA-specific features for web deployments.

## Design & Assets

**Figma UI Reference**: [FIGMA_UI_URL]
All UI implementations must align with the approved Figma designs when provided. If the placeholder is empty, developers should fallback to standard Material/Cupertino placeholders until the design is finalized.

## Additional Constraints

The project relies on standard Flutter tooling (`flutter pub`, `flutter test`).
Platform support focuses on Android and iOS unless otherwise specified.
No custom frameworks or heavy abstractions without documented justification.

## Development Workflow

1. Discuss and define features in specs before coding.
2. Implement with minimum required dependencies.
3. Add unit tests for domain logic.
4. Pass all lints and format checks before review.

## Governance

This constitution guides all technical decisions for the project. Additions to the dependency list require justification against Principle I.
All PRs/reviews must verify compliance. Complexity must be justified.

**Version**: 1.1.0 | **Ratified**: 2026-05-07 | **Last Amended**: 2026-05-07
