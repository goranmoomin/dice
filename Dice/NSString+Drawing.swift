//
//  NSString+Drawing.swift
//  Dice
//
//  Created by 조성빈 on 1/1/20.
//  Copyright © 2020 조성빈. All rights reserved.
//

import Cocoa

extension NSString {

    func drawCentered(in rect: NSRect, attributes: [NSAttributedString.Key : Any]) {
        let stringSize = size(withAttributes: attributes)
        let point = NSPoint(x: rect.origin.x + (rect.width - stringSize.width) / 2.0, y: rect.origin.y + (rect.height - stringSize.height) / 2.0)
        draw(at: point, withAttributes: attributes)
    }
}
