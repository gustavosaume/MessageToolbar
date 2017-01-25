//
//  CoreExtensions.swift
//  MessageToolbar
//
//  Created by Gustavo Saume on 1/21/17.
//  Copyright © 2017 FieldLens. All rights reserved.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return max(min(self, limits.upperBound), limits.lowerBound)
    }
}
