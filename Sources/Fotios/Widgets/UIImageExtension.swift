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

extension UIImage {
    
    public func filled(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        context!.translateBy(x: 0, y: size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context!.setBlendMode(.normal)
        context!.draw(cgImage!, in: rect)
        
        context!.setBlendMode(.sourceIn)
        color.setFill()
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    public func merged(with other: UIImage) -> UIImage? {
        let size = CGSize(
            width: max(size.width, other.size.width),
            height: max(size.height, other.size.height)
        )
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let mergedImage = renderer.image { _ in
            let image1Rect = CGRect(origin: .zero, size: self.size)
            self.draw(in: image1Rect)
            
            let image2Rect = CGRect(origin: CGPoint(x: size.width - other.size.width, y: size.height - other.size.height), size: other.size)
            other.draw(in: image2Rect)
        }
        
        return mergedImage
    }
    
    public func resized(_ smallerSideSize: CGFloat) -> UIImage {
        let originalSize = self.size
        
        guard originalSize.width > smallerSideSize && originalSize.height > smallerSideSize else {
            return self
        }
        
        let widthRatio = smallerSideSize / originalSize.width
        let heightRatio = smallerSideSize / originalSize.height

        var newSize: CGSize
        if widthRatio < heightRatio {
            newSize = CGSize(width: originalSize.width * heightRatio, height: originalSize.height * heightRatio)
        } else {
            newSize = CGSize(width: originalSize.width * widthRatio, height: originalSize.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
    
}
