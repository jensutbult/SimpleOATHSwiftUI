import Foundation
import Combine
import SwiftUI

class OATHViewModel: ObservableObject {
    
    @Published var credentials = [Credential]()
    private var oathService: OATHService

    var serviceCancellable: AnyCancellable?
    init(service: OATHService) {
        self.oathService = service
        serviceCancellable = oathService.credentials.sink { [weak self] in
            self?.credentials = $0
        }
    }
    
    var refreshCancellable: AnyCancellable?
    func refresh() {
        refreshCancellable = oathService.session()
            .flatMap { session in
                session.refresh().map { session }
            }
            .flatMap { session in
                session.endSession()
            }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.activeError = error
                    }
                },
                receiveValue: { _ in }
            )
    }
    
    var putCancellable: AnyCancellable?
    func putCredential(_ credential: Credential) {
        putCancellable = oathService
            .session()
            .flatMap { session in
                session.put(credential: credential).map { _ in session }
            }
            .flatMap { session in
                session.refresh().map { session }
            }
            .flatMap { session in
                session.endSession()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.activeError = error
                    }
                },
                receiveValue: { _ in }
            )
    }
    
    var deleteCancellable: AnyCancellable?
    func delete(credential: Credential) {
        deleteCancellable = oathService
            .session()
            .flatMap { session in
                session.delete(credential: credential).map { _ in session }
            }
            .flatMap { session -> Future<Void, Error> in
                DispatchQueue.main.async {
                    self.credentials.removeAll { $0.id == credential.id }
                }
                return session.endSession()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.activeError = error
                    }
                },
                receiveValue: { _ in }
            )
    }
    
    @Published private(set) var activeError: Error? {
        didSet {
            guard activeError != nil else { return }
            _ = oathService.session()
                .flatMap { session in session.endSession() }
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        }
    }
    
    var isPresentingAlert: Binding<Bool> {
        return Binding<Bool>(
            get: {
                return self.activeError != nil
            },
            set: { presentAlert in
                guard !presentAlert else { return }
                self.activeError = nil
            }
        )
    }
}
