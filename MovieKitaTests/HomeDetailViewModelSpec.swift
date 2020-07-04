//
//  HomeDetailViewModelSpec.swift
//  MovieKitaTests
//
//  Created by Stevanus Prasetyo Soemadi on 04/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable
import MovieKita

class HomeDetailViewModelSpec: QuickSpec {
	
	override func spec() {
		var homeDetailViewModel: HomeDetailViewModel!
		
		beforeEach {
			homeDetailViewModel = HomeDetailViewModel(movie: Movie.init(id: 2, title: "Title 1", voteAverage: nil, popularity: nil, voteCount: nil, genreIds: nil, video: nil, adult: nil, overview: nil, posterPath: nil, backdropPath: nil, originalLanguage: nil, originalTitle: nil, releaseDate: nil, genres: nil, revenue: nil, runtime: nil, status: nil, tagline: nil, budget: nil))
		}
		
		afterEach {
			homeDetailViewModel = nil
		}
		
		describe("Getting") {
			context("List Review") {
				it("should movies not nil") {
					homeDetailViewModel.requestListMovieReview() {
						expect(homeDetailViewModel.reviews.value?.count) >= 0
					}
				}
			}
		}
	}
}
