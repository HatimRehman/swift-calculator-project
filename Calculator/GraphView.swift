//
//  GraphView.swift
//  Calculator
//
//  Created by Hatim Rehman on 2016-06-06.
//  Copyright © 2016 Hatim Rehman. All rights reserved.
//

import UIKit

class GraphView: UIView {
    
    weak var dataSource: GraphViewDataSource?
    
    
    var axesDrawer = AxesDrawer(color: UIColor.lightGray, contentScaleFactor: 1)
    @IBInspectable
    var scale: CGFloat = 20 { didSet { setNeedsDisplay() } }
    
    // pinch gesture handler which scales the face
    func changeScale(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    fileprivate func getPath(_ rect: CGRect) -> UIBezierPath {
        
        let origin = self.center
        let path = UIBezierPath()
        
        path.lineWidth = 2.0
        
        var firstValue = true
        
        var point = CGPoint()
        var x = CGFloat()
        
        let maxY = rect.height/scale
        
        for i in 0...Int(bounds.size.width * contentScaleFactor) {
            
            point.x = CGFloat(i) / contentScaleFactor
            
            x = (point.x - origin.x) / scale
            
            if let y = dataSource?.function(x) , y < maxY/2 && y > -maxY/2 {
                point.y = origin.y - y * scale
                if firstValue {
                    path.move(to: point)
                    firstValue = false
                } else {
                    path.addLine(to: point)
                }
            }
        }
        
        return path
        //path.stroke()
    }
    
    fileprivate var haventDrawnFunction = true
    
    override func draw(_ rect: CGRect)
    {
        axesDrawer.drawAxesInRect(rect, origin: self.center, pointsPerUnit: scale)
        
        UIColor.orange.setStroke()
        
        let path = getPath(rect)
        let pathLayer = CAShapeLayer()
        
        if haventDrawnFunction {
            pathLayer.frame = rect
            pathLayer.path = path.cgPath
            pathLayer.strokeColor = UIColor.orange.cgColor
            pathLayer.fillColor = nil
            pathLayer.lineWidth = 2.0
            pathLayer.lineJoin = kCALineJoinBevel
            
            //Add the layer to your view's layer
            self.layer.addSublayer(pathLayer)
            
            //This is basic animation, quite a few other methods exist to handle animation see the reference site answers
            let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")// CABasicAnimation.animationWithKeyPath("strokeEnd")
            pathAnimation.duration = 2.0
            pathAnimation.fromValue = NSNumber(value: 0.0 as Float)
            pathAnimation.toValue = NSNumber(value: 1.0 as Float)
            //Animation will happen right away  
            pathLayer.add(pathAnimation, forKey: "strokeEnd")
            haventDrawnFunction = false
        } else {
            self.layer.sublayers?.removeLast()
            path.stroke() }
        
    }
}
