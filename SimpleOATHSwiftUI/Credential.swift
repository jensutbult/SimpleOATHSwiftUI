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
    let otp: String?
    
    static func testCredentials() -> [Credential] {
        [Credential(issuer: "Behemoth", account: "camina.drummer@gmail.com", otp: "123123"),
         Credential(issuer: "Tachi", account: "amos.burton@gmail.com", otp: "123123"),
         Credential(issuer: "Razorback", account: "clarissa.mao@gmail.com", otp: "123123"),
         Credential(issuer: "Canterbury", account: "naomi.nagata@gmail.com", otp: "123123"),
         Credential(issuer: "ISA Excalibur", account: "vir.cotto@gmail.com", otp: "123123"),
         Credential(issuer: "White Star 1", account: "londo.molari@gmail.com", otp: "123123")]
    }
}
