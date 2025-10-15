//
//  ContentView.swift
//  SunoTechnical
//
//  Created by Alan Leatherman on 10/15/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var vm = SongViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(Array(vm.songs.enumerated()), id: \.offset) { index, song in
                            SongView(viewModel: vm, songIndex: index)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .id(index)
                        }
                    }
                    .frame(height: geometry.size.height)
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $vm.currentSongIndex)
                .onChange(of: vm.currentSongIndex) { oldValue, newValue in
                    if newValue != nil {
                        vm.resetProgress()
                    }
                }
                .task {
                    await vm.fetchSongs()
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
