//
//  SongModel.swift
//  SunoTechnical
//
//  Created by Alan Leatherman on 10/15/25.
//

struct SongsModel: Codable {
    let songs: [SongModel]
}

struct SongModel: Codable, Hashable {
    let id: String
    let title: String
    let handle: String
    let displayName: String
    let imageUrl: String
    var isLiked: Bool
    var upvoteCount: Int
    let audioUrl: String
}
