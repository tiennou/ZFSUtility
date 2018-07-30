//
//  AppDelegate.swift
//  ZFS Utility
//
//  Created by Etienne on 29/07/2018.
//  Copyright © 2018 Etienne Samson. All rights reserved.
//

import Cocoa
import ZFS

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!

	var manager = ZFSManager.sharedInstance()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		var pools = manager.pools

		pools[0].drives
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

