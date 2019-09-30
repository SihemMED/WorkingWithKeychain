//
//  User.swift
//  WorkingWithKeychain
//
//  Created by Sihem Mohamed on 9/25/19.
//  Copyright © 2019 Simo. All rights reserved.
//

import Foundation
struct User {
    var username: String
    var password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
