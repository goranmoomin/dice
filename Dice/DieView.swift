//
//  DieView.swift
//  Dice
//
//  Created by 조성빈 on 12/31/19.
//  Copyright © 2019 조성빈. All rights reserved.
//

import Cocoa

class DieView: NSView, NSDraggingSource {

    var intValue: Int? = 1 {
        didSet {
            needsDisplay = true
        }
    }

    var pressed: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 120, height: 120)
    }

    var highlightForDragging: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    var color: NSColor = .white {
        didSet {
            needsDisplay = true
        }
    }

    var numberOfTimesToRoll: Int = 10

    var rollsRemaining: Int = 0

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        self.registerForDraggedTypes([.string])
    }

    override func draw(_ dirtyRect: NSRect) {
        let backgroundColor = NSColor.lightGray
        backgroundColor.set()
        NSBezierPath.fill(bounds)

        if highlightForDragging {
            let gradient = NSGradient(starting: color, ending: backgroundColor)
            let boundsCenter = NSPoint(x: bounds.minX + bounds.width / 2, y: bounds.minY + bounds.height / 2)
            gradient?.draw(fromCenter: boundsCenter, radius: 0, toCenter: boundsCenter, radius: bounds.width / 2)
        } else {
            drawDie(with: bounds.size)
        }
    }

    func metrics(for size: CGSize) -> (edgeLength: CGFloat, dieFrame: CGRect) {
        let edgeLength = min(size.width, size.height)
        let padding = edgeLength / 10
        let drawingBounds = CGRect(x: 0, y: 0, width: edgeLength, height: edgeLength)
        var dieFrame = drawingBounds.insetBy(dx: padding, dy: padding)
        if pressed {
            dieFrame = dieFrame.offsetBy(dx: 0, dy: -edgeLength / 40)
        }
        return (edgeLength, dieFrame)
    }

    func drawDie(with size: CGSize) {
        let (edgeLength, dieFrame) = metrics(for: size)
        let cornerRadius: CGFloat = edgeLength / 5.0
        let dotRadius = edgeLength / 12.0
        let dotFrame = dieFrame.insetBy(dx: dotRadius * 2.5, dy: dotRadius * 2.5)

        NSGraphicsContext.saveGraphicsState()

        let shadow = NSShadow()
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        print("pressed = \(pressed)")
        shadow.shadowBlurRadius = (pressed ? edgeLength / 100 : edgeLength / 20)
        shadow.set()

        // Draw the rounded shape of the die profile:
        color.set()
        NSBezierPath(roundedRect: dieFrame, xRadius: cornerRadius, yRadius: cornerRadius).fill()

        NSGraphicsContext.restoreGraphicsState()
        // Shadow will not apply to subsequent drawing commands

        // Ready to draw the dots.
        // The dots will be black:
        NSColor.black.set()

        // Nested function to make drawing dots cleaner:
        func drawDot(_ u: CGFloat, _ v: CGFloat) {
            let dotOrigin = CGPoint(x: dotFrame.minX + dotFrame.width * u, y: dotFrame.minY + dotFrame.height * v)
            let dotRect = CGRect(origin: dotOrigin, size: .zero).insetBy(dx: -dotRadius, dy: -dotRadius)
            NSBezierPath(ovalIn: dotRect).fill()
        }

        if let intValue = intValue {
            // If intValue is in range...
            if 1 <= intValue && intValue <= 6 {
                // Draw the dots:
                if intValue % 2 == 1 {
                    drawDot(0.5, 0.5)
                }
                if 2 <= intValue && intValue <= 6 {
                    drawDot(0, 1) // Upper left
                    drawDot(1, 0) // Lower right
                }
                if 4 <= intValue && intValue <= 6 {
                    drawDot(1, 1) // Upper right
                    drawDot(0, 0) // Lower left
                }
                if intValue == 6 {
                    drawDot(0, 0.5) // Mid left/right
                    drawDot(1, 0.5)
                }
            } else {
                let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                paraStyle.alignment = .center
                let font = NSFont.systemFont(ofSize: edgeLength * 0.5)
                let attrs: [NSAttributedString.Key : Any] = [
                    .foregroundColor: NSColor.black,
                    .font: font,
                    .paragraphStyle: paraStyle
                ]
                let string = String(intValue) as NSString
                string.drawCentered(in: dieFrame, attributes: attrs)
            }
        }
    }

    func randomize() {
        intValue = Int(arc4random_uniform(6)) + 1
    }

    func roll() {
        rollsRemaining = numberOfTimesToRoll
        Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(rollTick(_:)), userInfo: nil, repeats: true)
        window?.makeFirstResponder(nil)
    }

    @objc func rollTick(_ sender: Timer) {
        let lastIntValue = intValue
        while intValue == lastIntValue {
            randomize()
        }
        rollsRemaining -= 1
        if rollsRemaining == 0 {
            sender.invalidate()
            window?.makeFirstResponder(self)
        }
    }

    // MARK: - Actions

    @IBAction func savePDF(_ sender: Any?) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["pdf"]
        savePanel.beginSheetModal(for: window!, completionHandler: { [unowned savePanel] (result) in
            if result == .OK {
                let data = self.dataWithPDF(inside: self.bounds)
                do {
                    try data.write(to: savePanel.url!, options: .atomicWrite)
                } catch let error as NSError {
                    let alert = NSAlert(error: error)
                    alert.runModal()
                }
            }
        })
    }

    // MARK: - Mouse Events

    var mouseDownEvent: NSEvent?

    override func mouseDown(with event: NSEvent) {
        print("mouseDown")
        mouseDownEvent = event
//        let dieFrame = metrics(for: bounds.size).dieFrame
//        let pointInView = convert(event.locationInWindow, to: self)
//        pressed = dieFrame.contains(pointInView)
        pressed = true
    }

    override func mouseDragged(with event: NSEvent) {
        print("mouseDragged location: \(event.locationInWindow)")
        let downPoint = mouseDownEvent!.locationInWindow
        let dragPoint = event.locationInWindow

        let distanceDragged = hypot(downPoint.x - dragPoint.x, downPoint.y - dragPoint.y)
        if distanceDragged < 3 {
            return
        }

        pressed = false

        if let intValue = intValue {
            let imageSize = bounds.size
            let image = NSImage(size: imageSize, flipped: false) { (imageBounds) in
                self.drawDie(with: imageBounds.size)
                return true
            }

            let draggingFrame = NSRect(origin: .zero, size: imageSize)

            let item = NSDraggingItem(pasteboardWriter: String(intValue) as NSString)
            item.draggingFrame = draggingFrame
            item.imageComponentsProvider = {
                let component = NSDraggingImageComponent(key: .icon)
                component.contents = image
                component.frame = NSRect(origin: NSPoint(), size: imageSize)
                return [component]
            }

            beginDraggingSession(with: [item], event: mouseDownEvent!, source: self)
        }
    }

    override func mouseUp(with event: NSEvent) {
        print("mouseUp clickCount: \(event.clickCount)")
        if event.clickCount == 2 {
            roll()
        }
        pressed = false
    }

    // MARK: - First Responder

    override var acceptsFirstResponder: Bool {
        true
    }

    override func becomeFirstResponder() -> Bool {
        true
    }

    override func resignFirstResponder() -> Bool {
        true
    }

    override func drawFocusRingMask() {
        drawDie(with: bounds.size)
    }

    override var focusRingMaskBounds: NSRect {
        bounds
    }

    // MARK: - Keyboard Events

    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }

    override func insertText(_ insertString: Any) {
        let text = insertString as! String
        intValue = Int(text)
    }

    override func insertTab(_ sender: Any?) {
        window?.selectNextKeyView(sender)
    }

    override func insertBacktab(_ sender: Any?) {
        window?.selectPreviousKeyView(sender)
    }

    // MARK: - Pasteboard

    func write(to pasteboard: NSPasteboard) {
        if let intValue = intValue {
            pasteboard.clearContents()
            pasteboard.writeObjects([String(intValue) as NSString])
        }
    }

    func read(from pasteboard: NSPasteboard) -> Bool {
        let objects = pasteboard.readObjects(forClasses: [NSString.self], options: [:]) as! [String]

        if let str = objects.first {
            intValue = Int(str)
            return true
        }
        return false
    }

    @IBAction func cut(_ sender: Any) {
        write(to: NSPasteboard.general)
        intValue = nil
    }

    @IBAction func copy(_ sender: Any) {
        write(to: NSPasteboard.general)
    }

    @IBAction func paste(_ sender: Any) {
        read(from: NSPasteboard.general)
    }

    // MARK: - Drag Source

    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return NSDragOperation(arrayLiteral: [.copy, .delete])
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        if operation == .delete {
            intValue = nil
        }
    }

    // MARK: - Drag Destination

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingSource as? DieView == self {
            return NSDragOperation()
        }
        highlightForDragging = true
        return sender.draggingSourceOperationMask
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        highlightForDragging = false
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return read(from: sender.draggingPasteboard)
    }

    override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        highlightForDragging = false
    }
}
