//
//  Verifiers.swift
//  DID-Demo
//
//  Created by Luke on 31/1/2022.
//

import Foundation

protocol Verifier {
    var displayName: String { get }
    var requireInput: [String] { get }
    var inputs: [String: String] { get set }
    var messageSuccess: String { get }
    var messageFailure: String { get }
    func verify(payload: IssueAPI.Request) -> Bool
}

let allVerifiers = [
    NameVerifier(),
    AgeVerifier(),
    AddressVerifier(),
    CityVerifier(),
    GenderVerifier(),
    WeightVerifier(),
    EyeVerifier(),
    HairVerifier(),
    ClassVerifier()
] as [Verifier]

struct NameVerifier: Verifier {
    var displayName = "Name Contains"
    var requireInput = ["NAME"]
    var inputs: [String: String] = ["NAME": "John"]
    var messageSuccess: String { "THE USER'S NAME CONTAINS \(inputs["NAME"] ?? "")" }
    var messageFailure: String { "THE USER'S NAME DOES NOT CONTAINS \(inputs["NAME"] ?? "")" }
    func verify(payload: IssueAPI.Request) -> Bool {
        guard let name = inputs["NAME"] else { return false }
        let compareName = (payload.lastName + payload.firstName + payload.lastName).cleanedUp()
        return compareName.contains(name.cleanedUp())
    }
}

struct AgeVerifier: Verifier {
    var displayName = "Age is in range"
    var requireInput = ["BIGGER THAN OR EQUAL TO", "SMALLER THAN"]
    var inputs: [String: String] = ["BIGGER THAN OR EQUAL TO": "18", "SMALLER THAN": ""]
    var messageSuccess: String { "THE USER'S AGE IS QUALIFIED" }
    var messageFailure: String { "THE USER'S AGE IS NOT QUALIFIED" }
    func verify(payload: IssueAPI.Request) -> Bool {
        let startAge = Int(inputs["BIGGER THAN OR EQUAL TO"] ?? "0") ?? 0
        let endAge = Int(inputs["SMALLER THAN"] ?? "100") ?? 1000
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = kDateFormate
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale.current
        guard let birthdayDate = dateFormatter.date(from: payload.birthday) else { return false }
        let calender = Calendar.current
        let age = calender.dateComponents([.year], from: birthdayDate, to: Date()).year ?? -1
        
        return age >= startAge && age < endAge
    }
}

struct PhoneVerifier: Verifier {
    var displayName = "Phone Number"
    var requireInput = ["PHONE"]
    var inputs: [String: String] = ["PHONE": "000-000-0000"]
    var messageSuccess: String { "THE USER'S PHONE IS QUALIFIED" }
    var messageFailure: String { "THE USER'S PHONE IS NOT QUALIFIED" }
    func verify(payload: IssueAPI.Request) -> Bool {
        guard let phone = inputs["PHONE"] else { return false }
        let phoneCompare = phone
        return payload.phoneNumber.cleanedUp() == phoneCompare.cleanedUp()
    }
}



struct AddressVerifier: Verifier {
    var displayName = "Address"
    var requireInput = ["STREET NAME"]
    var inputs: [String: String] = ["STREET NAME": "Main"]
    var messageSuccess: String { "THE USER'S ADDRES IS QUALIFIED" }
    var messageFailure: String { "THE USER'S ADDRES IS NOT QUALIFIED" }
    func verify(payload: IssueAPI.Request) -> Bool {
        guard let streetName = inputs["STREET NAME"] else { return false }
        let compareName = (payload.address).cleanedUp()
        return compareName.contains(streetName.cleanedUp())
    }
}

struct CityVerifier: Verifier {
    var displayName = "City Province"
    var requireInput = ["CITY", "PROVINCE"]
    var inputs: [String: String] = ["CITY": "Vancouver", "PROVINCE": "BC"]
    var messageSuccess: String { "THE USER'S ADDRES IS QUALIFIED" }
    var messageFailure: String { "THE USER'S ADDRES IS NOT QUALIFIED" }
    func verify(payload: IssueAPI.Request) -> Bool {
        guard let city = inputs["CITY"], let province = inputs["PROVINCE"] else { return false }
        return payload.city.cleanedUp() == (city + province).cleanedUp()
    }
}

struct GenderVerifier: Verifier {
    var displayName = "Gender"
    var requireInput = ["GENDER"]
    var inputs: [String: String] = ["GENDER": "Female"]
    var messageSuccess: String { "THE USER'S GENDER IS QUALIFIED" }
    var messageFailure: String { "THE USER'S GENDER IS NOT QUALIFIED" }
    func verify(payload: IssueAPI.Request) -> Bool {
        guard let gender = inputs["GENDER"] else { return false }
        return payload.gender.cleanedUp() == gender.cleanedUp()
    }
}

struct WeightVerifier: Verifier {
    var displayName = "Weight is in range"
    var requireInput = ["BIGGER THAN OR EQUAL TO", "SMALLER THAN"]
    var inputs: [String: String] = ["BIGGER THAN OR EQUAL TO": "80", "SMALLER THAN": "100"]
    var messageSuccess: String { "THE USER'S WEIGHT IS QUALIFIED" }
    var messageFailure: String { "THE USER'S WEIGHT IS NOT QUALIFIED" }
    func verify(payload: IssueAPI.Request) -> Bool {
        let startWeight = Double(inputs["BIGGER THAN OR EQUAL TO"] ?? "0") ?? 0
        let endWeight = Double(inputs["SMALLER THAN"] ?? "0") ?? 1000
        
        guard let weight = Double(payload.weight) else { return false }
        
        return weight >= startWeight && weight < endWeight
    }
}

struct EyeVerifier: Verifier {
    var displayName = "Eye Color"
    var requireInput = ["EYE COLOR"]
    var inputs: [String: String] = ["EYE COLOR": "Brown"]
    var messageSuccess: String { "THE USER'S EYE COLOR IS QUALIFIED" }
    var messageFailure: String { "THE USER'S EYE COLOR IS NOT QUALIFIED" }
    func verify(payload: IssueAPI.Request) -> Bool {
        guard let eyes = inputs["EYE COLOR"] else { return false }
        return payload.eyes.cleanedUp() == eyes.cleanedUp()
    }
}

struct HairVerifier: Verifier {
    var displayName = "Hair Color"
    var requireInput = ["HAIR COLOR"]
    var inputs: [String: String] = ["HAIR COLOR": "Brown"]
    var messageSuccess: String { "THE USER'S HAIR COLOR IS QUALIFIED" }
    var messageFailure: String { "THE USER'S HAIR COLOR IS NOT QUALIFIED" }
    func verify(payload: IssueAPI.Request) -> Bool {
        guard let hair = inputs["HAIR COLOR"] else { return false }
        return payload.hair.cleanedUp() == hair.cleanedUp()
    }
}

struct ClassVerifier: Verifier {
    var displayName = "Driver Licence Class"
    var requireInput = ["DRIVER LICENCE CLASS"]
    var inputs: [String: String] = ["DRIVER LICENCE CLASS": "5"]
    var messageSuccess: String { "THE USER'S CLASS IS QUALIFIED" }
    var messageFailure: String { "THE USER'S CLASS IS NOT QUALIFIED" }
    func verify(payload: IssueAPI.Request) -> Bool {
        guard let `class` = inputs["DRIVER LICENCE CLASS"] else { return false }
        return payload.class.cleanedUp() == `class`.cleanedUp()
    }
}


extension String {
    func cleanedUp() -> String {
        self.lowercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "")
    }
}
