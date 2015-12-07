//
//  UITicketButton.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 12/7/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

@IBDesignable
class UITicketButton: UIButton {
    
    var fill = UIColor.clearColor()
    @IBInspectable var strokeColor: UIColor = UIColor.blackColor()
    @IBInspectable var fillColor: UIColor = UIColor.clearColor()
    
    let π = CGFloat(M_PI)
    let cornerRadius: CGFloat = 8
    let patternRadius: CGFloat = 8

    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextMoveToPoint(ctx, cornerRadius, 0)
        CGContextSetLineWidth(ctx, 0.8)
        CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor)
        CGContextSetFillColorWithColor(ctx, fillColor.CGColor)
        CGContextSetInterpolationQuality(ctx, CGInterpolationQuality.High)

        let path = CGPathCreateMutable()
        //init in top left corner
        CGPathMoveToPoint(path, nil, cornerRadius + 1, 1)
        
        CGPathAddLineToPoint(path, nil, rect.width - 1 - cornerRadius, 1)
        CGPathAddArc(path, nil, rect.width - 1, 1, cornerRadius, π, π / 2, true)
        
        CGPathAddLineToPoint(path, nil, rect.width - 1, (rect.height - 2) / 2 - patternRadius)
        CGPathAddArc(path, nil, rect.width - 1, rect.height / 2, patternRadius, π * 3 / 2, π / 2, true)
        CGPathAddLineToPoint(path, nil, rect.width - 1, rect.height - 1 - cornerRadius)
        CGPathAddArc(path, nil, rect.width - 1, rect.height - 1, cornerRadius, π * 3 / 2, π, true)

        CGPathAddLineToPoint(path, nil, cornerRadius + 2, rect.height - 1)
        CGPathAddArc(path, nil, 1, rect.height - 1, cornerRadius, 0, π * 3 / 2, true)
        
        CGPathAddLineToPoint(path, nil, 1, (rect.height - 2) / 2 + patternRadius + 1)
        CGPathAddArc(path, nil, 1, rect.height / 2, patternRadius, π / 2, π * 3 / 2, true)
        CGPathAddLineToPoint(path, nil, 1, 1 + cornerRadius)
        CGPathAddArc(path, nil, 1, 1, cornerRadius, π / 2, 0, true)
        
        CGPathCloseSubpath(path)
        CGContextAddPath(ctx, path)
        
        CGContextDrawPath(ctx, CGPathDrawingMode.FillStroke)
        
        CGContextAddRect(ctx, CGRectMake(2.5 * cornerRadius, 1.5 * cornerRadius, rect.width - 5 * cornerRadius, 0.4 * cornerRadius))
        CGContextAddRect(ctx, CGRectMake(2.5 * cornerRadius, rect.height - 1.9 * cornerRadius, rect.width - 5 * cornerRadius, 0.4 * cornerRadius))
        CGContextStrokePath(ctx)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        fillColor = strokeColor.colorWithAlphaComponent(0.3)
        setNeedsDisplay()
        
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        fillColor = fill
        setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        fillColor = fill
        setNeedsDisplay()
    }
}
