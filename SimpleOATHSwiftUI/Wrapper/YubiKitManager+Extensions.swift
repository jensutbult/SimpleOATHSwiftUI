//
//  YubiKitManager+Extensions.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-18.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import Foundation
import Combine

extension YubiKitManager {
    enum Session: Equatable {
        case NFC(YKFNFCSession)
        case Accessory(YKFAccessorySession)
        
        var oathService: YKFKeyOATHServiceProtocol? {
            switch self {
            case .NFC(let service):
                return service.oathService
            case .Accessory(let service):
                return service.oathService
            }
        }
    }
    

    
}

extension YubiKitManager {
    var session: AnyPublisher<YubiKitManager.Session?, Never> {
        guard let nfcSession = YubiKitManager.shared.nfcSession as? YKFNFCSession else { fatalError() }
        guard let accessorySession = YubiKitManager.shared.accessorySession as? YKFAccessorySession else { fatalError() }
        
        let nfc = nfcSession.publisher(for: \.iso7816SessionState).map { state -> YubiKitManager.Session? in
            if state == .open {
                return Session.NFC(nfcSession)
            } else {
                return nil
            }
            }.removeDuplicates()
        
        let accessory = accessorySession.publisher(for: \.sessionState).map { state -> YubiKitManager.Session? in
            if state == .open {
                return Session.Accessory(accessorySession)
            } else {
                return nil
            }
            }.removeDuplicates()
        if YubiKitDeviceCapabilities.supportsMFIAccessoryKey {
            accessorySession.startSession()
        }
        
        return nfc.merge(with: accessory).shareReplay(1).eraseToAnyPublisher()
    }
}
