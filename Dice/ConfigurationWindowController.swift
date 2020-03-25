//
//  ConfigurationWindowController.swift
//  Dice
//
//  Created by 조성빈 on 1/2/20.
//  Copyright © 2020 조성빈. All rights reserved.
//

import Cocoa

struct DieConfiguration {
    let color: NSColor
    let rolls: Int

    init(color: NSColor, rolls: Int) {
        self.color = color
        self.rolls = max(rolls, 1)
    }
}

class ConfigurationWindowController: NSWindowController {

    var configuration: DieConfiguration {
        set {
            color = newValue.color
            rolls = newValue.rolls
        }
        get {
            DieConfiguration(color: color, rolls: rolls)
        }
    }

    @objc dynamic private var color: NSColor = .white
    @objc dynamic private var rolls: Int = 10

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("ConfigurationWindowController")
    }

    @IBAction func okayButtonClicked(_ button: NSButton) {
        window?.endEditing(for: nil)
        dismiss(with: .OK)
    }

    @IBAction func cancelButtonClicked(_ button: NSButton) {
        dismiss(with: .cancel)
    }

    func dismiss(with response: NSApplication.ModalResponse) {
        window!.sheetParent!.endSheet(window!, returnCode: response)
    }
}
