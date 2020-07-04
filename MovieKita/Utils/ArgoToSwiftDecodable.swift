//
//  ArgoToSwiftDecodable.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 04/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

// For models that are ALREADY Argo decodable and want to be used inside Swift decodable object
protocol ArgoToSwiftDecodable: Argo.Decodable where Self.DecodedType == Self, Self: Swift.Decodable{}

extension ArgoToSwiftDecodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let json = try container.decode(JSON.self)
		self = try Self.decode(json).dematerialize()
	}
}

extension Argo.JSON: Swift.Decodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let value = try? container.decode(String.self) {
			self = .string(value)
		} else if let value = try? container.decode(Int.self) {
			self = JSON.number(value as NSNumber)
		} else if let value = try? container.decode(Double.self) {
			self = JSON.number(value as NSNumber)
		} else if let value = try? container.decode(Bool.self) {
			self = .bool(value)
		} else if let value = try? container.decode([String: Argo.JSON].self) {
			self = .object(value)
		} else if let value = try? container.decode([Argo.JSON].self) {
			self = .array(value)
		} else if container.decodeNil() {
			self = .null
		} else {
			throw DecodingError.typeMismatch(JSON.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON"))
		}
	}
}
