//
//  InteractiveViewController.swift
//  DID-Demo
//
//  Created by Luke on 30/1/2022.
//

import Foundation
import UIKit
import Lottie

class InteractiveViewController: UIViewController, NearbyInteractionDelegate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    var errorMessage: String?
    var successMessage: String?
    
    let animationView = AnimationView()
    let detectAnimation = Animation.named("detecting")
    let userDetectAnimation = Animation.named("userDetecting")
    let waitingAnimation = Animation.named("waiting")
    let sucessAnimation = Animation.named("sucess")
    let failAnimation = Animation.named("fail")
    var role: NearbyInteractionService.Role = .user
    
    var viewModel: InteractiveViewMdoel!
    var nearbyService: NearbyInteractionService!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setAnimationState(.detect, nil)
    }
    
    func setAnimationState(_ state: State, _ completion: (() -> ())?) {
        
        switch state {
        case .detect:
            if nearbyService.role == .user {
                animationView.animation = userDetectAnimation
                animationView.loopMode = .loop
                messageLabel.text = "HOLD CLOSE TO ISSUER'S DEVICE"
            } else {
                animationView.animation = detectAnimation
                animationView.loopMode = .loop
                messageLabel.text = "HOLD CLOSE TO USER'S PHONE"
            }
            navigationController?.setNavigationBarHidden(true, animated: true)
        case .wait:
            animationView.animation = waitingAnimation
            animationView.loopMode = .loop
            messageLabel.text = "WAITING ..."
            navigationController?.setNavigationBarHidden(true, animated: true)
        case .success:
            animationView.animation = sucessAnimation
            animationView.loopMode = .playOnce
            switch nearbyService.role {
            case .user:
                messageLabel.text = ""
            case .issuer:
                messageLabel.text = "UPDATE COMPLETE"
            case .verifier:
                messageLabel.text = "THE USER IS QUALIFIED"
            }
            
            if let successMessage = successMessage {
                messageLabel.text = successMessage.uppercased()
            }
            navigationController?.setNavigationBarHidden(false, animated: true)
        case .fail:
            animationView.animation = failAnimation
            animationView.loopMode = .playOnce
            switch nearbyService.role {
            case .user:
                messageLabel.text = "ERROR \(errorMessage ?? "")"
            case .issuer:
                messageLabel.text = "ERROR \(errorMessage ?? "")"
            case .verifier:
                messageLabel.text = "THE USER IS NOT QUALIFIED"
            }
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        
        animationView.play { _ in
            completion?()
        }
    }
    
    override func viewDidLoad() {
        nearbyService.delegate = self
        viewModel.delegate = self
        containerView.addSubview(animationView)
    }
    
    enum State {
        case detect
        case wait
        case success
        case fail
    }
    
    func trigger(didSession: DIDSession) {
        setAnimationState(.wait, nil)
        viewModel.trigger(didSession: didSession)
    }
    
    func recieveVC() {
        if self.role == .user {
            self.nearbyService = NearbyInteractionService(role: .user)
            self.nearbyService.delegate = self
            self.setAnimationState(.detect, nil)
        }
    }
    
    func wait() {
        setAnimationState(.wait, nil)
    }
    
    func success(_ completion: (() -> ())?) {
        setAnimationState(.success, {
            completion?()
        })
    }
    
    func fail(errorMessage: String, _ completion: (() -> ())?) {
        self.errorMessage = errorMessage
        setAnimationState(.fail, completion)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animationView.frame = containerView.bounds
    }
    
    override func showSucess(message: String) {
        success {
            return
        }
    }
    
    override func showFailure(message: String) {
        fail(errorMessage: message) {
            return
        }
    }
}

class InteractiveViewMdoel {
    let network = NetworkService()
    weak var delegate: ViewModelDatagate?
    func trigger(didSession: DIDSession) {}
}
