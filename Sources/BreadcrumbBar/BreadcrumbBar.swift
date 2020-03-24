//
//  BreadcrumbBar.swift
//  ProjectName
//
//  Created by Devin Abbott on 8/26/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit

// MARK: - Breadcrumb

public struct Breadcrumb: Equatable {
    public var id: UUID
    public var title: String
    public var icon: NSImage?

    public init(id: UUID, title: String, icon: NSImage?) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}

// MARK: - BreadcrumbBar

public class BreadcrumbBar: NSBox {

    public static let slashDividerImage = NSImage(size: NSSize(width: 6, height: 14), flipped: false, drawingHandler: { rect in
       NSColor.textColor.withAlphaComponent(0.4).setStroke()
       let path = NSBezierPath()
       path.lineWidth = 1
       let pathRect = rect.insetBy(dx: path.lineWidth, dy: path.lineWidth)

       path.move(to: pathRect.origin)
       path.line(to: NSPoint(x: pathRect.maxX, y: pathRect.maxY))
       path.stroke()
       path.lineCapStyle = .round
       return true
   })

    public struct Style: Equatable {
        public var breadcrumbItemStyle: BreadcrumbItem.Style = .default
        public var itemsHaveEqualWidth: Bool = false
        public var padding: CGFloat = 2
        public var dividerPadding: CGFloat = 4
        public var dividerImage: NSImage? = BreadcrumbBar.slashDividerImage

        public static var `default` = Style()

        public static var compressible: Style = {
            var style = Style.default
            style.breadcrumbItemStyle = .compressible
            return style
        }()
    }

    // MARK: Lifecycle

    public init(breadcrumbs: [Breadcrumb] = [], isEnabled: Bool = true) {
        self.breadcrumbs = breadcrumbs
        self.isEnabled = isEnabled

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled {
                update()
            }
        }
    }

    public var breadcrumbs: [Breadcrumb] {
        didSet {
            if oldValue != breadcrumbs {
                update()
            }
        }
    }

    public var onClickBreadcrumb: ((UUID) -> Void)?

    public var style: Style = Style() {
       didSet {
           if oldValue != style {
               update()
           }
       }
    }

    // MARK: Private

    private var stackView = NSStackView()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        stackView.orientation = .horizontal
        stackView.spacing = 0

        addSubview(stackView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 2).isActive = true
        stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -2).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        stackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.setHuggingPriority(.defaultLow, for: .horizontal)
    }

    private func update() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for breadcrumb in breadcrumbs {
            let item = BreadcrumbItem(titleText: breadcrumb.title, icon: breadcrumb.icon)
            item.toolTip = breadcrumb.title
            item.style = style.breadcrumbItemStyle
            item.onClick = { [unowned self] in self.onClickBreadcrumb?(breadcrumb.id) }
            stackView.addArrangedSubview(item)

            if breadcrumb != breadcrumbs.last {
                stackView.setCustomSpacing(style.dividerPadding, after: item)

                if let dividerImage = style.dividerImage {
                    let divider = NSImageView()
                    divider.image = dividerImage
                    divider.widthAnchor.constraint(equalToConstant: dividerImage.size.width).isActive = true
                    divider.heightAnchor.constraint(equalToConstant: dividerImage.size.height).isActive = true
                    stackView.addArrangedSubview(divider)
                    stackView.setCustomSpacing(style.dividerPadding, after: divider)
                }
            }
        }

        let breadcrumbItems: [BreadcrumbItem] = stackView.arrangedSubviews.compactMap { $0 as? BreadcrumbItem }

        if style.itemsHaveEqualWidth {
            zip(breadcrumbItems.dropFirst(), breadcrumbItems.dropLast()).forEach { a, b in
                a.widthAnchor.constraint(equalTo: b.widthAnchor).isActive = true
            }
        }

        alphaValue = isEnabled ? 1 : 0.5
    }
}

