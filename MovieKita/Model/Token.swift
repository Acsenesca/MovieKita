//
//  Token.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 01/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct Token {
    let success: String
    let expiresAt: String
	let requestToken: String
}

extension Token:Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Token> {
        return curry(self.init)
            <^> (json <| "success") as Decoded<String>
            <*> (json <| "expires_at") as Decoded<String>
			<*> (json <| "request_token") as Decoded<String>
	}
}
