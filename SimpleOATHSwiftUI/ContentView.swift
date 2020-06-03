//
//  ContentView.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-03.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var credentials = [Credential]()
    var body: some View {
        NavigationView {
            List {
                ForEach(credentials) { credential in
                    CredentialView(credential: credential)
                }
            }
            .navigationBarTitle(Text("Accounts"))
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        var contentView = ContentView()
        contentView.credentials = [Credential(issuer: "Yubico", account: "vir.cotto@gmail.com"),
                                   Credential(issuer: "Yubico", account: "londo.molari@gmail.com"),
                                   Credential(issuer: "Yubico", account: "amos.burton@gmail.com"),
                                   Credential(issuer: "Yubico", account: "camina.drummer@gmail.com"),
                                   Credential(issuer: "Yubico", account: "clarissa.mao@gmail.com"),
                                   Credential(issuer: "Yubico", account: "naomi.nagata@gmail.com")]
        return contentView
    }
}
