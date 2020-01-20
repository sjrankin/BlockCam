//
//  SCNNode2.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Slightly overridden `SCNNode` class that contains logical coordinates for reuse.
class SCNNode2: SCNNode
{
    /// Initializer.
    override init()
    {
        super.init()
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    init(geometry: SCNGeometry)
    {
        super.init()
        self.geometry = geometry
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Holds the logical X coordinate.
    private var _LogicalX: Int = 0
    /// Get or set the logical X coordinate.
    public var LogicalX: Int
    {
        get
        {
            return _LogicalX
        }
        set
        {
            _LogicalX = newValue
        }
    }
    
    /// Holds the logical Y coordinate.
    private var _LogicalY: Int = 0
    /// Get or set the logical Y coordinate.
    public var LogicalY: Int
    {
        get
        {
            return _LogicalY
        }
        set
        {
            _LogicalY = newValue
        }
    }
    
    /// Holds the logical Z coordinate.
    private var _LogicalZ: Int = 0
    /// Get or set the logical Z coordinate.
    public var LogicalZ: Int
    {
        get
        {
            return _LogicalZ
        }
        set
        {
            _LogicalZ = newValue
        }
    }
    
    /// Holds a value that can be interpreted as an angle.
    private var _Angle: Double = 0.0
    /// Get or set a value that can be used for angles.
    public var Angle: Double
    {
        get
        {
            return _Angle
        }
        set
        {
            _Angle = newValue
        }
    }
}
