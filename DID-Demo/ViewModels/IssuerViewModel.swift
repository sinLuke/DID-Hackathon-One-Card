//
//  IssuerViewModel.swift
//  DID-Demo
//
//  Created by Luke on 27/1/2022.
//

import UIKit

class IssuerViewModel: InteractiveViewMdoel {
    let request: IssueAPI.Request
    
    init(request: IssueAPI.Request) {
        self.request = request
    }

    override func trigger(didSession: DIDSession) {
        network.api(IssueAPI(body: request), authorization: nil) { result in
            do {
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
    }
}
