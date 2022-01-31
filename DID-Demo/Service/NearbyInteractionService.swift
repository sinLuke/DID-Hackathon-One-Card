//
//  NearbyInteractionService.swift
//  DID-Demo
//
//  Created by Luke on 29/1/2022.
//

import UIKit
import NearbyInteraction
import MultipeerConnectivity
import Combine

class NearbyInteractionService: NSObject, DIDSessionDelegate, MPCSessionDelegate {
    
    func sessionNotification(_ notification: String) {
        self.notification.send(notification)
    }
    
    
    var peerDiscoveryToken: NIDiscoveryToken?
    var mpc = MPCSession(service: "diddemo", identity: "luke.general.DID-Demo-nearbyinteraction", maxPeers: 1)
    var sharedTokenWithPeer = false
    var didSessions: [MCPeerID: DIDSession] = [:]
    var connectedSession: DIDSession?
    let role: Role
    var notification = PassthroughSubject<String, Never>()
    weak var delegate: NearbyInteractionDelegate?
    
    init(role: Role) {
        self.role = role
        super.init()
        
        mpc.delegate = self
        mpc.invalidate()
        mpc.start()
    }
    
    func connectedToPeer(peer: MCPeerID) {
        notification.send("\(peer.displayName) connected")
        let didSession = DIDSession(peer: peer, mcSession: mpc.mcSession, role: role.rawValue)
        didSession.delegate = self
        didSessions[peer] = didSession
    }

    func disconnectedFromPeer(peer: MCPeerID) {
        notification.send("\(peer.displayName) disconnected")
        didSessions[peer]?.invalidateSession()
    }
    
    func dataReceived(data: Data, peer: MCPeerID) {
        if let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data)  {
            notification.send("\(peer.displayName) recieve token")
            didSessions[peer]?.start(peerToken: discoveryToken)
        }
        
        if let peerRole = Role(rawValue: String(data: data, encoding: .utf8) ?? "unknwon") {
            notification.send("\(peer.displayName) recieve role")
            if self.role == .user {
                if peerRole != .user {
                    return
                }
            } else {
                if peerRole == .user {
                    return
                }
            }
            didSessions[peer]?.invalidateSession()
        }
        
        if role == .issuer, String(data: data, encoding: .utf8) == "Issue Recieved" {
            delegate?.success(nil)
        }
        
        if role == .user, String(data: data, encoding: .utf8) == "Wait" {
            delegate?.wait()
        }
        if role == .user, String(data: data, encoding: .utf8) == "Sucess" {
            delegate?.success({
                return
            })
        }
        if role == .user, String(data: data, encoding: .utf8) == "Failure" {
            delegate?.fail(errorMessage: "SORRY, YOU ARE NOT QUALIFIED", nil)
        }
        
        let jsonDecoder = JSONDecoder()
        
        if role == .user {
            if let response = try? jsonDecoder.decode(IssueAPI.Response.self, from: data) {
                try? mpc.mcSession.send("Issue Recieved".data(using: .utf8)!, toPeers: [peer], with: .reliable)
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                self.delegate?.recieveVC()
                if UIApplication.shared.canOpenURL(response.url) {
                    UIApplication.shared.open(response.url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(URL(string: "https://apps.apple.com/app/microsoft-authenticator/id983156458")!, options: [:], completionHandler: nil)
                }
            } else if let response = try? jsonDecoder.decode(VerifyAPI.Response.self, from: data) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                delegate?.wait()
                if UIApplication.shared.canOpenURL(response.url) {
                    UIApplication.shared.open(response.url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(URL(string: "https://apps.apple.com/app/microsoft-authenticator/id983156458")!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    enum Role: String {
        case issuer
        case verifier
        case user
    }
    
    func sessionDistanceUpdated() {
        var miniumDistance = Float.greatestFiniteMagnitude
        var miniumSession: DIDSession?
        didSessions.values.filter { $0.state == .detecting }.forEach { session in
            if session.distance < miniumDistance {
                miniumDistance = session.distance
                miniumSession = session
            }
        }
        if role == .issuer || role == .verifier, miniumDistance < 0.05, let miniumSession = miniumSession, miniumSession.state == .detecting {
            miniumSession.connect()
            try? mpc.mcSession.send("Wait".data(using: .utf8)!, toPeers: [miniumSession.peer], with: .reliable)
            delegate?.trigger(didSession: miniumSession)
        }
    }
    
    deinit {
        mpc.invalidate()
        didSessions.values.forEach { session in
            session.invalidateSession()
        }
    }
}

protocol NearbyInteractionDelegate: AnyObject {
    func trigger(didSession: DIDSession)
    func recieveVC()
    func wait()
    func success(_ completion: (() -> ())?)
    func fail(errorMessage: String, _ completion: (() -> ())?)
}
