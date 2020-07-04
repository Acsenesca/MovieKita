//
//  CacheStorage.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 04/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation

protocol CacheStorage {
	associatedtype Key
	associatedtype Value
	
	func cache(value: Value, key: Key)
	
	func value(key: Key) -> Value?
	
	func removeValue(key: Key)
	
	func removeAllValues()
}

