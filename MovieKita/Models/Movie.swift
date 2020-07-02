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
	
	func rawValue() -> String {
		switch self {
		case .Popular: return "Popular"
		case .TopRated: return "Top Rated"
		case .NowPlaying: return "Now Playing"
		default:
			return "undefined"
		}
	}

}

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
	let popularity: Float?
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
	let genres: [Movie.Genre]?
	let revenue: Float?
	let runtime: Int?
	let status: String?
	let tagline: String?
	let budget: Int?
	
	struct Genre {
		let id: Int
		let name: String?
	}
}

extension Movie: Argo.Decodable {
	public static func decode(_ json: JSON) -> Decoded<Movie> {
		let m = curry(Movie.init)
			<^> (json <| "id") as Decoded<Int>
			<*> (json <|? "title") as Decoded<String?>
			<*> (json <|? "vote_Average") as Decoded<Float?>
			<*> (json <|? "popularity") as Decoded<Float?>
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
		
		let m2 = m <*> (json <||? "genres") as Decoded<[Movie.Genre]?>
			<*> (json <|? "revenue") as Decoded<Float?>
			<*> (json <|? "runtime") as Decoded<Int?>
			<*> (json <|? "status") as Decoded<String?>
			<*> (json <|? "tagline") as Decoded<String?>
			<*> (json <|? "budget") as Decoded<Int?>

		return m2
	}
}

extension Movie.Genre: Argo.Decodable {
	public static func decode(_ json: JSON) -> Decoded<Movie.Genre> {
		return curry(Movie.Genre.init)
			<^> (json <| "id") as Decoded<Int>
			<*> (json <|? "name") as Decoded<String?>
	}
}

struct ListReview {
	let page: Int?
	let totalResults: Int?
	let totalPages: Int?
	let results: [Review]?
}

extension ListReview: Argo.Decodable {
	public static func decode(_ json: JSON) -> Decoded<ListReview> {
		return curry(self.init)
			<^> (json <|? "page") as Decoded<Int?>
			<*> (json <|? "total_results") as Decoded<Int?>
			<*> (json <|? "totalPages") as Decoded<Int?>
			<*> (json <||? "results") as Decoded<[Review]?>
	}
}

struct Review {
	let id: String
	let author: String?
	let content: String?
	let url: String?
}

extension Review: Argo.Decodable {
	public static func decode(_ json: JSON) -> Decoded<Review> {
		return curry(self.init)
			<^> (json <| "id") as Decoded<String>
			<*> (json <|? "author") as Decoded<String?>
			<*> (json <|? "content") as Decoded<String?>
			<*> (json <|? "url") as Decoded<String?>
	}
}
