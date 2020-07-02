//
//  APIProvider.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 01/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import Alamofire
import Moya

let APIProvider: MoyaProvider<API> = mainProvider()

func mainProvider<T:APITarget>() -> MoyaProvider<T> {
	return MoyaProvider(endpointClosure: endPointProvider)
}

func testProvider<T:APITarget>() -> MoyaProvider<T> {
	return MoyaProvider(stubClosure: MoyaProvider.immediatelyStub)
}

func localProvider<T:APITarget>() -> MoyaProvider<T> {
	return MoyaProvider(
		endpointClosure: endPointProvider,
		stubClosure: MoyaProvider.immediatelyStub
	)
}

//MARK:- endpoint
func endPointProvider<T:APITarget>(target:T) -> Endpoint {
	let url = target.baseURL.appendingPathComponent(target.path).absoluteString
	return Endpoint(
		url: url,
		sampleResponseClosure: {.networkResponse(200, target.sampleData)},
		method: target.method,
		task: target.task,
		httpHeaderFields: target.headers)
}
