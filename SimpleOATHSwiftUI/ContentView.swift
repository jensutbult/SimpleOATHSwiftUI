//
//  ContentView.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-03.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var yubiKit: YubiKitWrapper
    
    var body: some View {
        NavigationView {
            List {
                ForEach(yubiKit.credentials) { credential in
                    CredentialView(credential: credential)
                }
            }
            .navigationBarTitle(Text("Accounts"))
            .navigationBarItems(trailing:
                Button(action: { self.yubiKit.refreshList() } ) { Text("Scan NFC") }
            )
        }.alert(isPresented: yubiKit.isPresentingAlert) {
            Alert(title: Text(yubiKit.activeError?.localizedDescription ?? "Unknown Error"))
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let previewYubiKit = YubiKitWrapper()
        previewYubiKit.credentials = Credential.testCredentials()
        return ContentView(yubiKit: previewYubiKit)
    }
}
