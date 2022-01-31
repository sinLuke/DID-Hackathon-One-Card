//
//  NetworkService.swift
//  DID-Demo
//
//  Created by Luke on 2022-01-25.
//

import Foundation

let sharedEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dataEncodingStrategy = .base64
    encoder.dateEncodingStrategy = .iso8601
    return encoder
}()

let sharedDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dataDecodingStrategy = .base64
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()

class NetworkService: NSObject, URLSessionDelegate {
    var session: URLSession!
    
    override init() {
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }
    
    func api<SomeAPI: API>(_ api: SomeAPI, authorization: Authorization? = nil, success: @escaping (SomeAPI.Response) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: api.url)
        request.httpMethod = api.method.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let authorization = authorization {
            switch authorization {
            case let .basic(username, password):
                let loginData = "\(username):\(password)".data(using: String.Encoding.utf8)!
                let base64LoginString = loginData.base64EncodedString()
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            case let .bearer(token):
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        if let body = api.body {
            do {
                request.httpBody = try sharedEncoder.encode(body)
            } catch {
                print("Body encode error: \(error.localizedDescription)")
            }
        }
        
        session.dataTask(with: request) { data, response, networkError in
            if let networkError = networkError {
                return failure(networkError)
            }
            guard let data = data else { return failure(NSError()) }
            do {
                let object = try sharedDecoder.decode(SomeAPI.Response.self, from: data)
                return success(object)
            } catch {
                print(error.localizedDescription)
                return failure(error)
            }
        }.resume()
    }
    
    enum Authorization {
        case basic(username: String, password: String)
        case bearer(token: String)
    }
}

protocol API {
    associatedtype Response: Codable
    associatedtype Request: Codable
    var url: URL { get }
    var method: HttpMethod { get }
    var body: Request? { get }
}

enum HttpMethod: String {
    case GET
    case HEAD
    case POST
    case PUT
    case DELETE
    case CONNECT
    case OPTIONS
    case TRACE
    case PATCH
}
