//
//  HomePageViewModel.swift
//
//
//  Created by Tolga Polat on 15.07.2023.
//

import Foundation
import Alamofire
import UIKit

struct SearchResponse: Codable {
    let search: [Movie]?
    let totalResults: String?
    let response: String
    let error: String?

    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults = "TotalResults"
        case response = "Response"
        case error = "Error"
    }
}
struct APIError: Decodable, Error {
    let error: String
}

class HomePageViewModel {
    private let apiKey = "8a437353"
    private let baseURL = "https://www.omdbapi.com/"

    var movies: [Movie] = []
    public var totalResults: String = ""
    var errorMessage: String?

    func searchMovies(with query: String, completion: @escaping (Error?) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }

        let urlString = "\(baseURL)?apikey=\(apiKey)&s=\(encodedQuery)&type=movie"
        print("\(baseURL)?apikey=\(apiKey)&s=\(encodedQuery)&type=movie")

        if encodedQuery.count >= 3 {
            AF.request(urlString).responseDecodable(of: SearchResponse.self) { [weak self] response in
                guard let self = self else { return }

                switch response.result {
                case .success(let searchResponse):
                    if let movies = searchResponse.search {
                        self.movies = movies
                        self.errorMessage = nil
                        print("Movies count: \(movies.count)")
                    } else if let error = response.data {
                        let decoder = JSONDecoder()
                        if let apiError = try? decoder.decode(APIError.self, from: error) {
                            self.errorMessage = apiError.error
                            print("Error: \(apiError.error)")
                        }
                        self.movies = []
                    }
                    completion(nil)

                case .failure(let error):
                    completion(error)
                }
            }
        } else {
            self.movies = []
            self.errorMessage = "Arama sorgusu en az 3 karakter içermelidir."
            print("Arama sorgusu en az 3 karakter içermelidir.")
            completion(nil)
        }
    }
}

