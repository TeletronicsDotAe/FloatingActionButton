//
//  FloatingActionButton.swift
//  Pods
//
//  Adapted by Martin Jacob Rehder on 2016/04/17
//
//  Original by
//  Created by Takuma Yoshida on 2015/08/25.
//
//

import Foundation
import QuartzCore

// FloatingButton DataSource methods

@objc public protocol FloatingActionButtonDataSource {
    func numberOfCells(floatingActionButton: FloatingActionButton) -> Int

    func cellForIndex(index: Int) -> FloatingCell
}

@objc public protocol FloatingActionButtonDelegate {
    // selected method
    optional func floatingActionButton(floatingActionButton: FloatingActionButton, didSelectItemAtIndex index: Int)
}

public enum FloatingActionButtonAnimateStyle: Int {
    case Up
    case Right
    case Left
    case Down
}

@IBDesignable
public class FloatingActionButton: UIView {

    private let internalRadiusRatio: CGFloat = 20.0 / 56.0
    public var cellRadiusRatio: CGFloat = 0.38
    public var animateStyle: FloatingActionButtonAnimateStyle = .Up {
        didSet {
            baseView.animateStyle = animateStyle
        }
    }
    public var enableShadow = true {
        didSet {
            setNeedsDisplay()
        }
    }

    public var delegate: FloatingActionButtonDelegate?
    public var dataSource: FloatingActionButtonDataSource?

    public var responsible = true
    public var isOpening: Bool {
        get {
            return !baseView.openingCells.isEmpty
        }
    }
    public private(set) var isClosed: Bool = true

