//
//  OATH.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-18.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import Foundation
import Combine

class OATHService: YubikeyService {

    var credentials: AnyPublisher<[Credential], Never>

    private let refreshCredentials = CurrentValueSubject<Bool, Never>(true)
    private let credentialsDidRefresh = PassthroughSubject<Void, Never>()
    private let yubikeySession: AnyPublisher<YubiKitManager.Session?, Never>
    
    private var didChangeCancellable: AnyCancellable?
    private var sessionCancellable: AnyCancellable?
    
    func session() -> Future<OATHSession, Error> {
        Future { [self, refreshCredentials, credentialsDidRefresh] completion in
            self.sessionCancellable = self.yubikeySession.map { session -> OATHSession? in
                guard let session = session, let service = session.oathService else {
                    refreshCredentials.send(false)
                    YubiKitManager.shared.nfcSession.startIso7816Session()
                    return nil
                }
                return OATHSession(service: service, refreshCredentials: refreshCredentials, credentialsDidRefresh: credentialsDidRefresh)
            }
            .compactMap { $0 }
            .prefix(1)
            .sink { session in
                completion(.success(session))
            }
        }
    }
    
    init(session sessionPublisher: AnyPublisher<YubiKitManager.Session?, Never>) {
        self.yubikeySession = sessionPublisher
        
        credentials = yubikeySession
            .combineLatest(refreshCredentials)
            .filter { $0.1 }
            .map { $0.0 }
            .flatMap { session -> AnyPublisher<(YubiKitManager.Session?, [Credential]), Never> in
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
            .receive(on: RunLoop.main)
            .shareReplay(1)
            .eraseToAnyPublisher()
        
        didChangeCancellable = credentials.map { _ in Void() }.sink { [credentialsDidRefresh] in credentialsDidRefresh.send() }
    }
}

