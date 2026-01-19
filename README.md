# Liveonce

SwiftUI + SwiftData MVP for the “Death Calendar + Life Budget” app.

## Project Structure
- `LiveonceApp/`: SwiftUI app target source.
- `LiveonceWidget/`: WidgetKit extension source.
- `Shared/`: App + widget shared models (WidgetSummary).

## App Group Setup
1. In Xcode, add an App Group capability to both the app target and widget target.
2. Use the same identifier as defined in `Shared/WidgetSummary.swift`:
   - `group.com.song.liveonce`
3. Ensure both targets share this App Group so the widget can read the summary data.

## MVP Features
- Death Calendar (week/year grids + KPI header).
- Life budget weekly planning (minutes per bucket).
- Execution logging with weekly summary.
- Daily scoring with history list.
- Widget showing remaining weeks, progress %, and weekly adherence.

## Notes
- The widget summary updates after saving budgets, logs, or scores.
- Default seed data is created on first launch.
