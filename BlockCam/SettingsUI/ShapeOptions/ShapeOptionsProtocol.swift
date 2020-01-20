//
//  ShapeOptionsProtocol.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol to send shapes.
protocol ShapeOptionsProtocol: class
{
    /// Return the shape.
    func GetShape() -> NodeShapes
}
