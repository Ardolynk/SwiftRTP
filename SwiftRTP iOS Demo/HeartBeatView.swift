//
//  HeartBeatView.swift
//  iSolo
//
//  Created by Jonathan Wight on 9/21/15.
//  Copyright © 2015 3d Robotics. All rights reserved.
//

import UIKit
import SwiftRTP

@IBDesignable public class HeartbeatView: UIView, CAAnimationDelegate {

    var eventsForHash: [Int: RTPEvent] = [:]
    var maxEvents: Int = 16
    var duration: CFTimeInterval = 5

    public func handle(event: RTPEvent) {

        let hashFraction = CGFloat(fractionForEvent(event))

        if eventsForHash[hash] == nil {
            eventsForHash[hash] = event
        }

        let radius = CGFloat(5)
        let color = colorForEvent(event)
        let newLayer = CAShapeLayer()
        newLayer.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        newLayer.fillColor = color.cgColor
        newLayer.strokeColor = nil

        newLayer.position = CGPoint(
            x: hashFraction * bounds.size.width,
            y: bounds.size.height
            )

        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.toValue = CGPath(ellipseIn: CGRect(x: 0, y: 0, width: 0, height: 0), transform: nil)

        let positionAnimation = CABasicAnimation(keyPath: "position.y")
        positionAnimation.toValue = 0

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [ pathAnimation, positionAnimation ]
        groupAnimation.delegate = self
        groupAnimation.duration = duration
        groupAnimation.setValue(newLayer, forKey: "layer")

        newLayer.add(groupAnimation, forKey: "groupAnimation")
        layer.addSublayer(newLayer)
    }

    public func fractionForEvent(_ event: RTPEvent) -> Double {
        let hash = abs(event.hashValue % maxEvents)
        let hashFraction = Double(hash) / Double(maxEvents)
        return hashFraction
    }

    public func colorForEvent(_ event: RTPEvent) -> UIColor {
        let hashFraction = CGFloat(fractionForEvent(event))
        let color = UIColor(hue: hashFraction, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        return color
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let layer = anim.value(forKey: "layer") as? CALayer else {
            Swift.print("No layer")
            return
        }
        layer.model().removeFromSuperlayer()
    }
}
