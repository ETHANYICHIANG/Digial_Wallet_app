//
//  HomeViewController.swift
//  Mammon
//
//  Created by Ethan Chiang on 10/19/19.
//  Copyright © 2019 EYC. All rights reserved.
//

import UIKit



class HomeViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var accountTotalLabel: UILabel!
    @IBOutlet weak var accountsTabelView: UITableView!
    @IBOutlet weak var newAccountNameTextField: UITextField!
    
    @IBOutlet weak var addAccountPopUp: UIView!
    
    var phoneNumber : String = ""
    var wallet : Wallet = Wallet.init()
    var currentIndexPath: IndexPath? = nil
    
    @objc func disconnectPaxiSocket(_ notification: Notification) {
        self.reloadWallet()
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // recieving notification to reload wallet
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPaxiSocket(_:)), name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
        
        self.accountsTabelView.dataSource = self
        self.accountsTabelView.delegate = self
        self.userNameTextField.delegate = self
        self.newAccountNameTextField.delegate = self
        self.activityIndicator.hidesWhenStopped = true
        self.addAccountPopUp.isHidden = true;
        
        // a tap that end editing(ketboard) in view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        
        // add tap gesture to view
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.reloadWallet()
    }
    
    // Dismiss keyboard when 'return' is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    // MARK: userNameChanged
    @IBAction func userNameChanged() {
        print("user name changed to \(userNameTextField.text!)")
        
        if let userName = userNameTextField.text {
            
            self.view.isUserInteractionEnabled = false
            self.activityIndicator.startAnimating()
            
            // Only allow user to change name to non-empty
            if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                Api.setName(name: userName) { response, error in
                    
                    if let error = error {
                        print("Unable to set user name: \(error.message)")
                    }
                }
            } else {
                Api.setName(name: phoneNumber) { response, error in
                    
                    if let error = error {
                        print("Unable to set user name: \(error.message)")
                    }
                }
                
                self.userNameTextField.text = self.phoneNumber
            }
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    // MARK: tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(self.wallet.accounts.count)
        return self.wallet.accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "account") ?? UITableViewCell(style: .default, reuseIdentifier: "acount")
        let accountAmount = String(format: "%0.02f", self.wallet.accounts[indexPath.row].amount)
        let accountName = self.wallet.accounts[indexPath.row].name
        cell.textLabel?.text = "\(accountName) : $\(accountAmount)"
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.accountsTabelView.deselectRow(at: indexPath, animated: true)
        currentIndexPath = indexPath
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "homeToAccountDetail", sender: self)
    }
    
    // MARK: segue prepare
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // get a reference to the second view controller
        if let accountDetailVC = segue.destination as? AccountDetailViewController {

            // want to break if can't find path index
            let accountIndex = self.currentIndexPath!.row

            //print("In segue: acount # \(self.wallet.accounts.count)")
            
            // set a variable in the second view controller with the data to pass
            //accountDetailVC.accountName = self.wallet.accounts[accountIndex].name
            //accountDetailVC.accountAmount = self.wallet.accounts[accountIndex].amount
            accountDetailVC.accountIndex = accountIndex
        }
    }
    
    // MARK: reload wallet func
    // reload table view data
    func reloadWallet() {
        
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        Api.user() {
        response, error in
            
            if let error = error {
                print("API.user() failed: \(error)")
                return
            }
            
            if let response = response {
                // will parse info from response
                self.wallet = Wallet.init(data: response, ifGenerateAccounts: false)
                //print(self.wallet.accounts.count)
                // Display user name
                if let name = self.wallet.userName {
                   if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                       self.userNameTextField.text = name
                   } else {
                       self.userNameTextField.text = self.wallet.phoneNumber
                   }
                }
                
                

                // display accoumt total
                self.accountTotalLabel.text = "Account Total: $\(String(format: "%0.02f", self.wallet.totalAmount))"
                self.accountsTabelView.reloadData()
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        }
    }

    // MARK: add new accout
    @IBAction func addNewAccountButtonPress() {
        self.addAccountPopUp.isHidden = false;
        self.newAccountNameTextField.text = ""
        
        // find largest account index
        var index = 0
        
        for account in self.wallet.accounts {
            if account.name.hasPrefix("Account") {
                
                if let newIndex = Int(String(account.name.last!)) {
                    if index < newIndex{
                        index = newIndex
                    }
                }
            }
        }
        
        // new account index will be one larger
        index += 1
        
        self.newAccountNameTextField.placeholder = "Account \(index)"
    }
    
    @IBAction func addAccountDonePress() {
        self.addAccountPopUp.isHidden = true
        
        guard let newAccountNameToAdd = self.newAccountNameTextField.text else {
            print("Unable to unwrap new account name")
            return
        }
        
        for account in self.wallet.accounts {
            if account.name == newAccountNameToAdd || account.name == self.newAccountNameTextField.placeholder! {
                let alertController = UIAlertController(title: "Failed to create account", message: "Please enter unique account name", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                return 
            }
        }
        
        if !newAccountNameToAdd.trimmingCharacters(in: .whitespaces).isEmpty {
            // custom account name
            //print("Create custom accout \(newAccountNameToAdd)")
            
            Api.addNewAccount(wallet: self.wallet, newAccountName: newAccountNameToAdd) {
                response, error in
                
                if let error = error {
                    print("Unable to add new accout: \(error)")
                    return
                }
                self.reloadWallet()
            }
        } else {
            // force unwrap b/c the placeholder should always has something
            Api.addNewAccount(wallet: self.wallet, newAccountName: self.newAccountNameTextField.placeholder!) {
                response, error in
                
                if let error = error {
                    print("Unable to add new accout: \(error)")
                    return
                }
                self.reloadWallet()
            }
        }
    }
}


