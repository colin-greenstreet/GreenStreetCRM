//
//  AppDelegate.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 03/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    //Kills the whole app after last window has been closed via the red button
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        return true
    }
    
}

