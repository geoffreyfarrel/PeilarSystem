---
description: "Task list for Landing Page feature implementation"
---

# Tasks: Landing Page

**Input**: Design documents from `specs/001-landing-page/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create core routing configuration in `lib/core/routing/app_router.dart`
- [ ] T002 [P] Create base theme configuration in `lib/core/theme/app_theme.dart`
- [ ] T003 Create directory structure for landing feature in `lib/features/landing/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Create `FeatureItem` entity in `lib/features/landing/domain/entities/feature_item.dart`
- [ ] T005 [P] Create `PromoBanner` entity in `lib/features/landing/domain/entities/promo_banner.dart`
- [ ] T006 Create `MockLandingRepository` in `lib/features/landing/data/repositories/mock_landing_repository.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Navigating the Landing Page (Priority: P1) 🎯 MVP

**Goal**: View a well-structured landing page to easily discover and access all available features.

**Independent Test**: Can be fully tested by launching the app and verifying the presence and correct positioning of the carousel, feature grids, categories, and bottom navigation bar.

### Tests for User Story 1

- [ ] T007 [P] [US1] Create widget test for landing page in `test/features/landing/presentation/landing_page_test.dart`

### Implementation for User Story 1

- [ ] T008 [P] [US1] Implement `PromoCarousel` widget in `lib/features/landing/presentation/widgets/promo_carousel.dart`
- [ ] T009 [P] [US1] Implement `TopFeaturesGrid` widget in `lib/features/landing/presentation/widgets/top_features_grid.dart`
- [ ] T010 [P] [US1] Implement `FeatureCategoryList` widget in `lib/features/landing/presentation/widgets/feature_category_list.dart`
- [ ] T011 [P] [US1] Implement `BottomNavBar` widget in `lib/features/landing/presentation/widgets/bottom_nav_bar.dart`
- [ ] T012 [US1] Assemble `LandingPage` in `lib/features/landing/presentation/pages/landing_page.dart` using all widgets
- [ ] T013 [US1] Integrate `LandingPage` with routing in `lib/core/routing/app_router.dart`
- [ ] T014 [US1] Add auth prompt mock logic in `LandingPage` for restricted features (e.g., onTap triggers dialog)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently.

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T015 [P] Verify accessibility tap targets on all interactive elements in UI widgets
- [ ] T016 Run all tests and verify layout on different simulated screen sizes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3)**: Depends on Foundational phase completion
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel (Theme config).
- All Foundational tasks marked [P] can run in parallel (Entities).
- All UI widget tasks (T008, T009, T010, T011) in User Story 1 can be built entirely in parallel.

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks story)
3. Complete Phase 3: User Story 1 (Build all widgets, then assemble)
4. **STOP and VALIDATE**: Test User Story 1 independently by running the app.
