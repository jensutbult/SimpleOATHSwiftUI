import Combine

class OATHSession: YubikeySession {
    
    private let service: YKFKeyOATHServiceProtocol
    private let refreshCredentials: CurrentValueSubject<Bool, Never>
    private let credentialsDidRefresh: PassthroughSubject<Void, Never>

    init(service:YKFKeyOATHServiceProtocol, refreshCredentials: CurrentValueSubject<Bool, Never>, credentialsDidRefresh: PassthroughSubject<Void, Never>) {
        self.service = service
        self.refreshCredentials = refreshCredentials
        self.credentialsDidRefresh = credentialsDidRefresh
    }
    
    func endSession() -> Future<Void, Error> {
        return Future { promise in
            YubiKitManager.shared.nfcSession.stopIso7816Session()
            promise(.success(()))
        }
    }

    var refreshCancellable: AnyCancellable?
    func refresh() -> Future<Void, Error> {
        Future { promise in
            self.refreshCredentials.send(true)
            self.refreshCancellable = self.credentialsDidRefresh.sink {
                promise(.success(Void()))
            }
        }
    }

    func put(credential: Credential) -> Future<Credential, Error> {
        Future { [service] completion in
            let ykfCredential = YKFOATHCredential(account: credential.account, issuer: credential.issuer!)
            ykfCredential.secret = NSData.ykf_data(withBase32String: "asecretsecret")!
            ykfCredential.type = .TOTP
            
            let request = YKFKeyOATHPutRequest(credential: ykfCredential)!
            service.execute(request) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(credential))
            }
        }
    }
    
    func delete(credential: Credential) -> Future<Void, Error> {
        Future { [service] completion in
            let request = YKFKeyOATHDeleteRequest(credential: YKFOATHCredential(account: credential.account, issuer: credential.issuer!))!
//            let request = YKFKeyOATHDeleteRequest(credential: YKFOATHCredential(account: "no such account", issuer: credential.issuer!))!
            service.execute(request) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(Void()))
            }
        }
    }
    
//    func update(credential: Credential, updated: Credential) -> Future<Credential, Error>
//    func calculate(credential: Credential) -> Future<Credential, Error>
//    func calculateAllCredentials() -> Future<[Credential], Error>
//    func refreshCredentials() -> Future<[Credential], Error>
//    func set(password: Password) -> Future<Void, Error>
//    func validate(password: Password) -> Future<Void, Error>
//    func reset() -> Future<Void, Error>
}

extension YKFOATHCredential {
    convenience init(account: String, issuer: String) {
        self.init()
        self.issuer = issuer
        self.account = account
    }
}
