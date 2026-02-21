# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Logit is a SwiftUI iOS app that helps users manage job application cover letters (자소서). Users record their experiences, and the app uses AI to match experiences to cover letter questions and generate drafts.

## Build & Development

This is an Xcode project — there is no CLI build/test workflow. All builds, tests, and runs must be performed through Xcode.

- **Open project**: `open Logit/Logit.xcodeproj`
- **Run tests**: Use Xcode's Test Navigator (⌘U) — test targets are `LogitTests` and `LogitUITests`
- **Build**: ⌘B in Xcode

The app's `baseURL` and `TEST_ACCESS_TOKEN` are read from `Config.xcconfig` via `Info.plist` → `Config.swift`. During development, `TokenManager` seeds its in-memory access token from `Config.testAccessToken` so API calls work without a real login flow.

## Architecture

**Pattern**: MVVM with a Coordinator pattern for multi-step flows.

### App Lifecycle
- `LogitApp` → injects `AppState` as an `@EnvironmentObject`
- `RootView` switches between `.splash`, `.login`, `.main` phases based on `AppState.appPhase`
- `MainTabView` is the root of the main phase, containing 5 tabs: Home, 자소서(CoverLetter), Add(+), 경험(Experience), 리포트(Report)

### Flow Coordinators
Multi-step modal flows use a Coordinator + ViewModel pattern:
- **`AddFlowCoordinator`** — fullScreenCover for creating a new project (company info → questions → workspace)
- **`ExperienceFlowCoordinator`** — fullScreenCover for adding/editing an experience

Each coordinator owns a `NavigationStack` with a `NavigationPath` managed by its ViewModel. The ViewModel holds a `rootScreen` enum that switches the root view within the stack (e.g., `AddFlowViewModel.RootScreen` flips from `.applicationInfo` to `.workspace` after project creation).

### Network Layer
Located in `Logit/Network/`:

```
Network/
  Core/
    NetworkClient.swift          # Protocol: request<T>(endpoint:body:)
    DefaultNetworkClient.swift   # Implementation with auto token refresh on 401
    APIError.swift               # APIError enum + ErrorResponse decoding
    TokenManager.swift           # Keychain-backed token storage (singleton)
    KeychainManager.swift
    EndPoint/
      EndPoint.swift             # Protocol: path + method
      *Endpoint.swift            # Concrete endpoints per domain
  Models/
    Request/                     # Encodable request structs
    Response/                    # Decodable response structs
  Repository/
    *Repository.swift            # Protocol + Default implementation per domain
```

Repository pattern: each domain (Experience, Project, Question, Chat, User, Report) has a protocol and a `Default*Repository` class that takes a `NetworkClient` in its initializer. ViewModels depend on the protocol, not the concrete class.

**Token refresh**: `DefaultNetworkClient` automatically retries once on 401 using `TokenManager.refreshToken`. A single `refreshTask: Task` prevents duplicate refresh calls.

### Shared UI Utilities (`Resources/Shared/`)

- **Typography**: `LogitFont` enum — use `.typo(.semibold_16)` modifier on any `View`. Font is Pretendard. Font sizes are scaled via `ScreenAdjuster` (base device: iPhone 13 mini, 375×812).
- **Layout helpers** on `View`: `.fillWidth()`, `.fillHeight()`, `.fillScreen()`, `.frame(size:)`, `.cornerRadius(_:corners:)`, `.if(_:transform:)`, `.ifLet(_:transform:)`
- **Gradient**: `.gradientFill(_: GradientStyle)` modifier
- **Debug-only**: `.debugBorder()`, `.debugBackground()` — stripped in Release builds
- **`CompetencyMapper`**: maps experience category enum strings to Korean display names

### Color & Assets
Colors are defined as named colors in `Assets.xcassets`. Common colors: `primary50`, `primary100`, `primary400`, `primary500`, `gray70`, `gray100`, `gray200`, `gray300`, `gray400`.

### Responsive Layout
`ScreenAdjuster` provides `widthRatio`, `heightRatio`, `fontScaleRatio`, `layoutScaleRatio`. Use `.adjusted` (a `CGFloat` extension) to scale values against the 375-pt base width.

## Key Conventions

- All ViewModels are `@MainActor class` conforming to `ObservableObject`.
- API calls use `async/await` with `Task { }` in `.task {}` view modifiers or `.onAppear`.
- Repositories inject `DefaultNetworkClient()` by default, making them easy to override with mocks in tests.
- `AppState` is currently mock-based (uses `MockScenario` enum); real authentication integration is pending.
- When adding a new feature, follow the existing pattern: create a `*Repository` protocol + `Default*Repository`, a `*ViewModel`, and the corresponding View(s).
- Branch naming: `feat/#<issue-number>`, commit prefix: `[feat] #<number>`.
