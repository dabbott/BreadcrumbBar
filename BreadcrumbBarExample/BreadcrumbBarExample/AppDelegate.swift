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
        // Insert code here to initialize your application

        let breadcrumbBar = BreadcrumbBar()

        breadcrumbBar.fillColor = .white

        let contentView = window.contentView!

        contentView.addSubview(breadcrumbBar)

        breadcrumbBar.translatesAutoresizingMaskIntoConstraints = false
        breadcrumbBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        breadcrumbBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        breadcrumbBar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        let home = FileManager.default.homeDirectoryForCurrentUser

        let breadcrumbs: [Breadcrumb] = home.pathComponents.enumerated().map { index, component in
            let path = home.pathComponents.dropLast(home.pathComponents.count - index - 1).reduce("/") { (result, item) -> String in
                if item == "/" { return result }
                return result == "/" ? "\(result)\(item)" : "\(result)/\(item)"
            }

            Swift.print(path)

            return Breadcrumb(id: UUID(), title: component, icon: NSWorkspace.shared.icon(forFile: path))
        }

        breadcrumbBar.breadcrumbs = breadcrumbs

        breadcrumbBar.onClickBreadcrumb = { id in
            Swift.print("click", breadcrumbs.first(where: { $0.id == id })?.title ?? "")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

