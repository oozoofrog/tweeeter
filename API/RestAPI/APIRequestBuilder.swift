//
//  APIBuilder.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

public enum Method: String {
    case get, post
    var method: String { return self.rawValue.uppercased() }
}

public enum API: String {
    case api = "https://api.twitter.com"
    case stream = "https://stream.twitter.com"
}

public enum APIRequestError: Error, Equatable {
    case statusError(Int)
    case needAuthentication
    case invalidatePath
    case decodeFailed(reason: String)
    case unknown
}

public typealias ResultHandle<Result> = (Result?, APIRequestError?) -> Void
public protocol APIRequestBuildable {
    var configuration: APIConfiguration { get }
    var method: Method { get }
    var api: API { get }
    var path: String { get }
    var parameters: [String: Any]? { get }

    func requestData(_ completion: @escaping ResultHandle<Data>)
    func requestResult<Result: Decodable>(_ resultType: Result.Type,
                                          completion: @escaping ResultHandle<Result>)
}

extension APIRequestBuildable {

    public func requestResult<Result: Decodable>(_ resultType: Result.Type,
                                                 completion: @escaping ResultHandle<Result>) {
        requestData { (data, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, nil)
                return
            }

            do {
                let result: Result = try Result.jsonDecoder.decode(Result.self, from: data)
                completion(result, nil)
            } catch {
                completion(nil, .decodeFailed(reason: error.localizedDescription))
            }
        }
    }

}

public protocol URLRequestCreatable {
    func createRequest(configuration: APIConfiguration, url: URL) throws -> URLRequest
}

public struct OAuthRequestCreator: URLRequestCreatable {
    public func createRequest(configuration: APIConfiguration, url: URL) throws -> URLRequest {
        var request: URLRequest = URLRequest(url: url)
        request.addValue("Tweeeter_iOS_v1.0", forHTTPHeaderField: "User-Agent")
        request.addValue("Basic \(configuration.clientCredential.bearerToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        return request
    }
}

public struct CommonRequestCreator: URLRequestCreatable {
    public func createRequest(configuration: APIConfiguration, url: URL) throws -> URLRequest {
        guard let accessToken = configuration.accessTokenProvider.accessToken else {
            throw APIRequestError.needAuthentication
        }
        var request: URLRequest = URLRequest(url: url)
        request.addValue("Tweeeter_iOS_v1.0", forHTTPHeaderField: "User-Agent")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        return request
    }
}

public class APIRequestBuilder: APIRequestBuildable {

    public let configuration: APIConfiguration
    public let method: Method
    public let api: API
    let apiVersion: String?
    public let path: String
    public let parameters: [String: Any]?

    private let requestCreator: URLRequestCreatable

    init(configuration: APIConfiguration = .default,
         requestCreator: URLRequestCreatable = CommonRequestCreator(),
         method: Method = .get,
         api: API = .api,
         apiVersion: String? = "1.1",
         path: String,
         parameters: [String: Any]? = nil) {
        self.configuration = configuration
        self.requestCreator = requestCreator
        self.method = method
        self.api = api
        self.apiVersion = apiVersion
        self.path = path
        self.parameters = parameters
    }

    func createURL() -> URL {
        guard let baseURL: URL = URL(string: api.rawValue) else { fatalError() }
        var url = baseURL
        if let version = apiVersion {
            url = url.appendingPathComponent(version)
        }
        url = url.appendingPathComponent(path)
        if method == .get, let parameters = self.parameters {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            comps?.queryItems = parameters.map({ URLQueryItem(name: $0, value: "\($1)") })
            guard let queryAppendedURL = comps?.url else { fatalError() }
            url = queryAppendedURL
        }
        return url
    }

    public func requestData(_ completion: @escaping ResultHandle<Data>) {
        do {
            var request: URLRequest = try requestCreator.createRequest(configuration: configuration, url: createURL())
            request.httpMethod = method.method
            if method == .post, let parameters = self.parameters {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            }
            let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        completion(data, nil)
                    } else {
                        completion(data, .statusError(httpResponse.statusCode))
                    }
                } else {
                    completion(data, error != nil ? .unknown : nil)
                }
            }
            session.resume()
        } catch {
            let error = error as? APIRequestError ?? .unknown
            switch error {
            case .needAuthentication:
                guard configuration.requestAccessTokenIfNeeded else { break }
                OAuthRequestBuilder(configuration: configuration).request {( _, error) in
                    if let error = error {
                        completion(nil, error)
                    } else {
                        self.requestData(completion)
                    }
                }
                return
            default: break
            }
            completion(nil, error)
        }
    }
}
