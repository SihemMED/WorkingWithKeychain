//
//  KeychainError.swift
//  WorkingWithKeychain
//
//  Created by Sofrecom2 on 9/25/19.
//  Copyright © 2019 Simo. All rights reserved.
//

import Foundation
enum KeychainStoreError : Error{
    case noPassword
    case unexpectedData
    case duplicateItemError
    case unhandledError(_ status: OSStatus)
    case conversionError
}
