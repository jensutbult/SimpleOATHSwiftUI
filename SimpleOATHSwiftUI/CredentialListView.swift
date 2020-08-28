//
//  ContentView.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-03.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import SwiftUI
import Combine

struct CredentialListView: View {
    @ObservedObject var oathViewModel: OATHViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(oathViewModel.credentials) { credential in
                    CredentialView(credential: credential)
                }.onDelete(perform: delete)
            }
            .navigationBarTitle(Text("Accounts"))
            .navigationBarItems(leading: Button(action: { self.addCredential() } ) { Text("Add credential") },
                                trailing: Button(action: { self.oathViewModel.refresh() } ) { Text("Refresh") }
            )
        }.alert(isPresented: oathViewModel.isPresentingAlert) {
            Alert(title: Text(oathViewModel.activeError?.localizedDescription ?? "Unknown Error"))
        }
    }
    
    func delete(at offsets: IndexSet) {
        let credentialsToDelete = offsets.map { oathViewModel.credentials[$0] }
        guard let credential = credentialsToDelete.first else { return }
        oathViewModel.delete(credential: credential)
    }
    
    func addCredential() {
        let randomNumber = arc4random() % 100
        let credential = Credential(issuer: "Yubico", account: "jens.utbult+\(randomNumber)@yubico.com", otp: nil)
        oathViewModel.putCredential(credential)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let previewViewModel = OATHViewModel(service: Yubikey.shared.oathService)
        previewViewModel.credentials = Credential.testCredentials()
        return CredentialListView(oathViewModel: previewViewModel)
    }
}
