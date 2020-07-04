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
	case Favourite
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
		case .Favourite: return "Favourite"
		default:
			return "undefined"
		}
	}

}

struct ListMovie: Encodable {
	let page: Int?
	let totalResults: Int?
	let totalPages: Int?
	let results: [Movie]?
	
	enum PropertyKey: String, CodingKey {
		case page
		case totalResults
		case totalPages
		case results
	}
	
	func encode(to encoder: Encoder) throws {
		
		var container = encoder.container(keyedBy: PropertyKey.self)
		
		try container.encode(page, forKey: .page)
		try container.encode(totalResults, forKey: .totalResults)
		try container.encode(totalPages, forKey: .totalPages)
		try container.encode(results, forKey: .results)
	}
}

extension ListMovie: Swift.Decodable {}

extension ListMovie: ArgoToSwiftDecodable {
	public static func decode(_ json: JSON) -> Decoded<ListMovie> {
		return curry(self.init)
			<^> (json <|? "page") as Decoded<Int?>
			<*> (json <|? "total_results") as Decoded<Int?>
			<*> (json <|? "totalPages") as Decoded<Int?>
			<*> (json <||? "results") as Decoded<[Movie]?>
	}
}

struct Movie: Encodable {
	
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
	let genres: [Genre]?
	let revenue: Float?
	let runtime: Int?
	let status: String?
	let tagline: String?
	let budget: Int?
	
	enum PropertyKey: String, CodingKey {
		case id = "id"
		case title = "title"
		case voteAverage = "vote_average"
		case popularity = "popularity"
		case voteCount = "vote_count"
		case genreIds = "genre_ids"
		case video = "video"
		case adult = "adult"
		case overview = "overview"
		case posterPath = "poster_path"
		case backdropPath = "backdrop_path"
		case originalLanguage = "original_anguage"
		case originalTitle = "original_title"
		case releaseDate = "release_date"
		case genres = "genres"
		case revenue = "revenue"
		case runtime = "runtime"
		case status = "status"
		case tagline = "tagline"
		case budget = "budget"
	}
	
	func encode(to encoder: Encoder) throws {
		
		var container = encoder.container(keyedBy: PropertyKey.self)
		
		try container.encode(id, forKey: .id)
		try container.encode(title, forKey: .title)
		try container.encode(voteAverage, forKey: .voteAverage)
		try container.encode(popularity, forKey: .popularity)
		try container.encode(voteCount, forKey: .voteCount)
		try container.encode(genreIds, forKey: .genreIds)
		try container.encode(video, forKey: .video)
		try container.encode(adult, forKey: .adult)
		try container.encode(overview, forKey: .overview)
		try container.encode(posterPath, forKey: .posterPath)
		try container.encode(backdropPath, forKey: .backdropPath)
		try container.encode(originalLanguage, forKey: .originalLanguage)
		try container.encode(originalTitle, forKey: .originalTitle)
		try container.encode(releaseDate, forKey: .releaseDate)
		try container.encode(genres, forKey: .genres)
		try container.encode(revenue, forKey: .revenue)
		try container.encode(runtime, forKey: .runtime)
		try container.encode(status, forKey: .status)
		try container.encode(tagline, forKey: .tagline)
		try container.encode(budget, forKey: .budget)
	}
}

extension Movie: Swift.Decodable {}

extension Movie: ArgoToSwiftDecodable {
	public static func decode(_ json: JSON) -> Decoded<Movie> {
		let m = curry(Movie.init)
			<^> (json <| "id") as Decoded<Int>
			<*> (json <|? "title") as Decoded<String?>
			<*> (json <|? "vote_average") as Decoded<Float?>
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
		
		let m2 = m <*> (json <||? "genres") as Decoded<[Genre]?>
			<*> (json <|? "revenue") as Decoded<Float?>
			<*> (json <|? "runtime") as Decoded<Int?>
			<*> (json <|? "status") as Decoded<String?>
			<*> (json <|? "tagline") as Decoded<String?>
			<*> (json <|? "budget") as Decoded<Int?>

		return m2
	}
}

struct Genre: Encodable {
	let id: Int
	let name: String?
	
	enum PropertyKey: String, CodingKey {
		case id
		case name
	}
	
	func encode(to encoder: Encoder) throws {
		
		var container = encoder.container(keyedBy: PropertyKey.self)
		
		try container.encode(id, forKey: .id)
		try container.encodeIfPresent(name, forKey: .name)
	}
}

extension Genre: Swift.Decodable {}

extension Genre: ArgoToSwiftDecodable {
	public static func decode(_ json: JSON) -> Decoded<Genre> {
		return curry(Genre.init)
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
