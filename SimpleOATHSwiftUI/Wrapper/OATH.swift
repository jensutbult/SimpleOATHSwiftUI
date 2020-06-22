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
    var credentials: AnyPublisher<[Credential], Never>
    var errors: CurrentValueSubject<Error?, Never> = CurrentValueSubject(nil)
    func session() -> Future<OATHSession, Error> {
        Future { completion in
            let session: OATHSession = Bool.random() ? NFCOATHSession() : AccessoryOATHSession()
            completion(.success(session))
        }
    }
    
    private let yubikeySession: AnyPublisher<YubiKitManager.Session?, Never>
    
    init(session sessionPublisher: AnyPublisher<YubiKitManager.Session?, Never>) {
        self.yubikeySession = sessionPublisher
        
        credentials = yubikeySession.flatMap { session -> AnyPublisher<(YubiKitManager.Session?, [Credential]), Never> in
            guard let session = session else { return Just((nil, [Credential]())).eraseToAnyPublisher() }
            let service: YKFKeyOATHServiceProtocol
            switch session {
            case .NFC(let oathSession):
                service = oathSession.oathService!
            case .Accessory(let accessorySession):
                service = accessorySession.oathService!
            }
            
            return Future<(YubiKitManager.Session?, [Credential]), Never> { completion in
                let request = YKFKeyOATHCalculateAllRequest(timestamp: Date().addingTimeInterval(10))!
                service.execute(request) { (response, error) in
                    guard let response = response else {
                        completion(.success((nil, [Credential]())))
                        return
                    }
                    guard let result = response.credentials as? [YKFOATHCredentialCalculateResult] else { fatalError() }
                    let credentials = result.map { Credential(issuer: $0.issuer, account: $0.account, otp: $0.otp) }
                    completion(.success((session, credentials)))
                    return
                }
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
        .scan((nil, [Credential]())) { previous, next -> (YubiKitManager.Session?, [Credential]) in
            // if previous session is nfc and next is nil return previous credentials
            if let session = previous.0, next.0 == nil {
                switch session {
                case .NFC(_):
                    return (nil, previous.1)
                case .Accessory(_):
                    return (nil, next.1)
                }
            } else {
                return next
            }
        }
        .map { $0.1 }
        .eraseToAnyPublisher()
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
