//
//  FloatingCell.swift
//  Pods
//
//  Created by Martin Rehder on 17.04.16.
//
//

import UIKit

public class FloatingCell: FloatingCircle {
    
    let internalRatio: CGFloat = 0.75
    
    public var responsible = true
    public var imageView = UIImageView()
    weak var actionButton: FloatingActionButton?
    
    // for implement responsible color
    private var originalColor: UIColor
    
    public override var frame: CGRect {
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
        self.originalColor = UIColor.clearColor()
        super.init()
        setup(icon)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(image: UIImage, tintColor: UIColor = UIColor.whiteColor()) {
        imageView.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageView.tintColor = tintColor
        setupView(imageView)
    }
    
    public func setupView(view: UIView) {
        userInteractionEnabled = false
        addSubview(view)
        resizeSubviews()
    }
    
    private func resizeSubviews() {
        let size = CGSize(width: frame.width * 0.5, height: frame.height * 0.5)
        imageView.frame = CGRect(x: frame.width - frame.width * internalRatio, y: frame.height - frame.height * internalRatio, width: size.width, height: size.height)
    }
    
    func update(key: CGFloat, open: Bool) {
        for subview in self.subviews {
            let ratio = max(2 * (key * key - 0.5), 0)
            subview.alpha = open ? ratio : -ratio
        }
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if responsible {
            originalColor = color
            color = originalColor.white(0.5)
            setNeedsDisplay()
        }
    }
    
    public override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if responsible {
            color = originalColor
            setNeedsDisplay()
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        color = originalColor
        actionButton?.didTappedCell(self)
    }
    
}
