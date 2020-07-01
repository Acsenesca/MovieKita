//
//  APIError.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 01/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import Moya
import Argo

public enum AuthError: Swift.Error {
	case Error
}
public enum APIError: Swift.Error {
	case notFound(code: Int, message: String, info: [String: AnyObject]?)
	case unauthorize(code: Int, message: String, info: [String: AnyObject]?)
	case unproccessableEntity(code: Int, message: String, info: [String: AnyObject]?)
	case serverError(code: Int, message: String, info: [String: AnyObject]?)
	case decodeError(message: String)
	
	func message() -> String {
		switch self {
		case .notFound(_, let message, _):
			return message
		case .unproccessableEntity(_, let message, _):
			return message
		case .serverError(_, let message, _):
			return message
		case .decodeError(let message):
			return message
		case .unauthorize(_, let message, _):
			return message
		}
	}
	
	func code() -> Int {
		switch self {
		case .notFound(let code, _, _):
			return code
		case .unproccessableEntity(let code, _, _):
			return code
		case .serverError(let code, _, _):
			return code
		case .decodeError(_):
			return 601
		case .unauthorize(let code, _, _):
			return code
		}
	}
	
	func info() -> [String: AnyObject]? {
		switch self {
		case .notFound(_, _, let info):
			return info
		case .unproccessableEntity(_, _, let info):
			return info
		case .serverError(_, _, let info):
			return info
		case .decodeError(_):
			return nil
		case .unauthorize(_, _, let info):
			return info
		}
	}
	
}

public func APIErrorFactory(code: Int, message: String, info: [String: AnyObject]?) -> APIError {
	switch code {
	case 404:
		return APIError.unproccessableEntity(code: code, message: message, info: info)
	case 422:
		return APIError.notFound(code: code, message: message, info: info)
	case 500:
		return APIError.serverError(code: code, message: message, info: info)
	default:
		return APIError.serverError(code: code, message: message, info: info)
	}
}

public func APIErrorFactory(decodeError: DecodeError) -> APIError {
	return APIError.decodeError(message: decodeError.description)
}

public func APIErrorFactory(response: Response) -> APIError {
	if let jsonError = JSONObjectWithData(data: response.data)?["error"] as? [String:Any],
		let code = jsonError["code"] as? Int,
		let message = jsonError["message"] as? String {
		return APIErrorFactory(code: code, message: message,info:nil)
	} else {
		let statusCode = response.statusCode
		return APIErrorFactory(code: statusCode, message:response.description, info:["detail":response])
	}
}
