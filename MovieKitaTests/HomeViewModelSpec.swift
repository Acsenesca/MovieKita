//
//  HomeViewModelSpec.swift
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

class HomeViewModelSpec: QuickSpec {
	
	override func spec() {
		var homeViewModel: HomeViewModel!
		
		beforeEach {
			homeViewModel = HomeViewModel()
		}
		
		afterEach {
			homeViewModel = nil
		}
		
		describe("Getting") {
			context("List Movie") {
//				it("should works properly") {
//					homeViewModel.reloadDataHandler = {_ in
//						expect(homeViewModel.movies.value?.count) >= 0
//					}
//					homeViewModel.requestListMovie(movieFilterType: .Popular)
//				}
//
				it("should works properly 2") {
					homeViewModel.requestListMovie(movieFilterType: .Popular) {
						expect(homeViewModel.movies.value?.count) > 0
					}
				}
			}
		}
	}
}
