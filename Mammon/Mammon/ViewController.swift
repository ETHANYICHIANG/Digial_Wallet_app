//
//  ViewController.swift
//  Mammon
//
//  Created by Ethan Chiang on 10/4/19.
//  Copyright © 2019 EYC. All rights reserved.
//

import UIKit
import PhoneNumberKit

class ViewController: UIViewController {

    // error massage label object
    @IBOutlet weak var errorMessageLabel: UILabel!
    // textfiled object for phone number
    @IBOutlet weak var phoneNumberTextfeild: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var e164PhoneNumber: String = ""
    
    
    let phoneNumberKit = PhoneNumberKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        // a tap that end editing(ketboard) in view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        
        // add tap gesture to view
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // pre-load phone number
        if let lastEnteredPhoneNumber = Storage.phoneNumberInE164 {
            let splitIndex = lastEnteredPhoneNumber.index(lastEnteredPhoneNumber.endIndex, offsetBy: -10)
            
            let numberToDisplay = lastEnteredPhoneNumber[splitIndex...]
            phoneNumberTextfeild.text = String(numberToDisplay)
        }
        
    }
    
    // event happens with even entry in phoneNumberTextFeild
    @IBAction func phoneNumberEnter() {
        
        // parse textFiled into any digits
        
        guard let phoneNumText = phoneNumberTextfeild.text else {
            print("Unwap failed")
            return
        }
        
        let newStr = phoneNumText.filter{!"()- ".contains($0)}
                   
        // show error massage relates to length
        if(newStr.count < 10) {
           errorMessageLabel.text = "Too short"
        }
        else if(newStr.count > 10) {
           errorMessageLabel.text = "Too long"
        }
        else {
           errorMessageLabel.text = ""
        }
    }
    
    // pass e164 phone number to varificationVC when performing segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // if the segue.destination is not VarificationVC skip passing e164PhoneNumber
        if let varificationVC = segue.destination as? VarificationViewController {
            varificationVC.e164phoneNumber = e164PhoneNumber
            //print("sent: \(e164PhoneNumber)")
        }
        
        if let homeVC = segue.destination as? HomeViewController {
            homeVC.phoneNumber = e164PhoneNumber
            //print("sent: \(e164PhoneNumber)")
        }
    }
    
    
    @IBAction func signUpButtonPress() {
        //print("sign up pressed")
        errorMessageLabel.text = ""
        
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false

        
        
        // try to parese user enter number throw error is fail
        do {
            
            guard let phoneNumText = phoneNumberTextfeild.text else {
                print("Unwrap falied")
                return
            }
            
            let phoneNumber = try phoneNumberKit.parse(phoneNumText)

            
            // data for next hw
            e164PhoneNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
            print(e164PhoneNumber)
            
            errorMessageLabel.textColor = UIColor.green;
            errorMessageLabel.text = "Valid: \(e164PhoneNumber)"
            
            activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            
            if Storage.authToken != nil, Storage.phoneNumberInE164 ==
            e164PhoneNumber {
                // segue to home for old users
                performSegue(withIdentifier: "LoginToHome", sender: self)
                return
            }
            else {
                // segue to varification for new user
                performSegue(withIdentifier: "SignupToPhoneValidation", sender: self)
            }
        }
        catch {
            print("Generic parser error")
            errorMessageLabel.text = "Please enter valid mobile number"
            activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
        
    }
}

