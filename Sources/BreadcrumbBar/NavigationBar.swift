//
//  NavigationControl.swift
//  ProjectName
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit

// MARK: - NavigationBar

public class NavigationBar: NSBox {

    public struct Style: Equatable {
        public var breadcrumbBarStyle: BreadcrumbBar.Style = .default
        public var navigationControlStyle: NavigationControl.Style = .default
        public var spacing: CGFloat = 4

        public static var `default` = Style()
    }

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var breadcrumbs: [Breadcrumb] = [] {
        didSet {
            if oldValue != breadcrumbs {
                update()
            }
        }
    }

    public var onClickBreadcrumb: ((UUID) -> Void)?

    public var onClickForward: (() -> Void)?

    public var onClickBack: (() -> Void)?

    public var menuForForwardItem: (() -> NSMenu?)?

    public var menuForBackItem: (() -> NSMenu?)?

    public var style: Style = Style() {
       didSet {
           if oldValue != style {
               update()
           }
       }
    }

    // MARK: Private

    private var breadcrumbBar = BreadcrumbBar()

    private var navigationControl = NavigationControl()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        breadcrumbBar.onClickBreadcrumb = { [unowned self] uuid in self.onClickBreadcrumb?(uuid) }

        navigationControl.onClickBack = { [unowned self] in self.onClickBack?() }
        navigationControl.onClickForward = { [unowned self] in self.onClickForward?() }
        navigationControl.menuForForwardItem = { [unowned self] in self.menuForForwardItem?() }
        navigationControl.menuForBackItem = { [unowned self] in self.menuForBackItem?() }

        addSubview(navigationControl)
        addSubview(breadcrumbBar)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        navigationControl.topAnchor.constraint(equalTo: topAnchor).isActive = true
        navigationControl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        navigationControl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        navigationControl.trailingAnchor.constraint(lessThanOrEqualTo: breadcrumbBar.leadingAnchor, constant: -style.spacing).isActive = true

        breadcrumbBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        breadcrumbBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        breadcrumbBar.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true

        let centerConstraint = breadcrumbBar.centerXAnchor.constraint(equalTo: centerXAnchor)
        centerConstraint.priority = .defaultLow
        centerConstraint.isActive = true
    }

    private func update() {
        breadcrumbBar.breadcrumbs = breadcrumbs
        breadcrumbBar.style = style.breadcrumbBarStyle

        navigationControl.style = style.navigationControlStyle
    }

}

