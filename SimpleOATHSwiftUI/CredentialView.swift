//
//  CredentialView.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-03.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import SwiftUI

struct CredentialView: View {
    
    let credential: Credential
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(credential.otp ?? "*** ***").font(.title)
            Text("\(credential.issuer ?? "") \(credential.account)").font(.headline).foregroundColor(.gray)
        }.padding(10)
    }
}


struct CredentialView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialView(credential: Credential(issuer: "Behemoth", account: "camina.drummer@gmail.com", otp: "123123"))
    }
}
