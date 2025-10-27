# Pokemon iOS App - Development Requirements

## Project Overview

Build an iOS application that displays a list of Pokemon from the PokeAPI with pagination, favorites functionality, and local caching for offline access.

---

## Technical Specifications

### Platform Requirements

| Requirement | Value |
|------------|-------|
| **Platform** | iOS 17+ |
| **Device** | iPhone only |
| **Orientation** | Portrait only |
| **Framework** | SwiftUI |
| **Theme** | Light + Dark mode support |
| **Locale** | English only |
| **Third-Party Libraries** | Any libraries allowed |
| **Architecture** | Any (no constraints) |
| **Development Time** | ~1 hour |
| **Deliverable** | Archived Xcode project |

### API Information

- **API Provider**: PokeAPI
- **Base Endpoint**: `https://pokeapi.co/api/v2/pokemon?limit=10&offset=0`
- **Image Path**: `sprites -> other -> official-artwork -> front_default`

---

## Required Features

### 1. First Screen - Pokemon List

**Description**: Display a scrollable list of Pokemon from the API.

**Requirements**:
- [ ] Fetch data from: `https://pokeapi.co/api/v2/pokemon?limit=10&offset=0`
- [ ] Display for each Pokemon:
  - Pokemon name
  - Pokemon image (from `sprites -> other -> official-artwork -> front_default`)
- [ ] Implement **Pull-to-Refresh** functionality to reload the list
- [ ] Show loading indicators (loaders/spinners) during data fetching
- [ ] Ensure smooth user experience during loading

**API Response Structure**:
```json
{
  "count": 1292,
  "next": "https://pokeapi.co/api/v2/pokemon?offset=10&limit=10",
  "previous": null,
  "results": [
    {
      "name": "bulbasaur",
      "url": "https://pokeapi.co/api/v2/pokemon/1/"
    }
  ]
}
```

---

### 2. Pagination

**Description**: Load more Pokemon dynamically as user scrolls.

**Requirements**:
- [ ] Implement infinite scroll pagination
- [ ] Load additional Pokemon when user scrolls near the bottom
- [ ] Dynamically adjust the `offset` parameter in API calls
- [ ] Load 10 Pokemon per page
- [ ] Maintain smooth scrolling performance

**Example API calls**:
```
Page 1: https://pokeapi.co/api/v2/pokemon?limit=10&offset=0
Page 2: https://pokeapi.co/api/v2/pokemon?limit=10&offset=10
Page 3: https://pokeapi.co/api/v2/pokemon?limit=10&offset=20
```

---

### 3. Detail Screen

**Description**: Show detailed information about a selected Pokemon.

**Requirements**:
- [ ] Navigate to detail screen when user taps a Pokemon
- [ ] Choose presentation style (modal or push navigation)
- [ ] Display the following Pokemon details:
  - Name
  - Image
  - Experience (base_experience)
  - Height
  - Weight
- [ ] Fetch detail data from: `https://pokeapi.co/api/v2/pokemon/{id}`

**Detail API Response Structure**:
```json
{
  "id": 1,
  "name": "bulbasaur",
  "base_experience": 64,
  "height": 7,
  "weight": 69,
  "sprites": {
    "other": {
      "official-artwork": {
        "front_default": "https://..."
      }
    }
  }
}
```

---

### 4. Favorites System

**Description**: Allow users to mark Pokemon as favorites.

**Requirements**:
- [ ] Add a star icon (SF Symbol: `star` / `star.fill`) to each Pokemon cell
- [ ] Tapping the star icon should:
  - Toggle between favorite and non-favorite state
  - Show visual feedback (empty star ↔ filled star)
- [ ] **Persist favorite state** across app restarts
- [ ] Use any storage mechanism (UserDefaults, Core Data, file system, etc.)

**Suggested SF Symbols**:
- Unfavorited: `star`
- Favorited: `star.fill` (yellow color recommended)

---

### 5. Local Caching

**Description**: Cache Pokemon data for offline access and instant loading.

**Requirements**:
- [ ] Cache Pokemon list data locally
- [ ] Cache Pokemon detail data
- [ ] List should load instantly when reopening the app (from cache)
- [ ] Use any preferred caching mechanism:
  - UserDefaults
  - Core Data
  - File system (JSON files)
  - Third-party caching library
- [ ] Update cache when new data is fetched

---

### 6. Segmented Control (All/Favorites)

**Description**: Toggle between viewing all Pokemon and favorites only.

