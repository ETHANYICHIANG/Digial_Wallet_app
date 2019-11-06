//
//  VarifictionViewController.swift
//  Mammon
//
//  Created by Ethan Chiang on 10/19/19.
//  Copyright © 2019 EYC. All rights reserved.
//

import UIKit
//import Api.swift as Api

class VarificationViewController: UIViewController,PinTexFieldDelegate {
    
    @IBOutlet weak var codeSentToLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var textField1: PinTextField!
    @IBOutlet weak var textField2: PinTextField!
    @IBOutlet weak var textField3: PinTextField!
    @IBOutlet weak var textField4: PinTextField!
    @IBOutlet weak var textField5: PinTextField!
    @IBOutlet weak var textField6: PinTextField!
    
    
    var e164phoneNumber: String = ""
    var OTP = Array(repeating: "", count: 6)
    
    
    @IBAction func resendOTP() {
        // Send Verification Code
        Api.sendVerificationCode(phoneNumber: e164phoneNumber) { response, error in
         // Handle the response and error here
            
            if let error = error {
                print(error.message)
                self.errorMessageLabel.text = error.message
            }
        }
    }
    
    // MARK: PinTextField protocol implementation
    func didPressBackspace(textField : PinTextField) {
        
        switch textField{
        case textField1:
            resetOTP()
            textField1.text = ""
        case textField2:
            textField2.resignFirstResponder()
            textField2.isUserInteractionEnabled = false
             textField1.isUserInteractionEnabled = true
            textField1.text = ""
            resetOTP()
            textField1.becomeFirstResponder()
            break
        case textField3:
            textField3.resignFirstResponder()
            textField3.isUserInteractionEnabled = false
            textField2.isUserInteractionEnabled = true
            textField2.text = ""
            OTP[1] = ""
            OTP[2] = ""
            textField2.becomeFirstResponder()
            break
        case textField4:
            textField4.resignFirstResponder()
            textField4.isUserInteractionEnabled = false
            textField3.isUserInteractionEnabled = true
            textField3.text = ""
            OTP[2] = ""
            OTP[3] = ""
            textField3.becomeFirstResponder()
            break
        case textField5:
            textField5.resignFirstResponder()
            textField5.isUserInteractionEnabled = false
            textField4.isUserInteractionEnabled = true
            textField4.text = ""
            OTP[3] = ""
            OTP[4] = ""
            textField4.becomeFirstResponder()
            break
        case textField6:
            textField6.resignFirstResponder()
            textField6.isUserInteractionEnabled = false
            textField5.isUserInteractionEnabled = true
            textField5.text = ""
            OTP[4] = ""
            OTP[5] = ""
            textField5.becomeFirstResponder()
            break
        default:
            break
        }
        
    }
    // END MARK
    
    // clear testField when editing start
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textField4.delegate = self
        textField5.delegate = self
        textField6.delegate = self
        
        
        textField2.isUserInteractionEnabled = false
        textField3.isUserInteractionEnabled = false
        textField4.isUserInteractionEnabled = false
        textField5.isUserInteractionEnabled = false
        textField6.isUserInteractionEnabled = false
        

        print("received: \(e164phoneNumber)")
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        // Send Verification Code
        Api.sendVerificationCode(phoneNumber: e164phoneNumber) { response, error in
         // Handle the response and error here
            
            if let error = error {
                print(error.message)
                self.errorMessageLabel.text = error.message
            }
        }

        
        // the code should crash if e164phoneNumber was not sent correctly
        codeSentToLabel.text = "Code was sent to \(e164phoneNumber)"
        
        // a tap that end editing(ketboard) in view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        
        // add tap gesture to view
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    @IBAction func textField1Entry() {
      
        guard let textFieldDigit = textField1.text else{
            print("failed to unwrap textfield")
            return
        }
                
        if textFieldDigit.count > 0 {
            OTP[0] = textFieldDigit
            textField1.isUserInteractionEnabled = false
            textField2.isUserInteractionEnabled = true
            textField1.resignFirstResponder()
            textField2.becomeFirstResponder()
            
        }
    }
    
