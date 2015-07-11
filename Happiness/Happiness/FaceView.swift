//
//  FaceView.swift
//  Happiness
//
//  Created by Alice Yang on 7/11/15.
//  Copyright (c) 2015 Alice Yang. All rights reserved.
//

import UIKit

class FaceView: UIView {

    var faceCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    var faceRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * 0.90
    }
    
    var lineWidth: CGFloat = 3 { didSet{ setNeedsDisplay() } }
    var color: UIColor = UIColor.blueColor() { didSet{ setNeedsDisplay() } }

    override func drawRect(rect: CGRect) {
        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        color.set()
        facePath.stroke()
    }
}
