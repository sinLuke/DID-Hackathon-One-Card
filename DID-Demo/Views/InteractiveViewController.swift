//
//  InteractiveViewController.swift
//  DID-Demo
//
//  Created by Luke on 30/1/2022.
//

import Foundation
import UIKit
import Lottie
import NearbyInteraction

class InteractiveViewController: UIViewController, NearbyInteractionDelegate, ViewModelDatagate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var qrcodeImage: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var qrcodeButton: UIButton!
    var errorMessage: String?
    var successMessage: String?
    var requireQRCodeInstead = false
    
    let animationView = AnimationView()
    let detectAnimation = Animation.named("detecting")
    let userDetectAnimation = Animation.named("userDetecting")
    let waitingAnimation = Animation.named("waiting")
    let sucessAnimation = Animation.named("sucess")
    let failAnimation = Animation.named("fail")
    
    var viewModel: InteractiveViewMdoel!
    var nearbyService: NearbyInteractionService!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        qrcodeImage.isHidden = true
        setAnimationState(.detect, nil)
    }
    
    @IBAction func done(_ sender: Any) {
        if nearbyService.role == .user {
            navigationController?.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    func setAnimationState(_ state: State, _ completion: (() -> ())?) {
        animationView.isHidden = false
        qrcodeImage.isHidden = true
        qrcodeButton.isHidden = true
        switch state {
        case .detect:
            if (!NISession.isSupported || requireQRCodeInstead) {
                if nearbyService.role == .user {
                    messageLabel.text = "PLEASE SCAN THE QRCODE USING PHONE CAMERA"
                } else {
                    messageLabel.text = "PLEASE LET THE USER SCAN THE QRCODE USING THEIR PHONE CAMERA"
                }
                animationView.animation = waitingAnimation
                animationView.loopMode = .loop
                viewModel.trigger(didSession: nil)
            } else {
                if nearbyService.role == .user {
                    animationView.animation = userDetectAnimation
                    animationView.loopMode = .loop
                    messageLabel.text = "HOLD CLOSE TO ISSUER'S DEVICE"
                } else {
                    qrcodeButton.isHidden = false
                    animationView.animation = detectAnimation
                    animationView.loopMode = .loop
                    messageLabel.text = "HOLD CLOSE TO USER'S PHONE"
                }
                navigationController?.setNavigationBarHidden(true, animated: true)
            }
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
        let linkText = NSMutableAttributedString(string: "")
        linkText.append(NSAttributedString(string: "Generate a QRCode instead", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.systemFont(ofSize: 13, weight: .regular)]))
        qrcodeButton.setAttributedTitle(linkText, for: .normal)
        doneButton.layer.cornerRadius = 3
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
        if nearbyService.role == .user {
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
    
    func showSucess(message: String) {
        success {
            return
        }
    }
    
    func showFailure(message: String) {
        fail(errorMessage: message) {
            return
        }
    }
    
    func showQRCode(url: URL) {
        self.qrcodeImage.image = generateQRCode(from: url.absoluteString)
        animationView.isHidden = true
        qrcodeImage.isHidden = false
    }
    
    @IBAction func issueQRcode(_ sender: Any) {
        requireQRCodeInstead = true
        setAnimationState(.detect, nil)
    }
}

class InteractiveViewMdoel {
    let network = NetworkService()
    weak var delegate: ViewModelDatagate?
    func trigger(didSession: DIDSession?) {}
}
