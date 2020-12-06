//
//  DirectionalVisibility.swift
//  
//
//  Created by Jonathan Downing on 12/5/20.
//

public struct DirectionalVisibility: Equatable {
    
    public enum Direction {
        case north
        case northEast
        case east
        case southEast
        case south
        case southWest
        case west
        case northWest
    }
    
    public var visibility: Visibility
    public var direction: Direction
    
}
