# Mammon - a digital wallet ios app

## Author
Ethan Chiang 

## Project Discription
This is the final vresion of a digital wallet ios app for ECS189e @ UC Davis. This version now includes:
* Launch page
* Sign-up page
* OTP validation page
* Home page with account information
* Account detail page with deposit/withdraw/transfer/delete functionality

## Features

### Lanuch View
* Custome logo
* App name

### Sign-up/in View
* Auto-check mobile number length 
* Validation of mobile number with PhoneNumberKit
* e164 format disaply after entering valid phone number
* Error messages display to inform user when phone number is invalid

### OTP Varification View
* 6 OTP text field to enter code
* Resend OTP button
* Auto-check OTP after all 6 digits are entered
* Auto-fill on iphones
* Display of error message when OTP is invalid
* Activity indicator while waiting for api calls, all user interactions are disable 
* Auth_token and e164 phone number are stored on Storage after OTP varified

### Home View
* Inlcudes name of user, account total, list of accounts, logout button
* User name is default to be the phone number
* User can changed their user name (empty user name or pure white spaces will not be accpeted and user name will be default to phone number)
* List of account with name and balance in UITableView

### Account detail page
* DIsplay account name and balance
* "Done" button to go back to home view
* "Deposit" to deposit to account (money comes from no where)
* "Withdraw" to withdraw from account (no real money will comes out)
* "Transfer" to transfer balance between accounts, using UIPikerVIew to select account to transfer to
* "Delete" to delete account (balance goes into water)
