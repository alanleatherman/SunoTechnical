//
//  NetworkService.swift
//  SunoTechnical
//
//  Created by Alan Leatherman on 10/15/25.
//


import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingFailed(Error)
    case requestFailed(Error)
    case encodingFailed(Error)
    case jsonParsingFailed
}

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from url: URL) async throws -> T
    func fetchData(from url: URL) async throws -> Data
    func fetchJSON(from url: URL) async throws -> [String: Any]
    
    // HTTPMethod support
    func request<T: Decodable>(_ method: HTTPMethod, url: URL, body: Encodable?) async throws -> T
    func requestData(_ method: HTTPMethod, url: URL, body: Encodable?) async throws -> Data
    func requestJSON(_ method: HTTPMethod, url: URL, body: Encodable?) async throws -> [String: Any]
}

struct Endpoints {
    static let songsEndpoint = "https://apitest.suno.com/api/songs"
}


class NetworkService: NetworkServiceProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30 // Or from APIConfiguration
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    // MARK: GET Conveniences (URL-based, no body)
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        return try await request(.get, url: url)
    }
    
    func fetchData(from url: URL) async throws -> Data {
        return try await requestData(.get, url: url)
    }
    
    func fetchJSON(from url: URL) async throws -> [String: Any] {
        return try await requestJSON(.get, url: url)
    }
    
    // MARK: Requests
    /// Example (POST): let user: User = try await service.request(.post, url: url, body: CreateUserRequest(name: "Alan"))
    /// Example (PUT): let updated: User = try await service.request(.put, url: url, body: UpdateUserRequest(name: "NewName"))
    /// Example (GET): let user: User = try await service.request(.get, url: url)  // Or use convenience
    func request<T: Decodable>(_ method: HTTPMethod, url: URL, body: Encodable? = nil) async throws -> T {
        let request = try buildRequest(method, url: url, body: body)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
   func requestData(_ method: HTTPMethod, url: URL, body: Encodable? = nil) async throws -> Data {
        let request = try buildRequest(method, url: url, body: body)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        
        return data
    }
    
    func requestJSON(_ method: HTTPMethod, url: URL, body: Encodable? = nil) async throws -> [String: Any] {
        let data = try await requestData(method, url: url, body: body)
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return json
            } else {
                throw NetworkError.jsonParsingFailed
            }
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    // MARK: Helpers
    
    private func buildRequest(_ method: HTTPMethod, url: URL, body: Encodable?) throws -> URLRequest {
        guard url.scheme == "https" || url.scheme == "http" else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingFailed(error)
            }
        }
        
        return request
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: -1)
        }
        
        print("HTTP Status Code: \(httpResponse.statusCode) for \(httpResponse.url?.absoluteString ?? "unknown")")
        
        if !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
    
}
