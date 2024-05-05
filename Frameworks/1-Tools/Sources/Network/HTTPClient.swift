//
//  HTTPClient.swift
//
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation
import Network

public enum NetworkError: Error, Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.badRequest, .badRequest),
            (.unauthorized, .unauthorized),
            (.ServerError, .ServerError):
            return true
        case (.decodingError(let error1), .decodingError(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }

    case badRequest
    case unauthorized
    case ServerError
    case decodingError(Error)
}

public enum HTTPMethod {
    case get([URLQueryItem]?)
    case post(Data)
    case delete
    case patch(Data?)

    var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .delete: return "DELETE"
        case .patch: return "PATCH"
        }
    }
}


public struct Resource<T> {
    let url: URL
    let method: HTTPMethod
    let modelType: T.Type
    let isAuthentified: Bool
    let contentType: String

    public init(endpoint: ApiEndpoint, 
                method: HTTPMethod,
                contentType: String = "application/json",
                modelType: T.Type,
                isAuthentified: Bool = false) {
        self.url = ApiEndpoint.endpointURL(for: endpoint)
        self.method = method
        self.contentType = contentType
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
        self.session = URLSession(configuration: configuration)
    }

    public func load<T: Codable>(_ resource: Resource<T>) async throws -> T {

        var request = URLRequest(url: resource.url)
        request.setValue(resource.contentType, forHTTPHeaderField: "Content-Type")

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

        case .patch(let data):
            request.httpMethod = resource.method.name
            if let data {
                request.httpBody = data
            }
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
