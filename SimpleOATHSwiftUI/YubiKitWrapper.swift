//
//  YubiKitWrapper.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-04.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import Combine
import SwiftUI

extension String: Error {}

class YubiKitWrapper: ObservableObject {
    
    @Published var credentials = [Credential]()
    @Published private(set) var activeError: Error?
    var isPresentingAlert: Binding<Bool> {
        return Binding<Bool>(get: {
            return self.activeError != nil
        }, set: { newValue in
            guard !newValue else { return }
            self.activeError = nil
        })
    }

    private var sessionObserver: NSKeyValueObservation? = nil

    init() {
        // Can't do key value observation on the protocol so we have to cast it to its concrete implementation
        guard let session = YubiKitManager.shared.nfcSession as? YKFNFCSession else { return }
        
        // Observe changes to the nfc session
        sessionObserver = session.observe(\.iso7816SessionState) { [weak self] session, change in
            // If session state is open unwrap the YKFKeyOATHServiceProtocol
            if session.iso7816SessionState == .open, let service = session.oathService {
                let request = YKFKeyOATHCalculateAllRequest(timestamp: Date().addingTimeInterval(10))
                service.execute(request!) { [weak self] (response, error) in
                    defer { YubiKitManager.shared.nfcSession.stopIso7816Session() }
                    guard let response = response else {
                        DispatchQueue.main.async {
                            self?.credentials.removeAll()
                            self?.activeError = error ?? "No result and no error!"
                        }
                        return
                    }
                    guard let credentials = response.credentials as? [YKFOATHCredentialCalculateResult] else { fatalError() }
                    DispatchQueue.main.async {
                        self?.credentials = credentials.map {
                            Credential(issuer: $0.issuer, account: $0.account, otp: $0.otp)
                        }
                    }
                }
            }
        }
    }
    
    func refreshList() {
        YubiKitManager.shared.nfcSession.startIso7816Session()
    }
}
