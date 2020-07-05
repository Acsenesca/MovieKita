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
	
	static let shared = MovieStorage()
	
	init() {
		keychain = KeychainSwift()
	}
}

extension MovieStorage: CacheStorage {
	func save(value: [Movie], key: String) {
		keys.append(key)
		
		if let movies = try? JSONEncoder().encode(value) {
			keychain.set(movies, forKey: key)
		}
	}
	
	func load(key: MovieStorage.Key) -> [Movie]? {
		keychain.synchronizable = true
		let jsonString = keychain.get(key)
		var films: [Movie]? = []
		
		if let jsonStringNew = jsonString {
			let jsonData = Data(jsonStringNew.utf8)
			
			let decoder = JSONDecoder()
			do {
				decoder.keyDecodingStrategy = .convertFromSnakeCase
				let movies = try decoder.decode([Movie].self, from: jsonData)
				
				films = movies
			} catch {
				print(error.localizedDescription)
			}
		}
		
		return films
	}
	
	func remove(key: String) {
		keychain.delete(key)
	}
	
	func removeAll() {
		MovieKey.allCases.forEach { (key: MovieKey) in
			remove(key: key.rawValue)
		}
	}
}
