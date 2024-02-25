//
//  Copyright (C) 20201 Dmytro Lisitsyn
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

public final class ReverseMaskLayer: CALayer {

    public var reverseMask: CALayer? {
        didSet { setNeedsDisplay() }
    }
    
    public var fillColor: CGColor = UIColor.black.cgColor {
        didSet { setNeedsDisplay() }
    }

    public override func draw(in ctx: CGContext) {
        var mask: CGImage?
        if let reverseMask = reverseMask {
            ctx.saveGState()

            let origin = reverseMask.frame.origin
            ctx.translateBy(x: origin.x, y: origin.y)

            reverseMask.render(in: ctx)
            ctx.setBlendMode(.sourceIn)
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fill(reverseMask.bounds)

            ctx.restoreGState()

            mask = ctx.makeImage()?.masked()
        }

        if let mask = mask {
            ctx.saveGState()

            let rect = ctx.boundingBoxOfClipPath
            ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: rect.height))

            ctx.clear(rect)
            ctx.clip(to: rect, mask: mask)
            ctx.setFillColor(fillColor)
            ctx.fill(rect)

            ctx.restoreGState()
        }
    }

}

extension CGImage {

    fileprivate func masked() -> CGImage {
        return CGImage(
            maskWidth: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            provider: dataProvider!,
            decode: decode,
            shouldInterpolate: shouldInterpolate
        )!
    }

}
