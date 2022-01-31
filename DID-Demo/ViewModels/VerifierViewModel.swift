//
//  VerifierViewModel.swift
//  DID-Demo
//
//  Created by Luke on 29/1/2022.
//

import UIKit
import Combine

class VerifierViewModel: InteractiveViewMdoel {
    var timer = Timer()
    var response: VerifyAPI.Response?
    let verifier: Verifier
    
    init(verifier: Verifier) {
        self.verifier = verifier
    }

    override func trigger(didSession: DIDSession) {
        let timerStart = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
            guard let response = self.response else { return }
            self.network.api(PresentationResponseAPI(id: response.id), authorization: nil) { result in
                if let payload = result.payload {
                    do {
                        if let payloadDecoded = try JSONDecoder().decode([PresentationResponseAPI.Response.Payload].self, from: payload.data(using: .utf8) ?? Data()).first {
                            if self.verifier.verify(payload: payloadDecoded.claims) {
                                self.delegate?.showSucess(message: self.verifier.messageSuccess)
                            } else {
                                self.delegate?.showFailure(message: self.verifier.messageFailure)
                            }
                        }
                    }
                    catch {
                        UIApplication.shared.showAlert(alert: .error(error: error), nil)
                    }
                    self.timer.invalidate()
                }
                
                if timerStart.timeIntervalSinceNow < -100 {
                    self.timer.invalidate()
                    UIApplication.shared.showAlert(alert: .string(value: "Time out"), nil)
                }
            } failure: { error in
                UIApplication.shared.showAlert(alert: .error(error: error), nil)
            }
        })
        timer.fire()

        network.api(VerifyAPI(), authorization: nil) { result in
            do {
                self.response = result
                let encoder = JSONEncoder()
                guard let encodedData = try? encoder.encode(result) else {
                    UIApplication.shared.showAlert(alert: .string(value: "Error when encode data"), nil)
                    return
                }
                try didSession.mcSession.send(encodedData, toPeers: [didSession.peer], with: .reliable)
            } catch {
                UIApplication.shared.showAlert(alert: .error(error: error), nil)
            }
        } failure: { error in
            UIApplication.shared.showAlert(alert: .error(error: error), nil)
        }
        
        try? didSession.mcSession.send("Wait".data(using: .utf8)!, toPeers: [didSession.peer], with: .reliable)
    }
    
    deinit {
        timer.invalidate()
    }
}
