//
//  IssuerViewController.swift
//  DID-Demo
//
//  Created by Luke on 29/1/2022.
//

import UIKit
import Combine

class IssuerViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributeText = NSAttributedString(string: "Contact Technical Support", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.systemFont(ofSize: 13, weight: .regular)])
        supportButton.setAttributedTitle(attributeText, for: .normal)
        logoutButton.layer.cornerRadius = 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func newUserOnTap(_ sender: Any) {
        let newUserForm = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewUserFormViewController") as! NewUserFormViewController
        navigationController?.pushViewController(newUserForm, animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
