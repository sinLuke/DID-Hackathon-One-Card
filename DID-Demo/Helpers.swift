//
//  Helpers.swift
//  DID-Demo
//
//  Created by Luke on 2022-01-25.
//

import Foundation
import simd
import UIKit

enum Alert {
    case string(value: String)
    case message(title: String, message: String)
    case error(error: Error?)
}

extension UIViewController: ViewModelDatagate {
    @objc func showSucess(message: String) {
        return
    }
    
    @objc func showFailure(message: String) {
        return
    }
    
    func showResultPage(result: Any) {
        return
    }
    
    func showAlert(alert: Alert, _ completion: (() -> ())? = nil) {
        var title = ""
        var message = ""
        switch alert {
        case .string(let value):
            title = "Alert"
            message = value
        case .message(let _title, let _message):
            title = _title
            message = _message
        case .error(let error):
            title = "Error"
            message = error?.localizedDescription ?? "Unknown Error"
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] _ in
            alertController?.dismiss(animated: true, completion: completion)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIApplication {
    func showAlert(alert: Alert, _ completion: (() -> ())? = nil) {
        guard let mainWindow = keyWindow else {
            completion?()
            return
        }
        if let presentedViewController = mainWindow.rootViewController?.presentedViewController {
            presentedViewController.showAlert(alert: alert, completion)
        } else {
            mainWindow.rootViewController?.showAlert(alert: alert, completion)
        }
        
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

func azimuth(from direction: simd_float3) -> Float {
    return asin(direction.x)
}

func elevation(from direction: simd_float3) -> Float {
    return atan2(direction.z, direction.y) + .pi / 2
}

protocol ViewModelDatagate: AnyObject {
    func showResultPage(result: Any)
    func showSucess(message: String)
    func showFailure(message: String)
}

