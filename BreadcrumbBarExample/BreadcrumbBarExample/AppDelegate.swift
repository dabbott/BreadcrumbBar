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

        contentView.addSubview(navigationBar)

        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        navigationBar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        navigationBar.fillColor = NSColor.controlBackgroundColor

        let testButton = BreadcrumbItem(titleText: "Test", icon: nil, isEnabled: true)
        let accessoryView = NSStackView()
        accessoryView.addArrangedSubview(testButton)

        navigationBar.accessoryView = accessoryView

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

        let backMenu = NSMenu()

        let forwardMenu = NSMenu()

        forwardMenu.addItem(withTitle: "Test 1", action: nil, keyEquivalent: "")
        forwardMenu.addItem(withTitle: "Test 2", action: nil, keyEquivalent: "")

        navigationBar.onClickBack = {
            Swift.print("Back")

            if let first = backMenu.items.first {
                backMenu.removeItem(first)
                forwardMenu.addItem(first)

                navigationBar.isBackEnabled = backMenu.items.count > 0
                navigationBar.isForwardEnabled = forwardMenu.items.count > 0
            }
        }

        navigationBar.onClickForward = {
            Swift.print("Forward")

            if let first = forwardMenu.items.first {
                forwardMenu.removeItem(first)
                backMenu.addItem(first)

                navigationBar.isBackEnabled = backMenu.items.count > 0
                navigationBar.isForwardEnabled = forwardMenu.items.count > 0
            }
        }

        navigationBar.menuForBackItem = {
            return backMenu
        }

        navigationBar.menuForForwardItem = {
            return forwardMenu
        }

        navigationBar.isForwardEnabled = true
        navigationBar.isBackEnabled = false

        navigationBar.heightAnchor.constraint(equalToConstant: 38).isActive = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

