//
//  ConfettiLayer.swift
//  TestConfetti
//
//  Created by Sebastián Fernández on 18-07-20.
//  Copyright © 2020 Sebastián Fernández. All rights reserved.
//

import UIKit

class ConfettiLayer{
    
    //actual view where the layer is shown
    var view:UIView
    
    var confettiTypes: [ConfettiType] = {
        let confettiColors = [
            (r:149,g:58,b:255), (r:255,g:195,b:41), (r:255,g:101,b:26),
            (r:123,g:92,b:255), (r:76,g:126,b:255), (r:71,g:192,b:255),
            (r:255,g:47,b:39), (r:255,g:91,b:134), (r:233,g:122,b:208)
            ].map { UIColor(red: $0.r / 255.0, green: $0.g / 255.0, blue: $0.b / 255.0, alpha: 1) }

        // For each position x shape x color, construct an image
        return [ConfettiPosition.foreground, ConfettiPosition.background].flatMap { position in
            return [ConfettiShape.rectangle, ConfettiShape.circle].flatMap { shape in
                return confettiColors.map { color in
                    return ConfettiType(color: color, shape: shape, position: position)
                }
            }
        }
    }()
    
    var foregroundConfettiLayer : CAEmitterLayer!

    var backgroundConfettiLayer: CAEmitterLayer!
    
    

    init(view: UIView) {
        self.view=view
        foregroundConfettiLayer = self.createConfettiLayer()

        backgroundConfettiLayer = {
            let emitterLayer = self.createConfettiLayer()
            
            for emitterCell in emitterLayer.emitterCells ?? [] {
                emitterCell.scale = 0.5
            }

            emitterLayer.opacity = 0.5
            emitterLayer.speed = 0.95
            
            return emitterLayer
        }()
        
        
    }
    func startConfetti(){
        for layer in [foregroundConfettiLayer, backgroundConfettiLayer] {
            self.view.layer.addSublayer(layer!)
            self.addBehaviors(to: layer!)
            self.addAnimations(to: layer!)
        }
    }
    
    func stopConfetti(){
        self.foregroundConfettiLayer.lifetime=0
        self.backgroundConfettiLayer.lifetime=0
    }
    
    func addAnimations(to layer: CAEmitterLayer) {
        addAttractorAnimation(to: layer)
        addBirthrateAnimation(to: layer)
        addGravityAnimation(to: layer)
    }
    func addBehaviors(to layer: CAEmitterLayer) {
        layer.setValue([
            horizontalWaveBehavior(),
            verticalWaveBehavior(),
            attractorBehavior(for: layer)
        ], forKey: "emitterBehaviors")
    }
    
    func horizontalWaveBehavior() -> NSObject {
        let behavior = createBehavior(type: "kCAEmitterBehaviorWave")
        behavior.setValue([100, 0, 0], forKeyPath: "force")
        behavior.setValue(0.5, forKeyPath: "frequency")
        return behavior
    }

    func verticalWaveBehavior() -> NSObject {
        let behavior = createBehavior(type: "kCAEmitterBehaviorWave")
        behavior.setValue([0, 500, 0], forKeyPath: "force")
        behavior.setValue(3, forKeyPath: "frequency")
        return behavior
    }
    
    func createBehavior(type: String) -> NSObject {
        let behaviorClass = NSClassFromString("CAEmitterBehavior") as! NSObject.Type
        let behaviorWithType = behaviorClass.method(for: NSSelectorFromString("behaviorWithType:"))!
        let castedBehaviorWithType = unsafeBitCast(behaviorWithType, to:(@convention(c)(Any?, Selector, Any?) -> NSObject).self)
        return castedBehaviorWithType(behaviorClass, NSSelectorFromString("behaviorWithType:"), type)
    }
    
   func attractorBehavior(for emitterLayer: CAEmitterLayer) -> Any {
       let behavior = createBehavior(type: "attractor")
       behavior.setValue("attractor", forKeyPath: "name")

       // Attractiveness
       behavior.setValue(-290, forKeyPath: "falloff")
       behavior.setValue(300, forKeyPath: "radius")
       behavior.setValue(10, forKeyPath: "stiffness")

       // Position
       behavior.setValue(CGPoint(x: emitterLayer.emitterPosition.x,
                                 y: emitterLayer.emitterPosition.y + 20),
                         forKeyPath: "position")
       behavior.setValue(-70, forKeyPath: "zPosition")

       return behavior
   }

