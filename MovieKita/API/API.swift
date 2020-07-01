//
//  API.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 01/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import Moya

//MARK:- API
enum API {
	case Token
	
    func factory() -> APIFactoryable {
        switch self {
        case .Token:
			return APIToken()
		}
    }
}

extension API : APITarget {
    var headers: [String : String]? {
        return factory().headerParameter
    }
    
    public var task: Task {
        return factory().task
    }

    var baseURL: URL {
        guard let url = URL(string: APIUrl) else {
            return URL(string:"")!
        }
        return url
    }
    var path: String {
        return factory().path
    }
    var method: Moya.Method {
        return factory().method
    }
    var parameters: [String: Any]? {
        return factory().parameter
    }
    var headerParameter: [String: String]? {
        return factory().headerParameter
    }
    var sampleData: Data {
        return factory().sampleData
    }
    var multipartBody: [MultipartFormData]? {
        return nil
    }
}


//MARK:- TOKEN
struct APIToken: APIFactoryable {
    var path: String {
        return "/authentication/token/new/"
    }
    
    var method: Moya.Method {
		return .get
    }
    
    var task: Task {
        let parameters = [
			"api_key": APIKey
        ]
		
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
}
