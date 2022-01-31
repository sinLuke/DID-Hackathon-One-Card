//
//  IssuerController.swift
//  DID-Demo
//
//  Created by Luke on 2022-01-25.
//

import Foundation
import MSAL
import Combine

class IssuerService {
    var accessToken = CurrentValueSubject<String, Never>("")
    var accountIdentifier = CurrentValueSubject<String, Never>("")
    let clientApp: MSALPublicClientApplication
    let scopes: [String]
    
    let appSetting: [String: Any] = {
        let appSettingURL = Bundle.main.url(forResource: "appsettings", withExtension: "json")!
        let appSettingData = try! Data(contentsOf: appSettingURL)
        return try! JSONSerialization.jsonObject(with: appSettingData) as! [String : Any]
    }()
    
    let issuanceRequestConfig: [String: Any] = {
        let issuanceRequestConfigURL = Bundle.main.url(forResource: "issuance_request_config", withExtension: "json")!
        let issuanceRequestConfigData = try! Data(contentsOf: issuanceRequestConfigURL)
        return try! JSONSerialization.jsonObject(with: issuanceRequestConfigData) as! [String : Any]
    }()
    
    init() {
        scopes = [appSetting.get(String.self, path: "vcServiceScope")].compactMap { $0 }
        let clientAppConfigure = MSALPublicClientApplicationConfig(clientId: appSetting.get(String.self, path: "clientId") ?? "")
        let issuerAuthority = appSetting.get(String.self, path: "issuerAuthority") ?? ""
        clientAppConfigure.authority = try! MSALAuthority(url: URL(string: issuerAuthority)!)
        self.clientApp = try! MSALPublicClientApplication(
            configuration: clientAppConfigure)
        getToken()
    }
    
    func issuanceRequest() {
        var payload = issuanceRequestConfig
        if let length = payload.get(Int.self, path: "issuance", "pin", "length") {
            let newPin = (0..<length)
                .map { _ in Int.random(in: 0..<9) }
                .map { String($0) }
                .joined()
            payload.set(newPin, path: "issuance", "pin", "value")
        }
        payload.set(UUID().uuidString, path: "callback", "state")
        payload.set(appSetting.get(String.self, path: "issuerAuthority"), path: "authority")
        payload.set(nil, path: "callback", "url")
        payload.set(appSetting.get(String.self, path: "credentialManifest"), path: "issuance", "manifest")
        payload.set("Megan", path: "issuance", "claims", "given_name")
        payload.set("Bowen", path: "issuance", "claims", "family_name")
        
        //session.dataTask(with: <#T##URL#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)
    }
    
    func getToken() {
        let viewController = AppDelegate.current?.rootViewController ?? UIViewController()
        let webviewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        
        
        let interactiveParameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webviewParameters)
        clientApp.acquireToken(with: interactiveParameters, completionBlock: { (result, error) in
            
            guard let authResult = result, error == nil else {
                viewController.showAlert(alert: .error(error: error))
                return
            }
            
            self.accessToken.send(authResult.accessToken)
            self.accountIdentifier.send(authResult.account.identifier ?? "")
        })
    }
    
    func updateToken() {
        guard let account = try? clientApp.account(forIdentifier: accountIdentifier.value) else { return }
        let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: account)
        clientApp.acquireTokenSilent(with: silentParameters) { (result, error) in
            guard let authResult = result, error == nil else {
                let nsError = error! as NSError
                if (nsError.domain == MSALErrorDomain &&
                    nsError.code == MSALError.interactionRequired.rawValue) {
                    
                    self.getToken()
                    return
                }
                return
            }
            self.accessToken.send(authResult.accessToken)
        }
    }
}
