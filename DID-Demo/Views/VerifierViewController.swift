//
//  VerifierViewController.swift
//  DID-Demo
//
//  Created by Luke on 29/1/2022.
//

import UIKit
import Combine

class VerifierViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allVerifiers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let verifier = allVerifiers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! VerifierCell
        cell.mainLabel.text = verifier.displayName.uppercased()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let verifierInputViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VerifierInputViewController") as! VerifierInputViewController
        verifierInputViewController.verifier = allVerifiers[indexPath.row]
        navigationController?.pushViewController(verifierInputViewController, animated: true)
        tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
    }
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


class VerifierInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var bottomFlotingView: UIVisualEffectView!
    @IBOutlet weak var verifyUserButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var link: UILabel!
    override var canBecomeFirstResponder: Bool { true }
    var verifier: Verifier!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        verifyUserButton.layer.cornerRadius = 3
        let linkText = NSMutableAttributedString(string: "")
        linkText.append(NSAttributedString(string: "Please look at ", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular)]))
        linkText.append(NSAttributedString(string: "Privacy Policy", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.systemFont(ofSize: 13, weight: .regular)]))
        linkText.append(NSAttributedString(string: " and ", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular)]))
        linkText.append(NSAttributedString(string: "Terms of Use", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.systemFont(ofSize: 13, weight: .regular)]))
        linkText.append(NSAttributedString(string: ".", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular)]))
        link.attributedText = linkText
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verifier.inputs.count + 1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "SET RULES"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Header", for: indexPath) as! VerifierInputHeaderCell
            cell.mainLabel?.text = "REQUEST: \(verifier.displayName.uppercased())"
            return cell
        } else {
            let input = verifier.requireInput[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! VerifierInputCell
            cell.mainLabel.text = "\(input):"
            cell.mainInput.delegate = self
            cell.mainInput.placeholder = verifier.inputs[input] ?? ""
            cell.mainInput.tag = indexPath.row - 1
            return cell
        }
    }
    
    @IBAction func verify(_ sender: Any) {
        let interactiveViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InteractiveViewController") as! InteractiveViewController
        interactiveViewController.viewModel = VerifierViewModel(verifier: verifier)
        interactiveViewController.nearbyService = NearbyInteractionService(role: .verifier)
        if let navigationController = navigationController {
            navigationController.setViewControllers([navigationController.viewControllers[0], interactiveViewController], animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let inputLabel = verifier.requireInput[textField.tag]
        verifier.inputs[inputLabel] = textField.text
        textField.resignFirstResponder()
        return true
    }
}

class VerifierInputHeaderCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    override func awakeFromNib() {
        selectionStyle = .none
    }
}

class VerifierInputCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mainInput: UITextField!
    override func awakeFromNib() {
        selectionStyle = .none
    }
}

class VerifierCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
}
