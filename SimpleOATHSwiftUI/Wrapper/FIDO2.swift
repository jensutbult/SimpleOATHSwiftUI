//
//  FIDO2.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-18.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import Foundation
import Combine

struct FIDO2Service: YubikeyService {
    typealias Session = FIDO2Session
    
    func session() -> Future<FIDO2Session, Error> {
        Future<FIDO2Session, Error> { completion in
            let session: FIDO2Session = Bool.random() ? NFCFIDO2Session() : AccessoryFIDO2Session()
            completion(.success(session))
        }
    }
    
    private let yubikeySession: AnyPublisher<YubiKitManager.Session?, Never>
    
    init(session: AnyPublisher<YubiKitManager.Session?, Never>) {
        self.yubikeySession = session
    }
}

protocol FIDO2Session {
}

struct NFCFIDO2Session: FIDO2Session, YubikeyNFCSession {
}

struct AccessoryFIDO2Session: FIDO2Session, YubikeyAccessorySession {
}
