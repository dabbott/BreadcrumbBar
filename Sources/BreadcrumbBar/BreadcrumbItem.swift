//
//  BreadcrumbItem.swift
//  ProjectName
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit

// MARK: - BreadcrumbItem

extension NSEdgeInsets: Equatable {
    public static func == (lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
        return lhs.top == rhs.top && lhs.left == rhs.left && lhs.right == rhs.right && lhs.bottom == rhs.bottom
    }
}

public class BreadcrumbItem: NSBox {

    public struct Style: Equatable {
        public var padding: NSEdgeInsets = .init(top: 2, left: 4, bottom: 2, right: 4)
        public var backgroundColor: NSColor = .clear
        public var hoverBackgroundColor: NSColor = NSColor.textColor.withAlphaComponent(0.1)
        public var pressedBackgroundColor: NSColor = NSColor.textColor.withAlphaComponent(0.05)
        public var cornerRadius: CGFloat = 3

        public static var `default` = Style()
    }

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()

        addTrackingArea(trackingArea)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeTrackingArea(trackingArea)
    }

    // MARK: Public

    public var onClick: (() -> Void)?

    public var style: Style = .default {
        didSet {
            if oldValue != style {
                update()
            }
        }
    }

    public var titleText: String = "" {
        didSet {
            if oldValue != titleText {
                attributedTitleText = NSAttributedString(string: titleText)
            }
        }
    }

    public var icon: NSImage?

    // MARK: Private

    private var attributedTitleText: NSAttributedString = NSAttributedString() {
        didSet {
            update()
        }
    }

    private var hovered: Bool = false {
        didSet {
            if oldValue != hovered {
                update()
            }
        }
    }

    private var pressed: Bool = false {
        didSet {
            if oldValue != pressed {
                update()
            }
        }
    }

    private lazy var trackingArea = NSTrackingArea(
        rect: self.frame,
        options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
        owner: self
    )

    private let titleView = NSTextField(labelWithString: "")
    private let iconView = NSImageView()

    private var widthAnchorConstraint: NSLayoutConstraint?
    private var titleViewLeadingAnchorConstraint: NSLayoutConstraint?

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        addSubview(iconView)
        addSubview(titleView)

        titleView.maximumNumberOfLines = -1
        titleView.lineBreakMode = .byTruncatingTail
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false

        iconView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        iconView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: style.padding.left).isActive = true

        titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: style.padding.left)
        titleViewLeadingAnchorConstraint!.isActive = true

        titleView.topAnchor.constraint(equalTo: topAnchor, constant: style.padding.top).isActive = true
        titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -style.padding.right).isActive = true
        titleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -style.padding.bottom).isActive = true

        widthAnchorConstraint = titleView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        widthAnchorConstraint!.isActive = true

        titleView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    public override func mouseEntered(with event: NSEvent) {
        hovered = true
    }

    public override func mouseExited(with event: NSEvent) {
        hovered = false
    }

    public override func mouseUp(with event: NSEvent) {
        if hovered {
            handleClick()
        }

        pressed = false
    }

    public override func mouseDown(with event: NSEvent) {
        if hovered {
            pressed = true
        }
    }

    private func handleClick() {
        onClick?()
    }

    private func update() {
        titleView.stringValue = titleText
        toolTip = titleText

        if let icon = icon {
            iconView.isHidden = false
            iconView.image = icon
            titleViewLeadingAnchorConstraint?.constant = style.padding.left + 16 + style.padding.left
        } else {
            iconView.isHidden = true
            iconView.image = nil
            titleViewLeadingAnchorConstraint?.constant = style.padding.left
        }

        widthAnchorConstraint?.constant = min(30, attributedTitleText.size().width)

        if pressed {
            fillColor = style.pressedBackgroundColor
        } else if hovered {
            fillColor = style.hoverBackgroundColor
        } else {
            fillColor = style.backgroundColor
        }
        cornerRadius = style.cornerRadius
    }
}
