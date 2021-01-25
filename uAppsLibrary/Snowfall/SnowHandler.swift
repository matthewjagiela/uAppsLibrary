//
//  SnowHandler.swift
//  uTime
//
//  Created by Matthew Jagiela on 12/27/20.
//  Copyright © 2020 Matthew Jagiela. All rights reserved.
//

import SpriteKit

public enum Season: String {
    case spring
    case summer
    case fall
    case winter
}

public class SnowHandler {
    public init() {} 
    func getMonth() -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: Date()); //This is going to return the current month in a 1-12 format...
    }
    public func determineSeason() -> Season { //This is going to use the month to find out the current season.
        let month = getMonth()
        if month >= 3 && month < 6 {
            return .spring
        } else if month >= 6 && month < 9 {
            return .summer
        } else if month >= 9 && month < 12 {
            return .fall
        } else {
            return .winter
        }
        
    }
    
    public func shouldShowSnow() -> Bool {
        return determineSeason() == .winter ? true: false
    }

    public func setupSnowScene(view: SKView, size: CGSize) {
        let snowScene = SnowScene(size: size)
        view.ignoresSiblingOrder = true
        snowScene.scaleMode = .resizeFill
        view.backgroundColor = SKColor.clear
        view.presentScene(snowScene)
    }
}
