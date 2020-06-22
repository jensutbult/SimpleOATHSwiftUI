//
//  Yubikey.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-18.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import Foundation
import Combine

extension String: Error {}
struct APDU {}
struct Password {}

class Yubikey {
    static let shared = Yubikey()
    let oathService: OATHService
    let fido2Service: FIDO2Service
    let mgmtService = MGMTService()
    var cancellable: Cancellable?
    
    private var session: AnyPublisher<YubiKitManager.Session?, Never>
    private let manager: YubiKitManager
    
    private init() {
        guard let manager = YubiKitManager.shared as? YubiKitManager else { fatalError() }
        self.manager = manager
        self.session = manager.session
        oathService = OATHService(session: session)
        fido2Service = FIDO2Service(session: session)
        
        cancellable = session.sink { session in
            print(session)
        }
    }
}

protocol YubikeyService {
    associatedtype Session
    func session() -> Future<Session, Error>
}

protocol YubikeySession {
    func execute(apdu: APDU) -> Future<Any, Error>
    func close() -> Future<Void, Error>
}

extension YubikeySession {
    func execute(apdu: APDU) -> Future<Any, Error> {
        Future { completion in
            completion(.failure("Not implemented"))
        }
    }
    func close() -> Future<Void, Error> {
        Future { completion in
            completion(.failure("Not implemented"))
        }
    }
}

protocol YubikeyNFCSession: YubikeySession {
}

protocol YubikeyAccessorySession: YubikeySession {
}
