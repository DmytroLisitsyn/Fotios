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

extension UIColor {

    public static func random() -> UIColor {
        let redLevel = CGFloat.random(in: 0...100) / 100
        let greenLevel = CGFloat.random(in: 0...100) / 100
        let blueLevel = CGFloat.random(in: 0...100) / 100

        return UIColor(red: redLevel, green: greenLevel, blue: blueLevel, alpha: 1.0)
    }

    public static func makeUsingHash<T: Hashable>(of entity: T) -> UIColor {
        var hash = abs(entity.hashValue)
        let red = CGFloat(hash % 100) / 100
        hash /= 100
        let green = CGFloat(hash % 100) / 100
        hash /= 100
        let blue = CGFloat(hash % 100) / 100

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    public var components: ColorComponents {
        return ColorComponents(self)
    }

}

extension UIColor {

    /**
     Initializes UIColor with 6- or 8-digit hex code.
     
     - Parameter hexString: Hexadecimal code string. For example "#ffe700ff" or "ffe700ff".
     */
    public convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)

        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        if hexString.count == 6 {
            hexString.append("ff")
        }

        guard hexString.count == 8 else {
            self.init()
            return
        }

        var hex: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&hex) else {
            self.init()
            return
        }

        let red = CGFloat((hex & 0xff000000) >> 24) / 255
        let green = CGFloat((hex & 0x00ff0000) >> 16) / 255
        let blue = CGFloat((hex & 0x0000ff00) >> 8) / 255
        let alpha = CGFloat(hex & 0x000000ff) / 255

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /**
     Returns 8-digit hex code string.
     
     - Returns: Hexadecimal code string. For example "ffe700ff".
     */
    public func hex() -> String {
        var c = ColorComponents(self)

        c.red *= 255
        c.green *= 255
        c.blue *= 255
        c.alpha *= 255

        return String(format: "%02x%02x%02x%02x", Int(c.red), Int(c.green), Int(c.blue), Int(c.alpha))
    }

    /**
     Blends `self` with passed color.
     
     - Parameter colorToBlendWith: Color to blend `self` with.
     - Parameter ratio: Intensity of `colorToBlendWith`. Can be in range from 0.0 to 1.0, where 0.0 or less will return `self`,
     and 1.0 or more will return `colorToBlendWith`. Default is 0.5.
     
     - Returns: Blending result.
     */
    public func blend(with colorToBlendWith: UIColor, ratio: CGFloat = 0.5) -> UIColor {
        if ratio <= 0 {
            return self
        } else if ratio >= 1 {
            return colorToBlendWith
        }

        let selfRatio = 1 - ratio

        let c1 = ColorComponents(self)
        let c2 = ColorComponents(colorToBlendWith)

        var c3 = ColorComponents()
        c3.red = c1.red * selfRatio + c2.red * ratio
        c3.green = c1.green * selfRatio + c2.green * ratio
        c3.blue = c1.blue * selfRatio + c2.blue * ratio
        c3.alpha = c1.alpha * selfRatio + c2.alpha * ratio

        return c3.uiColor
    }

}

public struct ColorComponents {

    public var red: CGFloat = 1.0
    public var green: CGFloat = 1.0
    public var blue: CGFloat = 1.0
    public var alpha: CGFloat = 1.0

    public var luminance: CGFloat {
        let value = 0.299 * red + 0.587 * green + 0.114 * blue
        return value
    }

    public var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    public init() {

    }

    public init(_ uiColor: UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }

}