   // Step 6: Animations & Explosions
   func addAttractorAnimation(to layer: CALayer) {
       let animation = CAKeyframeAnimation()
       animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
       animation.duration = 3
       animation.keyTimes = [0, 0.4]
       animation.values = [80, 5]

       layer.add(animation, forKey: "emitterBehaviors.attractor.stiffness")
   }

   func addBirthrateAnimation(to layer: CALayer) {
       let animation = CABasicAnimation()
       animation.duration = 1
       animation.fromValue = 1
       animation.toValue = 0

       layer.add(animation, forKey: "birthRate")
   }

   // Step 7: Air Resistance & Gravity
   func dragBehavior() -> Any {
       let behavior = createBehavior(type: "drag")
       behavior.setValue("drag", forKey: "name")
       behavior.setValue(2, forKey: "drag")

       return behavior
   }

   func addDragAnimation(to layer: CALayer) {
       let animation = CABasicAnimation()
       animation.duration = 0.35
       animation.fromValue = 0
       animation.toValue = 2

       layer.add(animation, forKey:  "emitterBehaviors.drag.drag")
   }

   func addGravityAnimation(to layer: CALayer) {
       let animation = CAKeyframeAnimation()
       animation.duration = 6
       animation.keyTimes = [0.05, 0.1, 0.5, 1]
       animation.values = [0, 100, 2000, 4000]

       for image in confettiTypes {
           layer.add(animation, forKey: "emitterCells.\(image.name).yAcceleration")
       }
   }
    

    func createConfettiCells() -> [CAEmitterCell] {
        return confettiTypes.map { confettiType in
            let cell = CAEmitterCell()
            cell.name = confettiType.name
            
            cell.beginTime = 0.1
            cell.birthRate = 100
            cell.contents = confettiType.image.cgImage
            cell.emissionRange = CGFloat(Double.pi)
            cell.lifetime = 10
            cell.spin = 4
            cell.spinRange = 8
            cell.velocityRange = 0
            cell.yAcceleration = 0
            
            // Step 3: A _New_ Spin On Things
            
            cell.setValue("plane", forKey: "particleType")
            cell.setValue(Double.pi, forKey: "orientationRange")
            cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
            cell.setValue(Double.pi / 2, forKey: "orientationLatitude")
            
            return cell
        }
    }
    func createConfettiLayer() -> CAEmitterLayer {
       let emitterLayer = CAEmitterLayer()

        emitterLayer.birthRate = 0
        emitterLayer.emitterCells = createConfettiCells()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.minY - 100)
        emitterLayer.emitterSize = CGSize(width: 300, height: 300)
        emitterLayer.emitterShape = .sphere
        emitterLayer.frame = view.bounds

        emitterLayer.beginTime = CACurrentMediaTime()
        return emitterLayer
    }
}




/**
 Represents a single type of confetti piece.
 */
class ConfettiType {
    let color: UIColor
    let shape: ConfettiShape
    let position: ConfettiPosition
    lazy var name = UUID().uuidString

    init(color: UIColor, shape: ConfettiShape, position: ConfettiPosition) {
        self.color = color
        self.shape = shape
        self.position = position
    }
    lazy var image: UIImage = {
        let imageRect: CGRect = {
            switch shape {
            case .rectangle:
                return CGRect(x: 0, y: 0, width: 20, height: 13)
            case .circle:
                return CGRect(x: 0, y: 0, width: 10, height: 10)
            }
        }()

        UIGraphicsBeginImageContext(imageRect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)

        switch shape {
        case .rectangle:
            context.fill(imageRect)
        case .circle:
            context.fillEllipse(in: imageRect)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }()
}

enum ConfettiShape {
    case rectangle
    case circle
}

enum ConfettiPosition {
    case foreground
    case background
}
