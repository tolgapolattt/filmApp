//
//  HomePageModel.swift
//
//
//  Created by Tolga Polat on 15.07.2023.
//

struct Movie: Codable {
    let title: String
    let year: String
    let imdbID: String
    let poster: String
    let actors: String!
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case poster = "Poster"
        case actors = "Actors"
    }
}

