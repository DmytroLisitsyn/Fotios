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

import Foundation

public protocol CrystalViewDelegate: AnyObject {
    func crystalViewDidScroll(_ crystalView: CrystalView)
    func crystalViewWillEndDragging(_ crystalView: CrystalView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func crystalView(_ crystalView: CrystalView, willDisplayItemAt indexPath: IndexPath)
    func crystalView(_ crystalView: CrystalView, didSelectItemAt indexPath: IndexPath)
}

extension CrystalViewDelegate {

    public func crystalViewDidScroll(_ crystalView: CrystalView) {

    }

    public func crystalViewWillEndDragging(_ crystalView: CrystalView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

    }

    public func crystalView(_ crystalView: CrystalView, willDisplayItemAt indexPath: IndexPath) {

    }

    public func crystalView(_ crystalView: CrystalView, didSelectItemAt indexPath: IndexPath) {

    }

}