    @IBInspectable public var color: UIColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0) {
        didSet {
            if self.childControlsColor == baseView.color {
                self.childControlsColor = color
            }
            baseView.color = color
        }
    }
    
    @IBInspectable public var childControlsColor: UIKit.UIColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
    @IBInspectable public var childControlsTintColor: UIKit.UIColor = UIKit.UIColor.clearColor();

    @IBInspectable public var image: UIImage? {
        didSet {
            if image != nil {
                plusLayer.contents = image!.CGImage
                plusLayer.path = nil
            }
        }
    }

    @IBInspectable public var rotationDegrees: CGFloat = 45.0

    private var plusLayer = CAShapeLayer()
    private let circleLayer = CAShapeLayer()

    private var touching = false

    private var baseView = CircleBaseView()
    private let actionButtonView = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func insertCell(cell: FloatingCell) {
        
        cell.color = self.childControlsColor;
        cell.imageView.tintColor = self.childControlsTintColor;

        cell.radius = self.frame.width * cellRadiusRatio
        cell.center = self.center.minus(self.frame.origin)
        cell.actionButton = self
        insertSubview(cell, aboveSubview: baseView)
    }

    private func cellArray() -> [FloatingCell] {
        var result: [FloatingCell] = []
        if let source = dataSource {
            for i in 0 ..< source.numberOfCells(self) {
                result.append(source.cellForIndex(i))
            }
        }
        return result
    }

    // open all cells
    public func open() {

        // rotate plus icon
        CATransaction.setAnimationDuration(0.8)
        self.plusLayer.transform = CATransform3DMakeRotation((CGFloat(M_PI) * rotationDegrees) / 180, 0, 0, 1)

        let cells = cellArray()
        for cell in cells {
            insertCell(cell)
        }

        self.baseView.open(cells)

        self.isClosed = false
    }

    // close all cells
    public func close() {

        // rotate plus icon
        CATransaction.setAnimationDuration(0.8)
        self.plusLayer.transform = CATransform3DMakeRotation(0, 0, 0, 1)

        self.baseView.close(cellArray())

        self.isClosed = true
    }

    // MARK: draw icon
    public override func drawRect(rect: CGRect) {
        drawCircle()
        drawShadow()
    }

    /// create, configure & draw the plus layer (override and create your own shape in subclass!)
    public func createPlusLayer(frame: CGRect) -> CAShapeLayer {

        // draw plus shape
        let plusLayer = CAShapeLayer()
        plusLayer.lineCap = kCALineCapRound
        plusLayer.strokeColor = UIColor.whiteColor().CGColor
        plusLayer.lineWidth = 3.0

        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: frame.width * internalRadiusRatio, y: frame.height * 0.5))
        path.addLineToPoint(CGPoint(x: frame.width * (1 - internalRadiusRatio), y: frame.height * 0.5))
        path.moveToPoint(CGPoint(x: frame.width * 0.5, y: frame.height * internalRadiusRatio))
        path.addLineToPoint(CGPoint(x: frame.width * 0.5, y: frame.height * (1 - internalRadiusRatio)))

        plusLayer.path = path.CGPath
        return plusLayer
    }

    private func drawCircle() {
        self.circleLayer.cornerRadius = self.frame.width * 0.5
        self.circleLayer.masksToBounds = true
        if touching && responsible {
            self.circleLayer.backgroundColor = self.color.white(0.5).CGColor
        } else {
            self.circleLayer.backgroundColor = self.color.CGColor
        }
    }

    private func drawShadow() {
        if enableShadow {
            circleLayer.appendShadow()
        }
    }

    // MARK: Events
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touching = true
        setNeedsDisplay()
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touching = false
        setNeedsDisplay()
        didTapped()
    }

    public override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touching = false
        setNeedsDisplay()
    }

    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        for cell in cellArray() {
            let pointForTargetView = cell.convertPoint(point, fromView: self)

            if (CGRectContainsPoint(cell.bounds, pointForTargetView)) {
                if cell.userInteractionEnabled {
                    return cell.hitTest(pointForTargetView, withEvent: event)
                }
            }
        }

        return super.hitTest(point, withEvent: event)
    }

    // MARK: private methods
    private func setup() {
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false

        baseView.setup(self)
        self.baseView.baseLiquid?.removeFromSuperview()
        addSubview(baseView)

        actionButtonView.frame = baseView.frame
        actionButtonView.userInteractionEnabled = false
        addSubview(actionButtonView)

        actionButtonView.layer.addSublayer(circleLayer)
        circleLayer.frame = actionButtonView.layer.bounds

        plusLayer = createPlusLayer(circleLayer.bounds)
        circleLayer.addSublayer(plusLayer)
        plusLayer.frame = circleLayer.bounds
    }

    private func didTapped() {
        if isClosed {
            open()
        } else {
            close()
        }
    }

    public func didTappedCell(target: FloatingCell) {
        if let _ = dataSource {
            let cells = cellArray()
            for i in 0 ..< cells.count {
                let cell = cells[i]
                if target === cell {
                    delegate?.floatingActionButton?(self, didSelectItemAtIndex: i)
                }
            }
        }
    }

}

class ActionBarBaseView: UIView {
    var opening = false
    func setup(actionButton: FloatingActionButton) {
    }

    func translateY(layer: CALayer, duration: CFTimeInterval, f: (CABasicAnimation) -> ()) {
        let translate = CABasicAnimation(keyPath: "transform.translation.y")
        f(translate)
        translate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        translate.removedOnCompletion = false
        translate.fillMode = kCAFillModeForwards
        translate.duration = duration
        layer.addAnimation(translate, forKey: "transYAnim")
    }
}

class CircleBaseView: ActionBarBaseView {

    let openDuration: CGFloat = 0.4
    let closeDuration: CGFloat = 0.15
    let viscosity: CGFloat = 0.65
    var animateStyle: FloatingActionButtonAnimateStyle = .Up
    var color: UIColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
    var baseLiquid: FloatingCircle?
    var enableShadow = true

    private var openingCells: [FloatingCell] = []
    private var keyDuration: CGFloat = 0
    private var displayLink: CADisplayLink?

    override func setup(actionButton: FloatingActionButton) {
        self.frame = actionButton.frame
        self.center = actionButton.center.minus(actionButton.frame.origin)
        self.animateStyle = actionButton.animateStyle
        let radius = min(self.frame.width, self.frame.height) * 0.5

        baseLiquid = FloatingCircle(center: self.center.minus(self.frame.origin), radius: radius, color: actionButton.color)
        baseLiquid?.clipsToBounds = false
        baseLiquid?.layer.masksToBounds = false

        clipsToBounds = false
        layer.masksToBounds = false
        addSubview(baseLiquid!)
    }

