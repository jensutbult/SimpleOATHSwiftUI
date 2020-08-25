//
//  Future+Bag.swift
//  SimpleOATHSwiftUI
//
//  Created by Jens Utbult on 2020-08-21.
//  Copyright © 2020 Jens Utbult. All rights reserved.
//

//import Foundation
/*
import Combine

final public class BaggedFuture<Output, Failure> : Publisher where Failure : Error {
    
    var wrappedFuture: Future<Output, Failure>

    /// A type that represents a closure to invoke in the future, when an element or error is available.
    ///
    /// The promise closure receives one parameter: a `Result` that contains either a single element published by a ``Future``, or an error.
    public typealias Promise = (Result<Output, Failure>) -> Void

    /// Creates a publisher that invokes a promise closure when the publisher emits an element.
    ///
    /// - Parameter attemptToFulfill: A ``Future/Promise`` that the publisher invokes when the publisher emits an element or terminates with an error.
    public init(_ attemptToFulfill: @escaping (@escaping BaggedFuture<Output, Failure>.Promise) -> AnyCancellable) {
        
        
    }

    /// Attaches the specified subscriber to this publisher.
    ///
    /// Implementations of ``Publisher`` must implement this method.
    ///
    /// The provided implementation of ``Publisher/subscribe(_:)-4u8kn``calls this method.
    ///
    /// - Parameter subscriber: The subscriber to attach to this ``Publisher``, after which it can receive values.
    final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        
        
    }
}
*/
