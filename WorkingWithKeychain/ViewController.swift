//
//  ViewController.swift
//  WorkingWithKeychain
//
//  Created by Sihem Mohamed on 9/20/19.
//  Copyright © 2019 Simo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var user: User!
    let server = "www.example.com"
    var query : [String: Any] = Dictionary<String, Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if let username = usernameTextField.text , let password = passwordTextField.text, !username.isEmpty && !password.isEmpty {
            do{
                try storeInKeychain(username, password: password)
            }catch let error{
                print("Error storing in keychain : \(error.localizedDescription)")
            }
        }else{
            print("Empty fields")
        }
        
    }
    
    func storeInKeychain(_ username: String, password: String) throws {
        user = User(username: username, password: password)
        let userAccount = user.username
        guard let encodedPassword = user.password.data(using: String.Encoding.utf8) else {
            throw KeychainStoreError.conversionError
        }
        query = [kSecClass as String: kSecClassInternetPassword, kSecAttrAccount as String: userAccount, kSecAttrServer as String: server]
        let queryStatus = SecItemCopyMatching(query as CFDictionary
            , nil)
        switch queryStatus {
        case errSecSuccess:
            showAlert("Item already exists")
        case errSecItemNotFound :
            do{
                try addKeychainItem(encodedPassword)
            }catch let error as NSError{
                print("Error adding item to keychain : \(error)")
            }
        default:
            throw KeychainStoreError.unhandledError(queryStatus)
        }
    }
    
    func addKeychainItem(_ item: Data) throws {
        query[kSecValueData as String] = item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainStoreError.unhandledError(status)
        }
        showAlert("Item added")
    }
    
    func updateKeychainItem(_ item: Data) throws {
        var queryToUpdate : [String: Any] = Dictionary<String,Any>()
        queryToUpdate[kSecValueData as String] = item
        let status = SecItemUpdate(query as CFDictionary, queryToUpdate as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainStoreError.unhandledError(status)
        }
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Keychain Item", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.usernameTextField.text = ""
            self.passwordTextField.text = ""
        }
        alert.addAction(okAction)
        self.present(alert, animated: false, completion: nil)
    }


}