    func open(cells: [FloatingCell]) {
        stop()
        displayLink = CADisplayLink(target: self, selector: #selector(CircleBaseView.didDisplayRefresh(_:)))
        displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        opening = true
        for cell in cells {
            cell.layer.removeAllAnimations()
            cell.layer.appendShadow()
            openingCells.append(cell)
        }
    }

    func close(cells: [FloatingCell]) {
        stop()
        opening = false
        displayLink = CADisplayLink(target: self, selector: #selector(CircleBaseView.didDisplayRefresh(_:)))
        displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        for cell in cells {
            cell.layer.removeAllAnimations()
            openingCells.append(cell)
            cell.userInteractionEnabled = false
        }
    }

    func didFinishUpdate() {
        if opening {
            for cell in openingCells {
                cell.userInteractionEnabled = true
            }
        } else {
            for cell in openingCells {
                cell.removeFromSuperview()
            }
        }
    }

    func update(delay: CGFloat, duration: CGFloat, opening: Bool, f: (FloatingCell, Int, CGFloat) -> ()) {
        if openingCells.isEmpty {
            return
        }

        let maxDuration = duration + CGFloat(delay)
        let t = keyDuration
        let allRatio = easeInEaseOut(t / maxDuration)

        if allRatio >= 1.0 {
            didFinishUpdate()
            stop()
            return
        }

        let easeInOutRate = allRatio * allRatio * allRatio
        let alphaColor = opening ? easeInOutRate : 1 - easeInOutRate

        if opening {
            for i in 0 ..< openingCells.count {
                let liquidCell = openingCells[i]
                let cellDelay = CGFloat(delay)
                let ratio = easeInEaseOut((t - cellDelay) / duration)
                f(liquidCell, i, ratio)
            }

            if let firstCell = openingCells.first {
                firstCell.alpha = alphaColor
            }
            for i in 1 ..< openingCells.count {
                let prev = openingCells[i - 1]
                let cell = openingCells[i]
                cell.alpha = alphaColor
            }
        } else {
            for i in 0 ..< openingCells.count {
                let cell = openingCells[i]
                cell.alpha = alphaColor
            }
        }
    }

    func updateOpen() {
        update(0.1, duration: openDuration, opening: true) {
            cell, i, ratio in
            let posRatio = 0.5 + (ratio / 3.333333333)
            let distance = (cell.frame.height * 0.5 + CGFloat(i + 1) * cell.frame.height * 1.5) * posRatio
            cell.center = self.center.plus(self.differencePoint(distance))
            cell.update(ratio, open: true)
        }
    }

    func updateClose() {
        update(0, duration: closeDuration, opening: false) {
            cell, i, ratio in
            let posRatio = 0.5 + (ratio / 3.333333333)
            let distance = (cell.frame.height * 0.5 + CGFloat(i + 1) * cell.frame.height * 1.5) * posRatio
            cell.center = self.center.plus(self.differencePoint(distance))
            cell.update(ratio, open: false)
        }
    }

    func differencePoint(distance: CGFloat) -> CGPoint {
        switch animateStyle {
        case .Up:
            return CGPoint(x: 0, y: -distance)
        case .Right:
            return CGPoint(x: distance, y: 0)
        case .Left:
            return CGPoint(x: -distance, y: 0)
        case .Down:
            return CGPoint(x: 0, y: distance)
        }
    }

    func stop() {
        openingCells = []
        keyDuration = 0
        displayLink?.invalidate()
    }

    func easeInEaseOut(t: CGFloat) -> CGFloat {
        if t >= 1.0 {
            return 1.0
        }
        if t < 0 {
            return 0
        }
        return -1 * t * (t - 2)
    }

    func didDisplayRefresh(displayLink: CADisplayLink) {
        if opening {
            keyDuration += CGFloat(displayLink.duration)
            updateOpen()
        } else {
            keyDuration += CGFloat(displayLink.duration)
            updateClose()
        }
    }

}
