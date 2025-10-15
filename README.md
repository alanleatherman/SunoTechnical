# SunoTechnical - iOS Interview Assignment

A stripped-down version of Suno's paging music player built with SwiftUI. This app replicates the expanded playback experience from Suno's iOS app, featuring horizontal song browsing with playback controls.

## Assignment Overview

Build a paging music player that displays songs fetched from an API, allowing users to swipe between tracks and interact with like functionality.

### Required Features ✅

- [x] **Fetch and decode songs** from the mock API
- [x] **Display song information** (title, artist handle) overlaid on background images
- [x] **Horizontal paging** - Swipe left/right to navigate between songs
- [x] **Like toggle** - Press the like button to toggle likes on/off with animated state changes

### Bonus Features ✅

- [x] **Simulated playback controls** - Play/pause, previous, and next buttons
- [x] **Progress tracking** - Real-time progress bar with timer (simulated audio playback)
- [x] **Auto-advance** - Automatically moves to next song when current finishes
- [x] **Smooth animations** - Fade-in backgrounds and animated scroll transitions
- [x] **Disabled states** - Previous/next buttons disabled at playlist boundaries

## Features

- **Horizontal Scrolling**: Smooth paging between songs using SwiftUI's native `.scrollTargetBehavior(.paging)`
- **Playback Controls**: Play/pause, next, and previous track buttons with visual feedback
- **Auto-Play**: Songs automatically start with a progress timer tracking playback
- **Like System**: Tap to like/unlike songs with animated thumbs-up icon and real-time vote count updates
- **Progress Bar**: Live progress tracking displaying current time and total duration
- **State Management**: Proper handling of disabled states and edge cases
- **Animations**: Fade-in image loading and smooth scroll transitions between tracks

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with reactive state management:

- **Models**: `SongModel` and `SongsModel` for type-safe data representation
- **Views**: 
  - `ContentView`: Main horizontal scrolling container with ScrollViewReader
  - `SongView`: Individual song display with overlay controls
- **ViewModel**: `SongViewModel` using `@Observable` macro for state management
- **Networking**: Generic `NetworkService` with protocol-based design

### Key Components

#### SongModel
```swift
struct SongModel: Codable, Hashable {
    let id: String
    let title: String
    let handle: String
    let displayName: String
    let imageUrl: String
    var isLiked: Bool          // Mutable for toggle
    var upvoteCount: Int       // Mutable for updates
    let audioUrl: String
}
```

#### SongViewModel
Manages:
- Song collection fetched from API
- Playback state (play/pause/progress)
- Like/unlike functionality with optimistic updates
- Timer-based progress simulation (1-second intervals)
- Auto-advance logic when songs complete
- Current song index tracking

#### NetworkService
Generic networking layer featuring:
- Support for GET, POST, PUT HTTP methods
- Automatic snake_case to camelCase conversion via `JSONDecoder`
- Type-safe requests using Swift's Codable
- Comprehensive error handling with custom `NetworkError` enum
- Request/response validation

## API Integration

### Endpoint
```
https://apitest.suno.com/api/songs
```

### Response Format
```json
{
  "songs": [
    {
      "id": "string",
      "title": "string",
      "handle": "string",
      "display_name": "string",
      "image_url": "string",
      "is_liked": boolean,
      "upvote_count": number,
      "audio_url": "string"
    }
  ]
}
```

### Key Fields Used
- `id` - Song identifier
- `title` - Song title displayed on overlay
- `handle` - Artist handle
- `display_name` - Artist display name shown with icon
- `image_url` - Background image URL for AsyncImage
- `is_liked` - Boolean for like button state
- `upvote_count` - Number of likes displayed
- `audio_url` - Audio file URL (for future playback implementation)

## Usage

- **Swipe left/right** to navigate between songs with smooth paging
- **Tap play/pause button** to control playback simulation
- **Tap previous/next buttons** to jump between adjacent songs (with smooth scroll animation)
- **Tap thumbs up icon** to like/unlike a song (updates immediately with animation)
- Progress bar updates in real-time every second
- Songs auto-advance when progress reaches the end
- Previous button disabled on first song, next button disabled on last song

## Implementation Highlights

### SwiftUI Paging
Used SwiftUI's native paging support as recommended:
```swift
ScrollView(.horizontal) {
    LazyHStack(spacing: 0) {
        // Song views
    }
}
.scrollTargetBehavior(.paging)
.scrollPosition(id: $currentSongIndex)
```

### State Management
- **@Observable Macro**: Modern SwiftUI observation for automatic view updates
- **Computed Properties**: Reactive song data directly from ViewModel array
- **ScrollViewReader**: Programmatic scrolling with smooth animations
- **Optional Bindings**: Proper handling of scroll position state

### Performance Optimizations
- **LazyHStack**: Lazy loading of song views for memory efficiency
- **AsyncImage**: Efficient image loading with automatic caching
- **Timer Management**: Proper cleanup in deinit to prevent memory leaks

## Technical Details

### Challenges Solved
1. **Background Image Sizing** - Used `.scaledToFill()` with explicit frames to prevent layout issues
2. **Like Button Reactivity** - Changed from `let song` to computed property for live updates
3. **Progress Reset Timing** - Used `.onChange` to reset timer when scrolling between songs
4. **Smooth Navigation** - Combined ScrollViewReader with animations for button-triggered scrolling
5. **Edge Cases** - Disabled buttons at playlist boundaries with visual feedback

### Code Quality
- Protocol-oriented networking layer
- Separation of concerns (MVVM)
- Type-safe API with Codable
- Comprehensive error handling
- Clean, organized view components
- Reusable computed properties

## Future Enhancements

- [ ] Actual audio playback using AVPlayer/AVFoundation
- [ ] Backend API integration for persisting likes
- [ ] User authentication and profiles
- [ ] Playlist creation and management
- [ ] Search and filter functionality
- [ ] Share songs to social media
- [ ] Offline mode with local caching
- [ ] Music visualization effects
- [ ] Lyrics display (karaoke mode)
- [ ] Queue management


## Author

Alan Leatherman

---

Built with SwiftUI and ❤️