**Requirements**:
- [ ] Add a Segmented Control at the top of the first screen
- [ ] Two segments:
  - **"All"**: Display all Pokemon
  - **"Favorites"**: Display only favorited Pokemon
- [ ] Update the list immediately when switching segments
- [ ] Maintain scroll position when possible

**UI Example**:
```
┌─────────────────────────┐
│   [All] | [Favorites]   │
├─────────────────────────┤
│  Pokemon List           │
└─────────────────────────┘
```

---

### 7. Favorites Management Toolbar

**Description**: Provide option to delete all favorites at once.

**Requirements**:
- [ ] Show toolbar **only when "Favorites" segment is selected**
- [ ] Display a Trash icon (SF Symbol: `trash`)
- [ ] When user taps the Trash icon:
  - [ ] Show a confirmation alert
  - [ ] Alert message: "Are you sure you want to delete all favorites?"
  - [ ] Buttons: "Cancel" and "Delete" (destructive style)
- [ ] If confirmed, clear all favorites and update the UI
- [ ] If no favorites exist, hide the toolbar or disable the button

**Suggested SF Symbol**: `trash` or `trash.fill`

---

### 8. Enhanced UI/UX

**Description**: Provide polished user experience with proper states.

**Requirements**:
- [ ] Show subtle, **non-blocking loading indicator** at the bottom while loading new pages
- [ ] Maintain **smooth scrolling** without blocking the UI
- [ ] Implement **empty state UI** for:
  - [ ] No favorites added yet
    - Show appropriate icon (e.g., `star.slash`)
    - Display message: "No Favorites Yet"
    - Add helpful text: "Tap the star icon to add favorites"
- [ ] Use appropriate animations and transitions
- [ ] Ensure responsive touch targets
- [ ] Add visual feedback for all interactive elements

---

### 9. Error Handling and Offline Mode

**Description**: Handle network failures and support offline usage.

**Requirements**:
- [ ] Display user-friendly error messages for:
  - Network failures
  - API errors
  - Invalid responses
  - Timeout errors
- [ ] Include a **Retry button** for failed requests
- [ ] **Offline Mode Support**:
  - [ ] Detect when device is offline
  - [ ] Automatically load cached data when no internet
  - [ ] Show indicator that app is in offline mode
  - [ ] Display appropriate message if offline and no cached data exists
- [ ] Handle edge cases:
  - [ ] Empty API responses
  - [ ] Malformed data
  - [ ] Missing images

**Error Handling Examples**:
```
❌ Network Error
Unable to connect to server.
[Retry] [Cancel]

📡 Offline Mode
Showing cached data.
Internet connection required for updates.
```

---

## Additional Guidelines

### Creativity and Proactiveness

The following are encouraged but not required:
- Extra UI/UX improvements
- Performance optimizations
- Additional features that enhance user experience
- Animations and transitions
- Accessibility features
- Unit tests
- UI tests

### Code Quality

- Write clean, maintainable code
- Use appropriate naming conventions
- Add comments for complex logic
- Follow Swift best practices
- Handle memory management properly
- Avoid force unwrapping where possible

---

## Deliverables Checklist

- [ ] Complete Xcode project (archived)
- [ ] All 9 required features implemented
- [ ] App works on iOS 17+
- [ ] iPhone only, portrait orientation
- [ ] Light and Dark mode support
- [ ] No crashes or major bugs
- [ ] Smooth performance
- [ ] Data persists across app restarts

---

## Success Criteria

Your app should successfully:

1. ✅ Load and display Pokemon from PokeAPI
2. ✅ Support pagination with smooth infinite scroll
3. ✅ Show Pokemon details on tap
4. ✅ Allow favoriting Pokemon with persistent storage
5. ✅ Switch between All and Favorites views
6. ✅ Provide ability to clear all favorites with confirmation
7. ✅ Cache data for offline access
8. ✅ Handle errors gracefully with retry options
9. ✅ Work in both light and dark mode
10. ✅ Provide smooth, polished user experience

---

## Resources

- **PokeAPI Documentation**: https://pokeapi.co/docs/v2
- **SF Symbols**: Available in Xcode
- **SwiftUI Documentation**: https://developer.apple.com/documentation/swiftui
- **UIKit Documentation**: https://developer.apple.com/documentation/uikit

---

## Timeline

**Estimated Development Time**: ~1 hour

**Suggested Breakdown**:
- Setup & Models: 10 min
- List View & Pagination: 20 min
- Detail View: 10 min
- Favorites System: 10 min
- Caching: 5 min
- UI Polish & Error Handling: 5 min

---

*Good luck with your development! 🚀*
