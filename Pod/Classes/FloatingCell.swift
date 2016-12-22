//
//  FloatingCell.swift
//  Pods
//
//  Created by Martin Rehder on 17.04.16.
//
//

import UIKit
import DynamicColor

open class FloatingCell: FloatingCircle {
    
    let internalRatio: CGFloat = 0.75
    
    open var responsible = true
    open var imageView = UIImageView()
    weak var actionButton: FloatingActionButton?
    
    // for implement responsible color
    fileprivate var originalColor: UIColor
    
    open override var frame: CGRect {
        didSet {
            resizeSubviews()
        }
    }
    
    init(center: CGPoint, radius: CGFloat, color: UIColor, icon: UIImage) {
        self.originalColor = color
        super.init(center: center, radius: radius, color: color)
        setup(icon)
    }
    
    init(center: CGPoint, radius: CGFloat, color: UIColor, view: UIView) {
        self.originalColor = color
        super.init(center: center, radius: radius, color: color)
        setupView(view)
    }
    
    public init(icon: UIImage) {
        self.originalColor = UIColor.clear
        super.init()
        setup(icon)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ image: UIImage, tintColor: UIColor = UIColor.white) {
        imageView.image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = tintColor
        setupView(imageView)
    }
    
    open func setupView(_ view: UIView) {
        isUserInteractionEnabled = false
        addSubview(view)
        resizeSubviews()
    }
    
    fileprivate func resizeSubviews() {
        let size = CGSize(width: frame.width * 0.5, height: frame.height * 0.5)
        imageView.frame = CGRect(x: frame.width - frame.width * internalRatio, y: frame.height - frame.height * internalRatio, width: size.width, height: size.height)
    }
    
    func update(_ key: CGFloat, open: Bool) {
        for subview in self.subviews {
            let ratio = max(2 * (key * key - 0.5), 0)
            subview.alpha = open ? ratio : -ratio
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if responsible {
            originalColor = color
            color = originalColor.darkened(amount: 0.5)
            setNeedsDisplay()
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if responsible {
            color = originalColor
            setNeedsDisplay()
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        color = originalColor
        actionButton?.didTappedCell(self)
    }
    
}
