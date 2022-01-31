//
//  VerifyAPI.swift
//  DID-Demo
//
//  Created by Luke on 29/1/2022.
//

import Foundation

struct VerifyAPI: API {
    var body: Request?
    let method: HttpMethod = .GET
    let url = URL(string: "https://did.sinluke.com/api/verifier/presentation-request")!
    
    struct Response: Codable {
        var requestId: UUID?
        var url: URL
        var expiry: Double?
        var id: String
    }
    
    struct Request: Codable {}
}
