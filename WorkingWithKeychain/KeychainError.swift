//
//  KeychainError.swift
//  WorkingWithKeychain
//
//  Created by Sihem Mohamed on 9/25/19.
//  Copyright © 2019 Simo. All rights reserved.
//

import Foundation
enum KeychainStoreError : Error{
    case unexpectedData
    case unhandledError(_ status: OSStatus)
    case conversionError
}