    @IBAction func textField2Entry() {
        guard let textFieldDigit = textField2.text else{
            print("failed to unwrap textfield")
            return
        }
                
        if textFieldDigit.count > 0 {
            OTP[1] = textFieldDigit
            textField2.isUserInteractionEnabled = false
            textField3.isUserInteractionEnabled = true
            textField2.resignFirstResponder()
            textField3.becomeFirstResponder()
        }
    }
    
    @IBAction func textField3Entry() {
        guard let textFieldDigit = textField3.text else{
            print("failed to unwrap textfield")
            return
        }
                
        if textFieldDigit.count > 0 {
            OTP[2] = textFieldDigit
            textField3.isUserInteractionEnabled = false
            textField4.isUserInteractionEnabled = true
            textField3.resignFirstResponder()
            textField4.becomeFirstResponder()
        }
    }
    
    @IBAction func textField4Entry() {
        guard let textFieldDigit = textField4.text else{
            print("failed to unwrap textfield")
            return
        }
                
        if textFieldDigit.count > 0 {
            OTP[3] = textFieldDigit
            textField4.isUserInteractionEnabled = false
            textField5.isUserInteractionEnabled = true
            textField4.resignFirstResponder()
            textField5.becomeFirstResponder()
        }
    }
    
    @IBAction func textField5Entry() {
        guard let textFieldDigit = textField5.text else{
            print("failed to unwrap textfield")
            return
        }
                
        if textFieldDigit.count > 0 {
            OTP[4] = textFieldDigit
            textField5.isUserInteractionEnabled = false
            textField6.isUserInteractionEnabled = true
            textField5.resignFirstResponder()
            textField6.becomeFirstResponder()
        }
    }
    
    @IBAction func textFiled6Entry() {
        
        //var OTPVarified = false
        
        guard let textFieldDigit = textField6.text else{
            print("failed to unwrap textfield")
            return
        }
                
        if textFieldDigit.count > 0 {
            OTP[5] = textFieldDigit
            print("OTP: \(OTP)")
            
            // Varify OTP
            varifyOTP()
        }
    }
    
    func resetOTP() {
        
        for index in 0...OTP.count-1 {
            OTP[index] = ""
        }
           
        // Make return to textField1 and clear all textField
        textField6.resignFirstResponder()
        textField6.isUserInteractionEnabled = false
        textField1.isUserInteractionEnabled = true
        textField1.text = ""
        textField2.text = ""
        textField3.text = ""
        textField4.text = ""
        textField5.text = ""
        textField6.text = ""
        textField1.becomeFirstResponder()
        view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }
       
   func varifyOTP() {
       activityIndicator.startAnimating()
       self.view.isUserInteractionEnabled = false
       
       // Verify Code
        Api.verifyCode(phoneNumber: e164phoneNumber, code: OTP.reduce(""){$0 + $1}) { response, error in
        // Handle the response and error here
           if let error = error {
               print(error.message)
               self.errorMessageLabel.text = error.message
               self.activityIndicator.stopAnimating()
               
               // reset OTP
               self.resetOTP()
               
           } else {
               print("OTP varified")
               
               guard let response = response else {
                   print("Api response failed")
                   return
               }
               
               guard let authToken = response["auth_token"] as? String else {
                   print("failed to unwrap auth_token from Api")
                   return
               }
               
                
               // store auth_token and phone number in Storage
               Storage.authToken = authToken
               Storage.phoneNumberInE164 = self.e164phoneNumber
               
               self.activityIndicator.stopAnimating()
               self.view.isUserInteractionEnabled = true
               self.performSegue(withIdentifier: "PhoneValidationToHome", sender: self)
           }
       }
   }
    
}
