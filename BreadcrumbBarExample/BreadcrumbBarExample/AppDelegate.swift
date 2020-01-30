//
//  AppDelegate.swift
//  BreadcrumbBarExample
//
//  Created by Devin Abbott on 1/27/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import BreadcrumbBar
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = window.contentView!

        let navigationBar = NavigationBar()

        navigationBar.fillColor = NSColor.controlBackgroundColor

        contentView.addSubview(navigationBar)

        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        navigationBar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        let home = FileManager.default.homeDirectoryForCurrentUser

        let breadcrumbs: [Breadcrumb] = home.pathComponents.enumerated().map { index, component in
            let path = home.pathComponents.dropLast(home.pathComponents.count - index - 1).reduce("/") { (result, item) -> String in
                if item == "/" { return result }
                return result == "/" ? "\(result)\(item)" : "\(result)/\(item)"
            }

            Swift.print(path)

            return Breadcrumb(id: UUID(), title: component, icon: NSWorkspace.shared.icon(forFile: path))
        }

        navigationBar.breadcrumbs = breadcrumbs

        navigationBar.onClickBreadcrumb = { id in
            Swift.print("click", breadcrumbs.first(where: { $0.id == id })?.title ?? "")
        }

        let menu = NSMenu()

        menu.addItem(withTitle: "Test 1", action: nil, keyEquivalent: "")
        menu.addItem(withTitle: "Test 2", action: nil, keyEquivalent: "")

        navigationBar.menuForForwardItem = {
            return menu
        }

        navigationBar.menuForBackItem = {
            return menu
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

