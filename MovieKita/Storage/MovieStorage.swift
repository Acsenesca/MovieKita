//
//  MovieStorage.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 04/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import KeychainSwift

typealias MovieStorageKey = MovieStorage.MovieKey

class MovieStorage {
	
	typealias Key = String
	typealias Value = [Movie]
	
	enum MovieKey: String, CaseIterable {
		case favoriteList = "favorite-list"
	}
	
	var keychain: KeychainSwift
	var keys: [String] = []
	
	init() {
		keychain = KeychainSwift()
	}
}

extension MovieStorage: CacheStorage {
	func cache(value: [Movie], key: String) {
		keys.append(key)
		
		if let movies = try? JSONEncoder().encode(value) {
			keychain.set(movies, forKey: key)
		}
	}
	
	func value(key: MovieStorage.Key) -> [Movie]? {
		guard let data = keychain.getData(key, asReference: true) else {
			return nil
		}
		
		let movies = try? JSONDecoder().decode([Movie].self, from: data)
		
		return movies
	}
	
	func removeValue(key: String) {
		keychain.delete(key)
	}
	
	func removeAllValues() {
		MovieKey.allCases.forEach { (key: MovieKey) in
			
		}
	}
}
