//
//  SongViewModel.swift
//  SunoTechnical
//
//  Created by Alan Leatherman on 10/15/25.
//

import SwiftUI

@Observable
class SongViewModel {
    
    var songs: [SongModel] = []
    var isPlaying: Bool = true
    var currentProgress: Double = 0.0
    var currentSongIndex: Int? = 0
    var currentTime: Double = 0.0
    var totalDuration: Double = 238.0 // 3:58 in seconds
    var isProgrammaticChange: Bool = false
    
    private var progressTimer: Timer?
    
    let networkService = NetworkService()
    
    func fetchSongs() async {
        guard let url = URL(string: Endpoints.songsEndpoint) else {
            return
        }
        
        do {
            let model: SongsModel = try await networkService.request(.get, url: url, body: nil as String?)
            songs = model.songs
            print(songs)
            startProgressTimer()
        } catch {
            print(error)
        }
    }
    
    func toggleLike(for songId: String) {
        if let index = songs.firstIndex(where: { $0.id == songId }) {
            // Create a copy of the song with toggled like status
            var updatedSong = songs[index]
            updatedSong.isLiked.toggle()
            
            if updatedSong.isLiked {
                updatedSong.upvoteCount += 1
            } else {
                updatedSong.upvoteCount = max(0, updatedSong.upvoteCount - 1)
            }
            
            // Replace the song in the array
            songs[index] = updatedSong
            
            print("Like toggled for song: \(songId), new like state: \(updatedSong.isLiked), count: \(updatedSong.upvoteCount)")
            
            // TODO: Make API call to update like status
            // Task {
            //     await networkService.updateLike(songId: songId, isLiked: updatedSong.isLiked)
            // }
        }
    }
    
    func togglePlayPause() {
        isPlaying.toggle()
        
        if isPlaying {
            startProgressTimer()
        } else {
            stopProgressTimer()
        }
        
        print("Play/Pause toggled: \(isPlaying)")
    }
    
    func resetProgress() {
        currentTime = 0.0
        currentProgress = 0.0
        if isPlaying {
            startProgressTimer()
        }
    }
    
    private func startProgressTimer() {
        stopProgressTimer()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            self.currentTime += 1.0
            self.currentProgress = self.currentTime / self.totalDuration
            
            // Auto advance to next song when current finishes
            if self.currentTime >= self.totalDuration {
                if let currentIndex = self.currentSongIndex, currentIndex < self.songs.count - 1 {
                    self.currentSongIndex = currentIndex + 1
                    self.resetProgress()
                }
            }
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    deinit {
        stopProgressTimer()
    }
}
