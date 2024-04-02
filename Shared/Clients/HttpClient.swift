//
//  HttpClient.swift
//  mage-ios
//
//  Created by Gagan Suie on 10/9/23.
//

import Foundation

enum NetworkError: Error {
    case badUrl
    case invalidResponse
    case decodingError
    case invalidServerResponse
    case invalidURL
}

enum HttpMethod {
    
    case get([URLQueryItem])
    case post(Data?)
    case put(Data?)
    case patch(Data?)
    case delete
    
    var name: String {
        switch self {
            case .get:
                return "GET"
            case .post:
                return "POST"
            case .put:
                return "PUT"
            case .patch:
                return "PATCH"
            case .delete:
                return "DELETE"
        }
    }
}

struct Resource<T: Codable> {
    let url: URL
    var headers: [String: String] = [:]
    var method: HttpMethod = .get([])
}

class HttpClient {
    
    func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
        
        var request = URLRequest(url: resource.url)
        request.allHTTPHeaderFields = resource.headers
        request.httpMethod = resource.method.name
        
        switch resource.method {
            case .get(let queryItems):
                var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: true)
                components?.queryItems = queryItems
                guard let url = components?.url else {
                    throw NetworkError.badUrl
                }
                request.url = url
            case .post(let data):
                request.httpBody = data
            case .put(let data):
                request.httpBody = data
            case .patch(let data):
                request.httpBody = data
            default:
                    break
        }
        
        let configuration = URLSessionConfiguration.default
        
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json",
                                               "x-api-key": "kzv2i5n40w02hodb1rhne9wduj26z8"] // gbg5qzp3s17zhddy3tv6o9rkovqm2q
        
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(for: request)
        
        let string = String(data: data, encoding: .utf8)!
        print("API RESPONSE: ", string)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201
        else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let result = try JSONDecoder().decode(T.self, from: data)
            return result
        } catch {
            print("Decode Error", error)
            print("Decode Model", T.self)
            throw NetworkError.decodingError
        }
        
    }
    
}
