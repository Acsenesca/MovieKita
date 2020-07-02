//
//  Movie.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 02/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct ListMovie {
	let page: Int?
	let totalResults: Int?
	let totalPages: Int?
	let results: [Movie]?
}

extension ListMovie: Argo.Decodable {
	public static func decode(_ json: JSON) -> Decoded<ListMovie> {
		return curry(self.init)
			<^> (json <|? "page") as Decoded<Int?>
			<*> (json <|? "total_results") as Decoded<Int?>
			<*> (json <|? "totalPages") as Decoded<Int?>
			<*> (json <||? "results") as Decoded<[Movie]?>
	}
}

struct Movie {
	let id: Int
	let title: String?
	let voteAverage: Float?
	let popularity: Int?
	let voteCount: Int?
	let genreIds: [Int]?
	let video: Bool?
	let adult: Bool?
	let overview: String?
	let posterPath: String?
	let backdropPath: String?
	let originalLanguage: String?
	let originalTitle: String?
	let releaseDate: String?
}

extension Movie: Argo.Decodable {
	public static func decode(_ json: JSON) -> Decoded<Movie> {
		return curry(self.init)
			<^> (json <| "id") as Decoded<Int>
			<*> (json <|? "title") as Decoded<String?>
			<*> (json <|? "vote_Average") as Decoded<Float?>
			<*> (json <|? "popularity") as Decoded<Int?>
			<*> (json <|? "vote_count") as Decoded<Int?>
			<*> (json <||? "genre_ids") as Decoded<[Int]?>
			<*> (json <|? "video") as Decoded<Bool?>
			<*> (json <|? "adult") as Decoded<Bool?>
			<*> (json <|? "overview") as Decoded<String?>
			<*> (json <|? "poster_path") as Decoded<String?>
			<*> (json <|? "backdrop_path") as Decoded<String?>
			<*> (json <|? "original_language") as Decoded<String?>
			<*> (json <|? "original_title") as Decoded<String?>
			<*> (json <|? "release_date") as Decoded<String?>
	}
}



enum MovieFilterType: String {
	case Popular
	case TopRated
	case NowPlaying
	case Undefined
	
	func description() -> String {
		switch self {
		case .Popular: return "popular"
		case .TopRated: return "top_rated"
		case .NowPlaying: return "now_playing"
		default:
			return "undefined"
		}
	}
}
