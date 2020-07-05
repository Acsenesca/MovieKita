//
//  MovieStorageSpec.swift
//  MovieKitaTests
//
//  Created by Stevanus Prasetyo Soemadi on 05/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import Quick
import Nimble
import KeychainSwift

@testable
import MovieKita

typealias MockMovieStorageKey = MovieStorageSpec.MockMovieKey

class MovieStorageSpec: QuickSpec {
	
	enum MockMovieKey: String, CaseIterable {
		case favoriteList = "mock-favorite-list"
	}
	
	override func spec() {
		var movieStorage: MovieStorage!
		var mockMovie: Movie!
		
		beforeEach {
			movieStorage = MovieStorage.shared
			
			mockMovie = Movie(
				id: 1,
				title: "Avenger",
				voteAverage: 9.0,
				popularity: 100.0,
				voteCount: 100,
				genreIds: nil,
				video: true,
				adult: false,
				overview: "Amazing",
				posterPath: nil,
				backdropPath: nil,
				originalLanguage: "en",
				originalTitle: "Avenger: Final",
				releaseDate: "",
				genres: nil,
				revenue: nil,
				runtime: nil,
				status: nil,
				tagline: nil,
				budget: nil)
		}
		
		afterEach {
			movieStorage.removeAll()
			movieStorage = nil
			
			mockMovie = nil
		}
		
		describe("Storage") {
			
			context("saving & loading") {
				
				it("should be have more than one value") {
					movieStorage.keychain = KeychainSwift()
					
					let favoriteListKey = MockMovieKey.favoriteList.rawValue
					
					movieStorage.save(value: [mockMovie], key: favoriteListKey)
					
					let favoriteList = movieStorage.load(key:favoriteListKey)
					
					expect(favoriteList?.count) > 0
				}
				
				it("should be get the correct title") {
					movieStorage.keychain = KeychainSwift()
					
					let favoriteListKey = MockMovieKey.favoriteList.rawValue
					
					movieStorage.save(value: [mockMovie], key: favoriteListKey)
					
					let favoriteList = movieStorage.load(key:favoriteListKey)
					
					expect(favoriteList?.first?.title) == "Avenger"
				}
			}
			
			context("remove") {
				
				it("should be working properly") {
					movieStorage.keychain = KeychainSwift()
					
					let favoriteListKey = MockMovieKey.favoriteList.rawValue
					
					movieStorage.save(value: [mockMovie], key: favoriteListKey)
					movieStorage.remove(key: favoriteListKey)
					
					let favoriteList = movieStorage.load(key:favoriteListKey)
					
					expect(favoriteList?.count) == 0
				}
			}
		}
	}
}
