//
//  Copyright (C) 2017 Dmytro Lisitsyn
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

extension UIView {

    static var reuseIdentifier: String {
        let objectClass: AnyClass = self
        let objectClassName = NSStringFromClass(objectClass)
        let objectClassNameComponents = objectClassName.components(separatedBy: ".")
        return objectClassNameComponents.last!
    }

}

extension UITableView {

    public enum RegistrationTarget<T: UIView> {
        case cellClass(T.Type)
        case cellNib(T.Type)
        case headerFooterClass(T.Type)
        case headerFooterNib(T.Type)
    }

    public func register(_ target: RegistrationTarget<UIView>) {
        switch target {
        case .cellClass(let type):
            register(type, forCellReuseIdentifier: type.reuseIdentifier)
        case .cellNib(let type):
            let bundle = Bundle(for: type)
            let nib = UINib(nibName: type.reuseIdentifier, bundle: bundle)
            register(nib, forCellReuseIdentifier: type.reuseIdentifier)
        case .headerFooterClass(let type):
            register(type, forHeaderFooterViewReuseIdentifier: type.reuseIdentifier)
        case .headerFooterNib(let type):
            let bundle = Bundle(for: type)
            let nib = UINib(nibName: type.reuseIdentifier, bundle: bundle)
            register(nib, forHeaderFooterViewReuseIdentifier: type.reuseIdentifier)
        }
    }

    public func dequeue<T: UITableViewCell>(_ cell: T.Type = T.self, at indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: cell.reuseIdentifier, for: indexPath) as! T
    }

    public func dequeue<T: UITableViewHeaderFooterView>(_ view: T.Type = T.self) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: view.reuseIdentifier) as! T
    }

}

extension UICollectionView {

    public enum RegistrationTarget<T> {
        case cellClass(T.Type)
        case cellNib(T.Type)
        case supplementaryViewClass(kind: String, T.Type)
        case supplementaryViewNib(kind: String, T.Type)
    }

    public func register(_ target: RegistrationTarget<UIView>) {
        switch target {
        case .cellClass(let type):
            register(type, forCellWithReuseIdentifier: type.reuseIdentifier)
        case .cellNib(let type):
            let bundle = Bundle(for: type)
            let nib = UINib(nibName: type.reuseIdentifier, bundle: bundle)
            register(nib, forCellWithReuseIdentifier: type.reuseIdentifier)
        case .supplementaryViewClass(let kind, let type):
            register(type, forSupplementaryViewOfKind: kind, withReuseIdentifier: type.reuseIdentifier)
        case .supplementaryViewNib(let kind, let type):
            let bundle = Bundle(for: type)
            let nib = UINib(nibName: type.reuseIdentifier, bundle: bundle)
            register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: type.reuseIdentifier)
        }
    }

    public func dequeue<T: UICollectionViewCell>(_ cell: T.Type = T.self, at indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: cell.reuseIdentifier, for: indexPath) as! T
    }

    public func dequeue<T: UICollectionReusableView>(_ view: T.Type = T.self, kind: String, at indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: view.reuseIdentifier, for: indexPath) as! T
    }

}
