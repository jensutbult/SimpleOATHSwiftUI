//
//  MGMT.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-06-18.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

import Foundation
import Combine

struct MGMTService: YubikeyService {
    typealias Session = MGMTSession
    
    func session() -> Future<MGMTSession, Error> {
        Future<MGMTSession, Error> { completion in
            let session: MGMTSession = Bool.random() ? NFCMGMTSession() : AccessoryMGMTSession()
            completion(.success(session))
        }
    }
}

protocol MGMTSession {
}

struct NFCMGMTSession: MGMTSession, YubikeyNFCSession {
}

struct AccessoryMGMTSession: MGMTSession, YubikeyAccessorySession {
}
