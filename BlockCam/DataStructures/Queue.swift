//
//  Queue.swift
//  BlockCam
//  Adapted from Fouris.
//
//  Created by Stuart Rankin on 1/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements a simple generic queue.
class Queue<T>
{
    /// Initializer.
    init()
    {
        Q = [T]()
    }
    
    /// Initializer.
    /// - Parameter Other: The other queue to use to populate this instance.
    init(_ Other: Queue<T>)
    {
        Q = [T]()
        let OtherItems = Other.AsArray()
        for SomeItem in OtherItems
        {
            Enqueue(SomeItem)
        }
    }
    
    /// Holds the queue's data.
    private var Q: [T]? = nil
    
    /// Clear the contents of the queue.
    public func Clear()
    {
        Q?.removeAll()
    }
    
    /// Returns the number of items in the queue.
    public var Count: Int
    {
        get
        {
            return Q!.count
        }
    }
    
    /// Returns true if the queue is empty, false if not.
    public var IsEmpty: Bool
    {
        get
        {
            return Q!.count == 0
        }
    }
    
    /// Enqueue the passed item.
    public func Enqueue(_ Item: T)
    {
        Q?.append(Item)
    }
    
    /// Dequeue the oldest item in the queue. Nil returned if the queue is empty.
    public func Dequeue() -> T?
    {
        if Q!.count < 1
        {
            return nil
        }
        let First = Q?.first
        Q?.removeFirst()
        return First
    }
    
    /// Peek at the next item to be dequeued but don't remove it from the queue. Nil returned if
    /// the queue is emtpy.
    public func DequeuePeek() -> T?
    {
        if Q!.count < 1
        {
            return nil
        }
        return Q?.first
    }
    
    /// Read the queue at the specified index. Nil return if the queue is empty or the value of `Index` is
    /// out of bounds.
    subscript(Index: Int) -> T?
    {
        get
        {
            if Count < 1
            {
                return nil
            }
            if Index < 0
            {
                return nil
            }
            if Index > Count - 1
            {
                return nil
            }
            return Q?[Index]
        }
    }
    
    /// Return the contents of the queue as an array.
    ///
    /// - Returns: Contents of the queue as an array.
    public func AsArray() -> [T]
    {
        var Results = [T]()
        for SomeT in Q!
        {
            Results.append(SomeT)
        }
        return Results
    }
}
