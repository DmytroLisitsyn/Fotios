//
//  Copyright (C) 2023 Dmytro Lisitsyn
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

// MARK: - CrystalSection

public final class CrystalSection: Hashable {

    public let id: String
    public var header: AnyCrystalItem?

    public var insets: UIEdgeInsets?
    public var minimumLineSpacing: CGFloat?
    public var minimumInteritemSpacing: CGFloat?

    public init(id: String, header: AnyCrystalItem? = nil) {
        self.id = id
        self.header = header
    }

    public static func == (lhs: CrystalSection, rhs: CrystalSection) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

extension CrystalSection {

    public static var `default`: CrystalSection {
        let section = CrystalSection(id: "CrystalSection.Default")
        return section
    }

}

// MARK: - CrystalItemContainer

public final class CrystalItemContainer: Hashable {

    public let id: String
    public var item: AnyCrystalItem

    public init(id: String, item: AnyCrystalItem) {
        self.id = id
        self.item = item
    }

    public static func == (lhs: CrystalItemContainer, rhs: CrystalItemContainer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

// MARK: - CrystalItem

public protocol AnyCrystalItem {
    static var viewType: AnyCrystalReusableView.Type { get }
    static var layoutType: AnyCrystalReusableViewLayout.Type { get }
}

/// Base protocol for reusable view's view model.
public protocol CrystalItem: AnyCrystalItem {
    associatedtype View: CrystalReusableView
    associatedtype Layout: CrystalReusableViewLayout
}

extension CrystalItem {

    public static var viewType: AnyCrystalReusableView.Type {
        return View.self
    }

    public static var layoutType: AnyCrystalReusableViewLayout.Type {
        return Layout.self
    }

}

// MARK: - CrystalReusableView

public protocol AnyCrystalReusableView: UICollectionReusableView {
    func setItem(_ item: AnyCrystalItem)
    func setLayout(_ layout: AnyCrystalReusableViewLayout?)
    func endDisplaying()
}

/// Base protocol for reusable view.
public protocol CrystalReusableView: AnyCrystalReusableView {
    associatedtype Item: CrystalItem

    func setItem(_ item: Item)
    func setLayout(_ layout: Item.Layout)
}

extension CrystalReusableView {

    public func setItem(_ item: AnyCrystalItem) {
        let item = item as! Item
        setItem(item)
    }

    public func setLayout(_ layout: AnyCrystalReusableViewLayout?) {
        if let layout = layout as? Item.Layout {
            setLayout(layout)
        }
    }

    public func endDisplaying() {

    }

}

// MARK: CrystalReusableLayout

public protocol AnyCrystalReusableViewLayout {
    var boundsSize: CGSize { get }

    init(item: AnyCrystalItem, estimatedSize: CGSize)
}

public protocol CrystalReusableViewLayout: AnyCrystalReusableViewLayout {
    associatedtype Item: CrystalItem

    init(item: Item, estimatedSize: CGSize)
}

extension CrystalReusableViewLayout {

    public init(item: AnyCrystalItem, estimatedSize: CGSize) {
        let item = item as! Item
        self.init(item: item, estimatedSize: estimatedSize)
    }

}
