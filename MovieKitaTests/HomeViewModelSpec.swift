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
			
			context("movie list") {
				
				it("should return expected value") {
					
					homeViewModel.requestListMovie(movieFilterType: .Popular)
					
					let exp = self.expectation(description: "Wait the response")
					let waiter = XCTWaiter.wait(for: [exp], timeout: 2.0)
					
					if waiter == XCTWaiter.Result.timedOut {
						expect(homeViewModel.movies.value?.count) >= 0
					} else {
						expect(homeViewModel.movies.value?.count) == 0
					}
				}
			}
			
			context("more movie list") {
				
				it("should return expected value") {
					homeViewModel.requestListMovie(movieFilterType: .Popular) {
						homeViewModel.requestLoadMoreListMovie(movieFilterType: .Popular)
					}
					
					let exp = self.expectation(description: "Wait the response")
					let waiter = XCTWaiter.wait(for: [exp], timeout: 2.0)
					
					if waiter == XCTWaiter.Result.timedOut {
						expect(homeViewModel.movies.value?.count) >= 20
					} else {
						expect(homeViewModel.movies.value?.count) == 0
					}
				}
			}
		}
	}
}
