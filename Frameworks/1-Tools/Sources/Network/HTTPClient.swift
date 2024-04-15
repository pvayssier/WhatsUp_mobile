//
//  HTTPClient.swift
//
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation
import Network

public enum NetworkError: Error {
    case badRequest
    case unauthorized
    case ServerError
    case decodingError(Error)
}

public enum HTTPMethod {
    case get([URLQueryItem]?)
    case post(Data)
    case delete

    var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .delete: return "DELETE"
        }
    }
}


public struct Resource<T> {
    let url: URL
    let method: HTTPMethod
    let modelType: T.Type
    let isAuthentified: Bool

    public init(endpoint: ApiEndpoint, method: HTTPMethod, modelType: T.Type, isAuthentified: Bool = false) {
        self.url = ApiEndpoint.endpointURL(for: endpoint)
        self.method = method
        self.modelType = modelType
        self.isAuthentified = isAuthentified
    }
}

public struct HTTPClient {

    public static let shared = HTTPClient()
    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        // add the default header
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        self.session = URLSession(configuration: configuration)
    }

    public func load<T: Codable>(_ resource: Resource<T>) async throws -> T {

        var request = URLRequest(url: resource.url)

        if resource.isAuthentified, let token = KeychainHelper.retrieveJWT() {
            request.addValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
        } else if resource.isAuthentified {
            throw NetworkError.unauthorized
        }

        switch resource.method {
        case .get(let queryItems):
            var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
            if let queryItems = queryItems {
                components?.queryItems = queryItems
            }
            guard let url = components?.url else {
                throw NetworkError.badRequest
            }

            request.url = url
            request.httpMethod = resource.method.name

        case .post(let data):
            request.httpMethod = resource.method.name
            request.httpBody = data

        case .delete:
            request.httpMethod = resource.method.name
        }

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {

            switch httpResponse.statusCode {
            case 401:
                throw NetworkError.unauthorized
            case 500:
                throw NetworkError.ServerError
            default: break
            }

        }

        do {
            let result = try JSONDecoder().decode(resource.modelType, from: data)
            return result
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
