//
//  APIFactory.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 01/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import Moya

protocol APITarget : TargetType {
	var headerParameter: [String: String]? { get }
}

protocol APIFactoryable {
	var path: String { get }
	var method: Moya.Method { get }
	var task: Moya.Task { get }
	var parameter: [String:Any]? { get }
	var headerParameter: [String:String]? { get }
	var sampleData: Data { get }
	var multipartBody: [MultipartFormData]? { get }
}

extension APIFactoryable {
	var headerParameter: [String: String]? {
		return nil
	}
	var parameter: [String:Any]? {
		return nil
	}
	var sampleData: Data {
		return Data()
	}
	var multipartBody: [MultipartFormData]? {
		return nil
	}
}
