//
//  UILabelWithPadding.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/4/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

@IBDesignable
class UILabelWithPadding: UILabel {
    
    lazy var gradient: CAGradientLayer = CAGradientLayer()
    
    @IBInspectable var enableGradientBackground: Bool = false
    @IBInspectable var startColor: UIColor = UIColor.transparent()
    @IBInspectable var endColor: UIColor = UIColor.transparent()
    @IBInspectable var startPoint: CGPoint = CGPointZero
    @IBInspectable var endPoint: CGPoint = CGPointMake(1, 0)
    @IBInspectable var gradientCenter: CGFloat = 0.5
    
    
    @IBInspectable var paddingLeft: CGFloat = 0
    @IBInspectable var paddingTop: CGFloat = 0
    @IBInspectable var paddingRight: CGFloat = 0
    @IBInspectable var paddingBottom: CGFloat = 0
    var padding: CGFloat = 0 {
        didSet {
            paddingLeft = padding
            paddingTop = padding
            paddingRight = padding
            paddingBottom = padding
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        if enableGradientBackground {
            prepareGradient()
            layer.insertSublayer(gradient, atIndex: 0)
        }
        super.drawRect(rect)
    }

    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }

    private func prepareGradient() {
        gradient.frame = bounds
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.locations = [0, gradientCenter]
        gradient.colors = [startColor.CGColor, endColor.CGColor]
    }
}
