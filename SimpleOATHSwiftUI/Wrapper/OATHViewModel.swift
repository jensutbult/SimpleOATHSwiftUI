//
//  OATHViewModel.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-24.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class OATHViewModel: ObservableObject {
    
    @Published var credentials = [Credential]()
    @Published private(set) var activeError: Error?
    private var oathService = Yubikey.shared.oathService

    var cancellable: AnyCancellable?
    init() {
        cancellable = oathService.credentials.sink { [weak self] in
            self?.credentials = $0
        }
    }
    
    var isPresentingAlert: Binding<Bool> {
        return Binding<Bool>(get: {
            return self.activeError != nil
        }, set: { newValue in
            guard !newValue else { return }
            self.activeError = nil
        })
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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.activeError = error
                }
            }, receiveValue: { _ in })
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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.activeError = error
                }
            }, receiveValue: { _ in })
    }
    
    var deleteCancellable: AnyCancellable?
    func deleteCredentials(_ credentials: [Credential]) {
        deleteCancellable = oathService
            .session()
            .flatMap { session in
                session.delete(credential: credentials.first!).map { _ in session }
            }
            .flatMap { session -> Future<Void, Error> in
                DispatchQueue.main.async {
                    self.credentials.removeAll { $0.id == credentials.first?.id }
                }
                return session.endSession()
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.activeError = error
                }
            }, receiveValue: { _ in })
    }
}
