//
//  PresentationResponseAPI.swift
//  DID-Demo
//
//  Created by Luke on 29/1/2022.
//

import Foundation

struct PresentationResponseAPI: API {
    var body: Request?
    let method: HttpMethod = .GET
    let id: String
    var url: URL { URL(string: "https://did.sinluke.com/api/verifier/presentation-response?id=\(id)")!
    }
    
    struct Response: Codable {
        var status: String
        var message: String
        var payload: String?
        
        struct Payload: Codable {
            var claims: IssueAPI.Request
        }
    }
    
    struct Request: Codable {}
}
