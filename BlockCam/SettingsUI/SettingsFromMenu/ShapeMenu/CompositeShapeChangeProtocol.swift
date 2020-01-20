//
//  CompositeShapeChangeProtocol.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol for the communication of shape changes.
protocol CompositeShapeChangeProtocol: class
{
    /// Notify the delegate of a changed shape.
    /// - Parameter At: The index of the changed shape.
    /// - Parameter NewShape: The name of the new shape.
    func ShapeChanged(At Index: Int, NewShape: String)
}
