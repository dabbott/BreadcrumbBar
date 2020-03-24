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
        public var disabledAlphaValue: CGFloat = 0.5
        public var compressibleTitle: Bool = false

        public static var `default` = Style()

        public static var compressible: Style = {
            var style = Style.default
            style.compressibleTitle = true
            return style
        }()
    }

    // MARK: Lifecycle

    public init(titleText: String? = nil, icon: NSImage? = nil, isEnabled: Bool = true) {
        self.titleText = titleText
        self.icon = icon
        self.isEnabled = isEnabled

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

    public var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled {
                update()
            }
        }
    }

    public var onClick: (() -> Void)?

    public var onLongClick: (() -> Void)?

    public var style: Style = .default {
        didSet {
            if oldValue != style {
                update(updateConstraints: true)
            }
        }
    }

    public var titleText: String? {
        didSet {
            if oldValue != titleText {
                attributedTitleText = NSAttributedString(string: titleText ?? "")
            }
        }
    }

    public var icon: NSImage? {
        didSet {
            if oldValue != icon {
                update()
            }
        }
    }

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

    public let titleView = NSTextField(labelWithString: "")

    public let iconView = NSImageView()

    private var contentLayoutGuide = NSLayoutGuide()

    private var longPressWorkItem: DispatchWorkItem?

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        addSubview(iconView)
        addSubview(titleView)
        addLayoutGuide(contentLayoutGuide)

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

        titleView.widthAnchor.constraint(greaterThanOrEqualToConstant: 12).isActive = true

        titleView.topAnchor.constraint(equalTo: topAnchor, constant: style.padding.top).isActive = true
        titleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -style.padding.bottom).isActive = true

        // Use the contentLayoutGuide to center the icon and title within the BreadcrumbItem
        contentLayoutGuide.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        contentLayoutGuide.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
        contentLayoutGuide.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentLayoutGuide.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        iconViewLeadingConstraint = iconView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: style.padding.left)
        iconViewTrailingConstraint = iconView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -style.padding.right)
        iconViewTitleViewSiblingConstraint = iconView.trailingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: -style.padding.left)
        titleViewLeadingConstraint = titleView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: style.padding.left)
        titleViewTrailingConstraint = titleView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -style.padding.right)

        NSLayoutConstraint.activate(
            conditionalConstraints(
                titleViewIsHidden: titleView.isHidden,
                iconViewIsHidden: iconView.isHidden
            )
        )
    }

    private var iconViewLeadingConstraint: NSLayoutConstraint?
    private var iconViewTrailingConstraint: NSLayoutConstraint?
    private var iconViewTitleViewSiblingConstraint: NSLayoutConstraint?
    private var titleViewLeadingConstraint: NSLayoutConstraint?
    private var titleViewTrailingConstraint: NSLayoutConstraint?

    private func conditionalConstraints(titleViewIsHidden: Bool, iconViewIsHidden: Bool) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint?]

        iconViewLeadingConstraint?.constant = style.padding.left
        titleViewLeadingConstraint?.constant = style.padding.left

        iconViewTrailingConstraint?.constant = -style.padding.right
        titleViewTrailingConstraint?.constant = -style.padding.right

        titleView.setContentCompressionResistancePriority(style.compressibleTitle ? .defaultLow : .defaultHigh, for: .horizontal)

        switch (titleViewIsHidden, iconViewIsHidden) {
        case (false, false):
            constraints = [
                iconViewLeadingConstraint,
                iconViewTitleViewSiblingConstraint,
                titleViewTrailingConstraint
            ]
        case (false, true):
            constraints = [
                titleViewLeadingConstraint,
                titleViewTrailingConstraint
            ]
        case (true, false):
            constraints = [
                iconViewLeadingConstraint,
                iconViewTrailingConstraint
            ]
        case (true, true):
            constraints = []
        }

        return constraints.compactMap({ $0 })
    }

    public override func mouseEntered(with event: NSEvent) {
        hovered = true
    }

    public override func mouseExited(with event: NSEvent) {
        hovered = false
    }

    public override func mouseUp(with event: NSEvent) {
        if hovered && isEnabled {
            handleClick()
        }

        pressed = false

        longPressWorkItem?.cancel()
        longPressWorkItem = nil
    }

    public override func mouseDown(with event: NSEvent) {
        if hovered {
            pressed = true

            let workItem = DispatchWorkItem(block: { [weak self] in
                guard let self = self else { return }

                self.hovered = false
                self.pressed = false

                self.onLongClick?()
            })

            longPressWorkItem = workItem

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
        }
    }

    private func handleClick() {
        onClick?()
    }

    private func update(updateConstraints: Bool = false) {
        let iconViewIsHidden = iconView.isHidden
        let titleViewIsHidden = titleView.isHidden

        if let titleText = titleText {
            titleView.isHidden = false
            titleView.stringValue = titleText
        } else {
            titleView.isHidden = true
        }
        
        if let icon = icon {
            iconView.isHidden = false
            iconView.image = icon
            iconView.alphaValue = isEnabled ? 1 : style.disabledAlphaValue
        } else {
            iconView.isHidden = true
            iconView.image = nil
        }

        if updateConstraints || iconViewIsHidden != iconView.isHidden || titleViewIsHidden != titleView.isHidden {
            NSLayoutConstraint.deactivate(
                conditionalConstraints(
                    titleViewIsHidden: titleViewIsHidden,
                    iconViewIsHidden: iconViewIsHidden
                )
            )
            NSLayoutConstraint.activate(
                conditionalConstraints(
                    titleViewIsHidden: titleView.isHidden,
                    iconViewIsHidden: iconView.isHidden
                )
            )
        }

        if isEnabled && pressed {
            fillColor = style.pressedBackgroundColor
        } else if isEnabled && hovered {
            fillColor = style.hoverBackgroundColor
        } else {
            fillColor = style.backgroundColor
        }

        cornerRadius = style.cornerRadius
    }
}
