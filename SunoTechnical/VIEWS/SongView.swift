//
//  SongView.swift
//  SunoTechnical
//
//  Created by Alan Leatherman on 10/15/25.
//

import SwiftUI

struct SongView: View {
    
    var viewModel: SongViewModel
    let songIndex: Int
    
    private var song: SongModel {
        guard songIndex < viewModel.songs.count else {
            return SongModel(id: "", title: "", handle: "", displayName: "", imageUrl: "", isLiked: false, upvoteCount: 0, audioUrl: "")
        }
        return viewModel.songs[songIndex]
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            backgroundImage
            gradientOverlay
            
            VStack {
                Spacer()
                songInfoSection
                progressBarSection
                playbackControls
            }
        }
        .contentShape(Rectangle())
        .allowsHitTesting(true)
    }
    
    // MARK: - Background Components
    
    private var backgroundImage: some View {
        Group {
            if let songURL = URL(string: song.imageUrl) {
                AsyncImage(url: songURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: song.id)
                    case .failure:
                        EmptyView()
                    case .empty:
                        EmptyView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.8)],
            startPoint: .center,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Song Info Section
    
    private var songInfoSection: some View {
        HStack(alignment: .bottom) {
            songDetails
            Spacer()
            likeButton
        }
        .padding(.horizontal, 20)
    }
    
    private var songDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(song.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            artistInfo
        }
    }
    
    private var artistInfo: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.orange)
                .frame(width: 20, height: 20)
            
            Text(song.displayName)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }
    
    private var likeButton: some View {
        VStack(spacing: 4) {
            Button {
                print("Like button tapped for song: \(song.id)")
                viewModel.toggleLike(for: song.id)
            } label: {
                Image(systemName: song.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            
            Text("\(song.upvoteCount)")
                .font(.caption)
                .foregroundStyle(.white)
        }
        .animation(.easeInOut(duration: 0.2), value: song.isLiked)
        .animation(.easeInOut(duration: 0.2), value: song.upvoteCount)
    }
    
    // MARK: - Progress Bar Section
    
    private var progressBarSection: some View {
        VStack(spacing: 4) {
            progressBar
            timeLabels
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.3))
                    .frame(height: 3)
                
                Capsule()
                    .fill(.white)
                    .frame(width: geo.size.width * viewModel.currentProgress, height: 3)
            }
        }
        .frame(height: 3)
    }
    
    private var timeLabels: some View {
        HStack {
            Text(formatTime(viewModel.currentTime))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            
            Spacer()
            
            Text(formatTime(viewModel.totalDuration))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    // MARK: - Playback Controls
    
    private var playbackControls: some View {
        HStack(spacing: 30) {
            previousButton
            playPauseButton
            nextButton
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
    }
    
    private var previousButton: some View {
        Button {
            if songIndex > 0 {
                viewModel.currentSongIndex = songIndex - 1
            }
        } label: {
            Image(systemName: "backward.end.fill")
                .font(.title2)
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(songIndex == 0)
        .opacity(songIndex == 0 ? 0.3 : 1.0)
    }
    
    private var playPauseButton: some View {
        Button {
            viewModel.togglePlayPause()
        } label: {
            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
    
    private var nextButton: some View {
        Button {
            if songIndex < viewModel.songs.count - 1 {
                viewModel.currentSongIndex = songIndex + 1
            }
        } label: {
            Image(systemName: "forward.end.fill")
                .font(.title2)
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(songIndex >= viewModel.songs.count - 1)
        .opacity(songIndex >= viewModel.songs.count - 1 ? 0.3 : 1.0)
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    @Previewable @State var previewVM = SongViewModel()
    SongView(
        viewModel: previewVM,
        songIndex: 0
    )
    .task {
        previewVM.songs = [
            SongModel(
                id: "1",
                title: "I Spent 3000 Credits on This Song",
                handle: "nanashi_zero",
                displayName: "🎐Nanashi_Zero",
                imageUrl: "https://cdn1.suno.ai/ffa48fbf-ac87-4a02-8cf2-f3766f518d58_c134aeb8.png",
                isLiked: false,
                upvoteCount: 359,
                audioUrl: ""
            )
        ]
    }
}
