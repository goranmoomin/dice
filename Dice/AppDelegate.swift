//
//  AppDelegate.swift
//  Dice
//
//  Created by 조성빈 on 12/31/19.
//  Copyright © 2019 조성빈. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create a window controller with a XIB file of the same name
        let mainWindowController = MainWindowController()
        // Put the window of the window controller on screen
        mainWindowController.showWindow(self)

        // Set the property to point to the window controller
        self.mainWindowController = mainWindowController
    }
}

