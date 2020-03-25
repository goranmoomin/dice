//
//  MainWindowController.swift
//  Dice
//
//  Created by 조성빈 on 12/31/19.
//  Copyright © 2019 조성빈. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override var windowNibName: NSNib.Name? {
        NSNib.Name("MainWindowController")
    }

    // MARK: - Actions

    var configurationWindowController: ConfigurationWindowController?

    @IBAction func showDieConfiguration(_ sender: Any?) {
        if let window = window, let dieView = window.firstResponder as? DieView {

            // Create and configure the window controller to present as a sheet:
            let windowController = ConfigurationWindowController()
            windowController.configuration = DieConfiguration(color: dieView.color, rolls: dieView.numberOfTimesToRoll)

            window.beginSheet(windowController.window!, completionHandler: { response in
                // The sheet has finished. Did the user click 'OK'?
                if response == .OK {
                    let configuration = self.configurationWindowController!.configuration
                    dieView.color = configuration.color
                    dieView.numberOfTimesToRoll = configuration.rolls
                }
                // All done with the window controller.
                self.configurationWindowController = nil
            })
            configurationWindowController = windowController
        }
    }
}
