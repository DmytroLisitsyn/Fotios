//
//  Copyright (C) 2020 Dmytro Lisitsyn
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

public struct Akro {
    
    private let rootView: UIView
    private var layoutAttributes: [NSLayoutConstraint.Attribute] = []
    
    fileprivate init(rootView: UIView) {
        self.rootView = rootView
        
        rootView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func canUseSuperviewAsDefaultView(_ layoutAttribute: NSLayoutConstraint.Attribute) -> Bool {
        return layoutAttribute != .width && layoutAttribute != .height
    }
    
    private func makeEdgeMultiplier(for layoutAttribute: NSLayoutConstraint.Attribute) -> CGFloat {
        switch layoutAttribute {
        case .bottom, .trailing:
            return -1
        default:
            return 1
        }
    }
    
    private func makeRelation(_ relation: NSLayoutConstraint.Relation, multipliedBy edgeMultiplier: CGFloat) -> NSLayoutConstraint.Relation {
        switch relation {
        case .lessThanOrEqual where edgeMultiplier < 0:
            return .greaterThanOrEqual
        case .greaterThanOrEqual where edgeMultiplier < 0:
            return .lessThanOrEqual
        default:
            return relation
        }
    }
    
}

extension Akro {
    
    public var all: Akro {
        return top.bottom.leading.trailing
    }

    public var centerX: Akro {
        var akro = self
        akro.layoutAttributes.append(.centerX)
        return akro
    }
    
    public var centerY: Akro {
        var akro = self
        akro.layoutAttributes.append(.centerY)
        return akro
    }
    
    public var top: Akro {
        var akro = self
        akro.layoutAttributes.append(.top)
        return akro
    }
    
    public var bottom: Akro {
        var akro = self
        akro.layoutAttributes.append(.bottom)
        return akro
    }
    
    public var leading: Akro {
        var akro = self
        akro.layoutAttributes.append(.leading)
        return akro
    }
    
    public var trailing: Akro {
        var akro = self
        akro.layoutAttributes.append(.trailing)
        return akro
    }
    
    public var width: Akro {
        var akro = self
        akro.layoutAttributes.append(.width)
        return akro
    }
    
    public var height: Akro {
        var akro = self
        akro.layoutAttributes.append(.height)
        return akro
    }
    
    public var firstBaseline: Akro {
        var akro = self
        akro.layoutAttributes.append(.firstBaseline)
        return akro
    }
    
    public var lastBaseline: Akro {
        var akro = self
        akro.layoutAttributes.append(.lastBaseline)
        return akro
    }
    
    public func setup(_ setup: (_ akro: Akro) -> Void) {
        setup(self)
    }
    
    @discardableResult
    public func apply(to target: AkroApplicable?) -> [NSLayoutConstraint] {
        return apply(to: target, relation: .equal)
    }
    
    @discardableResult
    public func apply(constant: CGFloat) -> [NSLayoutConstraint] {
        return apply(relation: .equal, constant: constant)
    }
    
    @discardableResult
    public func apply(
        to target: AkroApplicable? = nil,
        attribute: NSLayoutConstraint.Attribute? = nil,
        relation: NSLayoutConstraint.Relation = .equal,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> [NSLayoutConstraint] {
        let akro = self
        
        var constraints: [NSLayoutConstraint] = []
        var layoutAttributes = akro.layoutAttributes
        var target = target
        
        if layoutAttributes.isEmpty {
            layoutAttributes.append(contentsOf: [.top, .bottom, .leading, .trailing])
        }
        
        for layoutAttribute in layoutAttributes {
            if target == nil, canUseSuperviewAsDefaultView(layoutAttribute) {
                target = akro.rootView.superview
            }
            
            let targetAttribute = attribute ?? layoutAttribute

            let edgeMultiplier = makeEdgeMultiplier(for: layoutAttribute)
            let constant = constant * edgeMultiplier
            let relation = makeRelation(relation, multipliedBy: edgeMultiplier)
                        
            let constraint = NSLayoutConstraint(
                item: akro.rootView,
                attribute: layoutAttribute,
                relatedBy: relation,
                toItem: target,
                attribute: targetAttribute,
                multiplier: multiplier,
                constant: constant
            )
            
            constraint.priority = priority
            constraint.isActive = true
            
            constraints.append(constraint)
        }
        
        return constraints
    }
    
}

// MARK: - AkroApplicable

public protocol AkroApplicable {
    
}

extension UIView: AkroApplicable {
    
    public var akro: Akro {
        return Akro(rootView: self)
    }
    
}

extension UILayoutGuide: AkroApplicable {
    
}
