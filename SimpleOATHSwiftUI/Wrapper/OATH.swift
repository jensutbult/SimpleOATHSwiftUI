//
//  OATH.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-18.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import Foundation
import Combine

struct OATHService: YubikeyService {
    var credentials: CurrentValueSubject<[Credential], Never> = CurrentValueSubject([])
    var errors: CurrentValueSubject<Error?, Never> = CurrentValueSubject(nil)
    func session() -> Future<OATHSession, Error> {
        Future { completion in
            let session: OATHSession = Bool.random() ? NFCOATHSession() : AccessoryOATHSession()
            completion(.success(session))
        }
    }
    
    private let yubikeySession: AnyPublisher<YubiKitManager.Session?, Never>
    
    init(session: AnyPublisher<YubiKitManager.Session?, Never>) {
        self.yubikeySession = session
    }
}

protocol OATHSession: YubikeySession {
    func list() -> Future<[Credential], Error>
//    func put(credential: Credential) -> Future<Credential, Error>
//    func update(credential: Credential, updated: Credential) -> Future<Credential, Error>
//    func delete(credential: Credential) -> Future<Void, Error>
//    func calculate(credential: Credential) -> Future<Credential, Error>
//    func calculateAllCredentials() -> Future<[Credential], Error>
//    func refreshCredentials() -> Future<[Credential], Error>
//    func set(password: Password) -> Future<Void, Error>
//    func validate(password: Password) -> Future<Void, Error>
//    func reset() -> Future<Void, Error>
}

struct NFCOATHSession: OATHSession {
    func list() -> Future<[Credential], Error> {
        Future { completion in
            completion(.success([]))
        }
    }
}

struct AccessoryOATHSession: OATHSession {
    func list() -> Future<[Credential], Error> {
        Future { completion in
            completion(.success([]))
        }
    }
}
