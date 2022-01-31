//
//  IssueAPI.swift
//  DID-Demo
//
//  Created by Luke on 2022-01-25.
//

import Foundation

struct IssueAPI: API {
    
    let method: HttpMethod = .POST
    let url = URL(string: "https://did.sinluke.com/api/issuer/issuance-request")!
    let body: Request?
    
    struct Response: Codable {
        var requestId: UUID?
        var url: URL
        var expiry: Double?
        var pin: String?
        var id: String
    }
    
    struct Request: Codable {
        var firstName: String
        var lastName: String
        var phoneNumber: String
        var birthday: String
        var address: String
        var city: String
        var postalCode: String
        var weight: String
        var gender: String
        var eyes: String
        var hair: String
        var `class`: String
    }
}
