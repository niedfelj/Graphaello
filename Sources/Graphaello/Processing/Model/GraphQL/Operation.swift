//
//  Operation.swift
//  
//
//  Created by Mathias Quintero on 1/15/20.
//

import Foundation
import SwiftSyntax

enum Operation: Equatable {
    case flatten
    case compactMap
    case nonNull
    case withDefault(ExprSyntaxProtocol)

    static func == (lhs: Operation, rhs: Operation) -> Bool {
        switch (lhs, rhs) {
        case (.flatten, .flatten):
            return true
        case (.compactMap, .compactMap):
            return true
        case (.nonNull, .nonNull):
            return true
        case (.withDefault(let lhs), .withDefault(let rhs)):
            return lhs.description == rhs.description
        default:
            return false
        }
    }
}
