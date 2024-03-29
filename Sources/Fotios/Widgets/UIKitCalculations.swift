//
//  Copyright (C) 2019 Dmytro Lisitsyn
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

extension CGPoint {

    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func * (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    public static func / (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }

}

extension CGSize {

    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    public static func - (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    public static func * (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }

    public static func / (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }

}

extension CGRect {

    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(origin: lhs.origin + rhs.origin, size: lhs.size + rhs.size)
    }

    public static func - (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(origin: lhs.origin - rhs.origin, size: lhs.size - rhs.size)
    }

    public static func * (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(origin: lhs.origin * rhs.origin, size: lhs.size * rhs.size)
    }

    public static func / (_ lhs: Self, _ rhs: Self) -> Self {
        return .init(origin: lhs.origin / rhs.origin, size: lhs.size / rhs.size)
    }

}
