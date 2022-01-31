//
//  DIDSession.swift
//  DID-Demo
//
//  Created by Luke on 29/1/2022.
//

import UIKit
import NearbyInteraction
import MultipeerConnectivity

class DIDSession: NSObject, NISessionDelegate {
    let session = NISession()
    let peer: MCPeerID
    let mcSession: MCSession
    var peerToken: NIDiscoveryToken?
    var distance: Float = Float.greatestFiniteMagnitude
    weak var delegate: DIDSessionDelegate?
    private(set) var state: State = .initalized
    init(peer: MCPeerID, mcSession: MCSession, role: String) {
        self.peer = peer
        self.mcSession = mcSession
        super.init()
        session.delegate = self
        if
            let discoveryToken = session.discoveryToken,
                let encodedToken = try? NSKeyedArchiver.archivedData(withRootObject: discoveryToken, requiringSecureCoding: true),
                let roleData = role.data(using: .utf8) {
            do {
                try mcSession.send(encodedToken, toPeers: [peer], with: .reliable)
                try mcSession.send(roleData, toPeers: [peer], with: .reliable)
            } catch {
                UIApplication.shared.showAlert(alert: .error(error: error), nil)
            }
        }
        delegate?.sessionNotification("DIDSession created \(peer.displayName)")
    }
    
    func start(peerToken: NIDiscoveryToken) {
        let config = NINearbyPeerConfiguration(peerToken: peerToken)
        self.peerToken = peerToken
        session.run(config)
        state = .detecting
        delegate?.sessionNotification("DIDSession start \(peer.displayName)")
    }
    
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let peerToken = self.peerToken else {
            UIApplication.shared.showAlert(alert: .string(value: "don't have peer token"), nil)
            return
        }

        let peerObj = nearbyObjects.first { (obj) -> Bool in
            return obj.discoveryToken == peerToken
        }

        guard let nearbyObjectUpdate = peerObj else {
            return
        }
        
        if let distance = nearbyObjectUpdate.distance {
            self.distance = distance
            delegate?.sessionDistanceUpdated()
        }
    }

    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        guard let peerToken = self.peerToken else {
            UIApplication.shared.showAlert(alert: .string(value: "don't have peer token"), nil)
            return
        }

        let peerObj = nearbyObjects.first { (obj) -> Bool in
            return obj.discoveryToken == peerToken
        }

        if peerObj == nil {
            return
        }

        delegate?.sessionNotification("DIDSession get removed \(peer.displayName)")
        self.invalidateSession()
    }
    
    func invalidateSession() {
        self.state = .invalidated
        session.invalidate()
        delegate?.sessionNotification("DIDSession get invalidated \(peer.displayName)")
    }
    
    func connect() {
        self.state = .connected
    }
    
    deinit {
        self.invalidateSession()
        delegate?.sessionNotification("DIDSession get deinit \(peer.displayName)")
    }
    
    enum State {
        case initalized
        case detecting
        case connected
        case invalidated
    }
}

protocol DIDSessionDelegate: AnyObject {
    func sessionDistanceUpdated()
    func sessionNotification(_ notification: String)
}
