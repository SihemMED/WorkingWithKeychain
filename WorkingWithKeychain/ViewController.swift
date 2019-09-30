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
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var existingAccountLabel: UILabel!
    
    var userToDelete: User!
    let server = "www.simo.com"
    var query : [String: Any] = Dictionary<String, Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if let username = usernameTextField.text , let password = passwordTextField.text, !username.isEmpty && !password.isEmpty {
            do{
                let user = User(username: username, password: password)
                try storeInKeychain(user)
            }catch let error{
                print("Error storing in keychain : \(error.localizedDescription)")
            }
        }else{
            showAlert("all fields are required ", completion: nil)
        }
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        if let user = userToDelete {
            do {
                try deleteKeychainItem(user)
            } catch let error {
                print("Error deleting item from keychain : \(error)")
            }
        }
    }
    
    func storeInKeychain(_ user: User) throws {
        let userAccount = user.username
        guard let encodedPassword = user.password.data(using: String.Encoding.utf8) else {
            throw KeychainStoreError.conversionError
        }
        query = [kSecClass as String: kSecClassInternetPassword, kSecAttrAccount as String: userAccount, kSecAttrServer as String: server]
        let queryStatus = SecItemCopyMatching(query as CFDictionary
            , nil)
        switch queryStatus {
        case errSecSuccess:
            showAlert("Item already exists", completion: nil)
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
        showAlert("Item added") { (action) in
            self.usernameTextField.text = ""
            self.passwordTextField.text = ""
        }
    }
    
    func updateKeychainItem(_ item: Data) throws {
        var queryToUpdate : [String: Any] = Dictionary<String,Any>()
        queryToUpdate[kSecValueData as String] = item
        let status = SecItemUpdate(query as CFDictionary, queryToUpdate as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainStoreError.unhandledError(status)
        }
    }
    
    func showAlert(_ message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "Keychain", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: completion)
        alert.addAction(okAction)
        self.present(alert, animated: false, completion: nil)
    }

    func searchCredentialsFromKeychain(_ item: String) throws -> User {
        var searchQuery : [String: Any] = Dictionary<String,Any>()
        searchQuery = [kSecClass as String: kSecClassInternetPassword, kSecAttrServer as String: server, kSecMatchItemList as String: kSecMatchLimitAll, kSecReturnAttributes as String : true, kSecReturnData as String: true, kSecAttrAccount as String : item]
        var result: CFTypeRef?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(searchQuery as CFDictionary, UnsafeMutablePointer($0))
        }
        
        switch status {
        case errSecSuccess:
            guard let items = result as? [String: Any], let passwordData = items[kSecValueData as String] as? Data, let password = String(data: passwordData, encoding: String.Encoding.utf8) else{
                throw KeychainStoreError.unexpectedData
            }
            return User(username: item, password: password)
        case errSecItemNotFound:
            showAlert("Item not found") { (action) in
                self.existingAccountLabel.text = ""
                self.userToDelete = nil
            }
            throw KeychainStoreError.unhandledError(status)
        default:
            throw KeychainStoreError.unhandledError(status)
        }
    }
    
    func deleteKeychainItem(_ user: User) throws {
        guard let passwordData = user.password.data(using: String.Encoding.utf8) else{
            throw KeychainStoreError.conversionError
        }
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server, kSecAttrAccount as String: user.username, kSecValueData as String: passwordData]
        let status = SecItemDelete(query as CFDictionary)
        switch status {
        case errSecSuccess:
            showAlert("Item deleted") { (action) in
                self.existingAccountLabel.text = ""
                self.searchTextField.text = ""
                self.userToDelete = nil
            }
        case errSecItemNotFound:
            showAlert("Item not found", completion: nil)
        default:
            throw KeychainStoreError.unhandledError(status)
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        do {
            let user = try searchCredentialsFromKeychain(textField.text!)
            existingAccountLabel.isHidden = false
            existingAccountLabel.text = "Username : \(user.username) \nPassword: \(user.password)"
            userToDelete = user
            print( "Username : \(user.username) \nPassword: \(user.password)")
        } catch let error {
            print("Search failed : \(error)")
        }
        return true
    }
}

