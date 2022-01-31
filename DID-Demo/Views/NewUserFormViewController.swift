//
//  NewUserFormViewController.swift
//  DID-Demo
//
//  Created by Luke on 30/1/2022.
//

import UIKit
import SwiftUI

let kDateFormate = "MMMM dd, yyyy"
class NewUserFormViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var bottomFloatingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var createIdButton: UIButton!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var birthdayTextField: DateTextField!
    @IBOutlet weak var birthdayDatePicker: DatePicker!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var eyesTextField: UITextField!
    @IBOutlet weak var hairTextField: UITextField!
    @IBOutlet weak var classTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        birthdayTextField.datePicker = birthdayDatePicker
        scrollView.delegate = self
        registerForKeyboardNotifications()
        stackView.arrangedSubviews.forEach { view in
            (view as? UITextField)?.delegate = self
        }
        createIdButton.layer.cornerRadius = 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    var bottomInset: CGFloat = 0
    var keyboardInset: CGFloat = 0
    func resetScrollViewInsetsIfNeedeed() {
        let newContentInset = UIEdgeInsets(top: 0, left: 0, bottom: max(bottomInset, keyboardInset), right: 0)
        if scrollView.contentInset != newContentInset {
            scrollView.contentInset = newContentInset
        }
        if scrollView.verticalScrollIndicatorInsets != newContentInset {
            scrollView.scrollIndicatorInsets = newContentInset
        }
    }

    override var canBecomeFirstResponder: Bool { true }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.becomeFirstResponder()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // Don't forget to unregister when done
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func onKeyboardAppear(_ notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size

        self.keyboardInset = keyboardSize.height
        UIView.animate(withDuration: 0.3) {
            self.resetScrollViewInsetsIfNeedeed()
        }
    }

    @objc func onKeyboardDisappear(_ notification: NSNotification) {
        self.keyboardInset = 0
        UIView.animate(withDuration: 0.3) {
            self.resetScrollViewInsetsIfNeedeed()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomInset = bottomFloatingView.bounds.height
        self.resetScrollViewInsetsIfNeedeed()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var flag = false
        textField.superview?.subviews.forEach({ view in
            if (view as? UITextField)?.tag == (textField.tag + 1) {
                view.becomeFirstResponder()
                flag = true
            }
        })
        if !flag {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func createId(_ sender: Any) {
        let interactiveViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InteractiveViewController") as! InteractiveViewController
        interactiveViewController.viewModel = IssuerViewModel(request: IssueAPI.Request(firstName: firstNameTextField.text ?? "", lastName: lastNameTextField.text ?? "", phoneNumber: phoneNumberTextField.text ?? "", birthday: birthdayTextField.text ?? "", address: addressTextField.text ?? "", city: cityTextField.text ?? "", postalCode: postalCodeTextField.text ?? "", weight: weightTextField.text ?? "", gender: genderTextField.text ?? "", eyes: eyesTextField.text ?? "", hair: hairTextField.text ?? "", class: classTextField.text ?? ""))
        interactiveViewController.nearbyService = NearbyInteractionService(role: .issuer)
        navigationController?.pushViewController(interactiveViewController, animated: true)
    }
}

class DatePicker: UIDatePicker {
    override var canBecomeFirstResponder: Bool { true }
    override func becomeFirstResponder() -> Bool {
        self.isHidden = false
        if let scrollview = (self.superview?.superview as? UIScrollView) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollview.scrollRectToVisible(scrollview.convert(self.bounds, from: self), animated: true)
            }
        }
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        self.isHidden = true
        return super.resignFirstResponder()
    }
}


class DateTextField: UITextField, UITextFieldDelegate {
    weak var datePicker: UIDatePicker? {
        didSet {
            datePicker?.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
            inputView = UIView()
            inputAccessoryView = UIView()
        }
    }
    
    var date: Date? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = kDateFormate
            if let date = date {
                self.text = dateFormatter.string(from: date)
            } else {
                self.text = ""
            }
        }
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    override func becomeFirstResponder() -> Bool {
        return datePicker?.becomeFirstResponder() ?? true
    }
}
