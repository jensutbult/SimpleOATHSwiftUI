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
        HStack {
            Text(credential.issuer ?? "").font(.headline)
            Spacer()
            Text(credential.account).font(.headline)
            }.padding(10)
    }
}

struct CredentialView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialView(credential: Credential(issuer: "Yubico", account: "jens.utbult@yubico.com"))
    }
}
