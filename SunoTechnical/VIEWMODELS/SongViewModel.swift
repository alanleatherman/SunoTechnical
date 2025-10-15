//
//  SongViewModel.swift
//  SunoTechnical
//
//  Created by Alan Leatherman on 10/15/25.
//

import SwiftUI
import AVFoundation

@Observable
class SongViewModel {
    
    var songs: [SongModel] = []
    var isPlaying: Bool = true
    var currentProgress: Double = 0.0
    var currentSongIndex: Int? = 0
    var currentTime: Double = 0.0
    var totalDuration: Double = 0.0
    
    private var progressTimer: Timer?
    private var audioPlayer: AVPlayer?
    private var timeObserver: Any?
    
    let networkService = NetworkService()
    
    init() {
        setupAudioSession()
    }
    
    func fetchSongs() async {
        guard let url = URL(string: Endpoints.songsEndpoint) else {
            return
        }
        
        do {
            let model: SongsModel = try await networkService.request(.get, url: url, body: nil as String?)
            songs = model.songs
            print(songs)
            
            if let firstSong = songs.first {
                loadAudio(for: firstSong)
            }
        } catch {
            print(error)
        }
    }
    
    func toggleLike(for songId: String) {
        if let index = songs.firstIndex(where: { $0.id == songId }) {
            var updatedSong = songs[index]
            updatedSong.isLiked.toggle()
            
            if updatedSong.isLiked {
                updatedSong.upvoteCount += 1
            } else {
                updatedSong.upvoteCount = max(0, updatedSong.upvoteCount - 1)
            }
            
            songs[index] = updatedSong
            
            print("Like toggled for song: \(songId), new like state: \(updatedSong.isLiked), count: \(updatedSong.upvoteCount)")
        }
    }
    
    func togglePlayPause() {
        isPlaying.toggle()
        
        if isPlaying {
            audioPlayer?.play()
            startProgressTimer()
        } else {
            audioPlayer?.pause()
            stopProgressTimer()
        }
        
        print("Play/Pause toggled: \(isPlaying)")
    }
    
    func resetProgress() {
        currentTime = 0.0
        currentProgress = 0.0
        
        // Load and play the new song
        if let index = currentSongIndex, index < songs.count {
            loadAudio(for: songs[index])
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func loadAudio(for song: SongModel) {
        guard let audioURL = URL(string: song.audioUrl), !song.audioUrl.isEmpty else {
            print("Invalid audio URL for song: \(song.title)")
            totalDuration = 238.0
            startProgressTimer()
            return
        }
        
        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
        }
        
        let playerItem = AVPlayerItem(url: audioURL)
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.handleSongEnd()
        }
        
        timeObserver = audioPlayer?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            
            self.currentTime = time.seconds
            
            if let duration = self.audioPlayer?.currentItem?.duration.seconds,
               duration.isFinite {
                self.totalDuration = duration
                self.currentProgress = self.currentTime / duration
            }
        }
        
        if isPlaying {
            audioPlayer?.play()
        }
        
        print("Loaded audio for: \(song.title)")
    }
    
    private func handleSongEnd() {
        if let currentIndex = currentSongIndex, currentIndex < songs.count - 1 {
            currentSongIndex = currentIndex + 1
            resetProgress()
        } else {
            isPlaying = false
            audioPlayer?.pause()
        }
    }
    
    private func startProgressTimer() {
        guard audioPlayer == nil else { return }
        
        stopProgressTimer()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            self.currentTime += 1.0
            self.currentProgress = self.currentTime / self.totalDuration
            
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
        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }
}
