//
//  AccountDetailViewController.swift
//  Mammon
//
//  Created by Ethan Chiang on 11/2/19.
//  Copyright © 2019 EYC. All rights reserved.
//

import UIKit

class AccountDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountAmountLabel: UILabel!
    @IBOutlet weak var accountActionPopUp: UIView!
    @IBOutlet weak var accountActionPopUpLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var accountsPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var accountToTransfer : String = ""
    var amount : Double = 0.0
    var accountIndex : Int = 0
    var wallet : Wallet = Wallet.init()
    var accountAction : String = ""
    var pickerData: [String] = [String]()
    var prevPickerIndex : Int = 0
    

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accountsPickerView.delegate = self
        self.accountsPickerView.dataSource = self
        self.activityIndicator.hidesWhenStopped = true
        
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        // a tap that end editing(ketboard) in view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))

        // add tap gesture to view
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        //print("Accessed accout \(self.accountIndex)")
        
        self.accountActionPopUp.isHidden = true
        
        Api.user() { response, error in
        
            if let response = response {
                // will parse info from response
                self.wallet = Wallet.init(data: response, ifGenerateAccounts: false)
            }
            
            self.accountNameLabel.text = self.wallet.accounts[self.accountIndex].name
            self.accountAmountLabel.text = "$ \(String(format: "%0.02f", self.wallet.accounts[self.accountIndex].amount))"
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    // MARK: deposit
    @IBAction func depositPressed() {
        self.accountAction = "deposit"
        self.accountActionPopUpLabel.isHidden = false
        self.accountActionPopUpLabel.text = "Enter amount to deposit"
        self.accountActionPopUp.isHidden = false
        self.accountsPickerView.isHidden = true
    }
    
    // MARK: withdraw
    @IBAction func withdrawPressed() {
        self.accountAction = "withdraw"
        self.accountActionPopUpLabel.isHidden = false
        self.accountActionPopUpLabel.text = "Enter amount to withdraw"
        self.accountActionPopUp.isHidden = false
        self.accountsPickerView.isHidden = true
    }
    
    // MARK: transfer
    @IBAction func transferPressed() {
        self.accountAction = "transfer"
        self.accountActionPopUpLabel.isHidden = true
        self.accountActionPopUp.isHidden = false
        
        self.pickerData.removeAll()
        
        for account in self.wallet.accounts {
            if account.name != self.wallet.accounts[self.accountIndex].name {
                self.pickerData.append(account.name)
            }
        }
        
        self.accountsPickerView.reloadAllComponents()
        self.accountsPickerView.isHidden = false
        print(self.prevPickerIndex)
        self.accountToTransfer = pickerData[self.prevPickerIndex]
    }
    
    // MARK: delete
    @IBAction func deletePressed() {
        
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        Api.removeAccount(wallet: self.wallet, removeAccountat: self.accountIndex) { response, error in
                
            print("remove account \(self.accountIndex)")
            
            if let error = error {
                print("Unable to remove account: \(error)")
                return
            }
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            self.performSegue(withIdentifier: "accountDetailToHome", sender: self)
        }
    }
    
    
    // MARK: done
    @IBAction func donePressed() {
        
        // get amount entered
        guard let amountText = self.amountTextField.text
        else {
            print("Failed to unwrap accountActionPopUpLabel.text")
            return
        }
        
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        //print("amountText: \(amountText)")
        
        // convert to Double with 2 decimal places
        self.amount = Double(amountText) ?? 0
        self.amount = Double(round(100*self.amount)/100)
        
        switch self.accountAction {
        case "deposit":
            
            Api.deposit(wallet: self.wallet, toAccountAt: self.accountIndex, amount: self.amount) {
                response, error in
                
                if let error = error{
                    print(error)
                    return
                }
                
                print("deposit: \(self.amount) to account# \(self.accountIndex)")
                
                self.reloadAccount()
            }
            break
        case "withdraw":
            
            if self.amount > self.wallet.accounts[self.accountIndex].amount {
                let alertController = UIAlertController(title: "Balance insufficent", message: "Withdrawing account balance", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                // set withdraw amount to account amount
                self.amount = self.wallet.accounts[self.accountIndex].amount
            }
            
            Api.withdraw(wallet: self.wallet, fromAccountAt: self.accountIndex, amount: self.amount) {
                response, error in
                
                if let error = error {
                    print(error)
                    return
                }
                
                print("withdraw: \(self.amount) from account#: \(self.accountIndex)")
                
                self.reloadAccount()
                //self.hiddePopUP()
            }
            break
        case "transfer":
            
            var transferAccountIndex : Int = 0
            

            if self.amount > self.wallet.accounts[self.accountIndex].amount {
                let alertController = UIAlertController(title: "Balance insufficent", message: "Transfering account balance", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                // set withdraw amount to account amount
                self.amount = self.wallet.accounts[self.accountIndex].amount
            }
            
            for (index, account) in self.wallet.accounts.enumerated() {
                if account.name == self.accountToTransfer {
                    transferAccountIndex = index
                }
            }
            
            Api.transfer(wallet: self.wallet, fromAccountAt: self.accountIndex, toAccountAt: transferAccountIndex, amount: self.amount) {
                response, error in
                
                if let error = error {
                    print(error)
                    return
                }
                
                print("transfer $\(self.amount) from accoutn#\(self.accountIndex) to account#\(transferAccountIndex)")
                
                self.reloadAccount()
            }
            //self.prevPickerIndex = transferAccountIndex
            break
        default:
            print("Unexpected account action")
        }
    }
    
    
    // MARK: other func
    func hiddePopUP() {
        self.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.accountActionPopUp.isHidden = true
        self.amountTextField.text = ""
    }
    
    func reloadAccount() {
        print("reloadAccount")
        Api.user() { response, error in
        
            if let response = response {
                // will parse info from response
                self.wallet = Wallet.init(data: response, ifGenerateAccounts: false)
            }
            self.accountNameLabel.text = self.wallet.accounts[self.accountIndex].name
            self.accountAmountLabel.text = "$ \(String(format: "%0.02f", self.wallet.accounts[self.accountIndex].amount))"
            
            
            print("new balance is \(self.wallet.accounts[self.accountIndex].amount) for account#\(self.accountIndex)")
            
            // notify home view to reload wallet
            NotificationCenter.default.post(name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
            
            self.hiddePopUP()
        }
    }
    
    // MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }
       
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.accountToTransfer = pickerData[row]
        self.prevPickerIndex = row
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
