//
//  RootViewController.swift
//  DID-Demo
//
//  Created by Luke on 2022-01-25.
//

import UIKit
import Lottie
class RootViewController: UIViewController {
    @IBOutlet weak var buttonStack: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @IBAction func ontapIssuer(_ sender: Any) {
        let navigationController = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IssuerViewController") as! IssuerViewController)
        navigationController.navigationBar.tintColor = UIColor(named: "OneCard Dark")
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func ontapUser(_ sender: Any) {
        let interactiveViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InteractiveViewController") as! InteractiveViewController
        interactiveViewController.nearbyService = NearbyInteractionService(role: .user)
        interactiveViewController.viewModel = InteractiveViewMdoel()
        let navigationController = UINavigationController(rootViewController: interactiveViewController)
        navigationController.navigationBar.tintColor = UIColor(named: "OneCard Dark")
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func ontapVarifier(_ sender: Any) {
        let navigationController = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VerifierViewController") as! VerifierViewController)
        navigationController.navigationBar.tintColor = UIColor(named: "OneCard Dark")
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}
