//
//  Credential.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-03.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import Foundation

struct Credential: Identifiable {
    let id = UUID()
    let issuer: String?
    let account: String
}
