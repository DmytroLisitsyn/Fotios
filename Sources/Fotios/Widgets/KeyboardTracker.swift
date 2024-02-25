//
//  Copyright (C) 2016 Dmytro Lisitsyn
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

public protocol KeyboardTrackerDelegate: AnyObject {
    func keyboardTracker(_ keyboardTracker: KeyboardTracker, keyboardWillShowIn rect: CGRect, animationDuration: TimeInterval)
    func keyboardTracker(_ keyboardTracker: KeyboardTracker, keyboardWillHideFrom rect: CGRect, animationDuration: TimeInterval)
}

public final class KeyboardTracker: NSObject {

    public weak var delegate: KeyboardTrackerDelegate?

    public let keyboardLayoutGuide = UILayoutGuide()

    private weak var view: UIView?
    private var keyboardTopConstraint: NSLayoutConstraint?
    private var tapGestureRecognizer: UITapGestureRecognizer?

    public override init() {
        super.init()

        setup()
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let rect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0

        delegate?.keyboardTracker(self, keyboardWillShowIn: rect, animationDuration: duration)
        
        if let view = view {
            keyboardTopConstraint?.constant = rect.height - view.safeAreaInsets.bottom

            UIView.animate(withDuration: duration) {
                view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let rect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0

        delegate?.keyboardTracker(self, keyboardWillHideFrom: rect, animationDuration: duration)
        
        if let view = view {
            keyboardTopConstraint?.constant = 0
            
            UIView.animate(withDuration: duration) {
                view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        view?.endEditing(true)
    }
    
    public func setupKeyboardLayoutGuide(for view: UIView, shouldHideKeyboardOnTap: Bool = false) {
        self.view = view
        
        view.addLayoutGuide(keyboardLayoutGuide)
        
        keyboardTopConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.bottomAnchor)
        keyboardTopConstraint?.isActive = true
        
        if shouldHideKeyboardOnTap {
            let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(viewTapped))
            view.addGestureRecognizer(tapGestureRecognizer)
            self.tapGestureRecognizer = tapGestureRecognizer
        }
    }
    
    private func setup() {
        let center: NotificationCenter = .default
        center.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}
