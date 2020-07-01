//
//  APIHelper.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 01/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import ReactiveSwift
import Moya

extension SignalProducerProtocol where Value == Response, Error == APIError {
    func filterResponseCode(range:ClosedRange<Int>) -> SignalProducer<Value, Error> {
        return producer.attemptMap({ (response) in
            return response.filterResponseCode(range: range)
        })
    }
}

extension Response {
    func filterResponseCode(range:ClosedRange<Int>) -> Result<Response,APIError> {
        if range.contains(self.statusCode) {
            return .success(self)
        } else {
            return .failure(APIErrorFactory(response:self))
        }
    }
}

extension Swift.Result {
    func value() -> Success? {
        switch self {
        case .success(let success): return success
        case .failure(_): return nil
        }
    }
}
