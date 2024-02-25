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

public protocol SerafimImplied {
    var serafim: Serafim { get }
}

extension SerafimImplied {
    public var serafim: Serafim { Serafim.shared }
}

// MARK: - Serafim

public final class Serafim {

    public struct Transition {

        public enum Kind {
            case push
            case presentModally
        }

        public var name: String?
        public var kind: Kind
        public var destination: UIViewController

        /// Use this property to set desired hierarchy to perform push transition in.
        /// For example, when you want to perform transition in the view controller,
        /// embedded in another view controller.
        public var relative: UIViewController?

        public var presentation: UIModalPresentationStyle?
        public var transition: UIModalTransitionStyle?
        public weak var delegate: UIViewControllerTransitioningDelegate?

        public init(name: String? = nil, kind: Kind, destination: UIViewController) {
            self.name = name
            self.kind = kind
            self.destination = destination
        }

    }

    public static let shared = Serafim()

    public var window: UIWindow? {
        didSet { root = window?.rootViewController }
    }

    public var root: UIViewController? {
        didSet { didSetRoot(root) }
    }

    public var current: UIViewController? {
        return root.flatMap(fetchYoungestInHierarchy)
    }

    private struct NamedTransitionContainer {
        weak var source: UIViewController?
        weak var destination: UIViewController?
    }

    private var namedTransitionMap: [String: NamedTransitionContainer] = [:]

    public init(window: UIWindow? = nil) {
        self.window = window

        didSetRoot(root)
    }

    public init(root: UIViewController?) {
        self.root = root

        didSetRoot(root)
    }

    public func push(_ controller: UIViewController, relative: UIViewController? = nil, animated: Bool = true, completionHandler: (() -> Void)? = nil) {
        var transition = Serafim.Transition(kind: .push, destination: controller)
        transition.relative = relative
        perform(transition, animated: animated, completionHandler: completionHandler)
    }

    public func present(
        _ controller: UIViewController,
        presentation: UIModalPresentationStyle? = .fullScreen,
        transition transitionStyle: UIModalTransitionStyle? = .coverVertical,
        delegate: UIViewControllerTransitioningDelegate? = nil,
        animated: Bool = true,
        completionHandler: (() -> Void)? = nil
    ) {
        var transition = Serafim.Transition(kind: .presentModally, destination: controller)
        transition.presentation = presentation
        transition.transition = transitionStyle
        transition.delegate = delegate
        perform(transition, animated: animated, completionHandler: completionHandler)
    }

    public func perform(_ transition: Transition, animated: Bool = true, completionHandler: (() -> Void)? = nil) {
        let sourceCandidate = transition.relative ?? current

        guard let source = sourceCandidate else { return }

        if let name = transition.name {
            namedTransitionMap[name] = NamedTransitionContainer(source: source, destination: transition.destination)
        }

        switch transition.kind {
        case .push:
            guard let navigationController = (source as? UINavigationController) ?? source.navigationController else {
                break
            }

            navigationController.pushViewController(transition.destination, animated: animated)

            if animated, let transitionCoordinator = navigationController.transitionCoordinator {
                transitionCoordinator.animate(alongsideTransition: nil, completion: { _ in completionHandler?() })
            } else {
                DispatchQueue.main.async {
                    completionHandler?()
                }
            }
        case .presentModally:
            if let modalPresentationStyle = transition.presentation {
                transition.destination.modalPresentationStyle = modalPresentationStyle
            }

            if let modalTransitionStyle = transition.transition {
                transition.destination.modalTransitionStyle = modalTransitionStyle
            }

            if let transitioningDelegate = transition.delegate {
                transition.destination.transitioningDelegate = transitioningDelegate
            }

            source.present(transition.destination, animated: animated, completion: completionHandler)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func undo<T: UIViewController>(to type: T.Type? = nil, name: String? = nil, animated: Bool = true, completionHandler: (() -> Void)? = nil) {
        guard let root = root else { return }

        let queryIncluded = type != nil || name != nil
        if queryIncluded {
            if let controller = fetchOccurrenceInHierarchy(of: root, name: name, type: type) {
                if controller.presentedViewController != nil {
                    if let navigationController = controller as? UINavigationController {
                        let viewControllers = Array(navigationController.viewControllers.prefix(through: 0))
                        navigationController.setViewControllers(viewControllers, animated: false)
                    } else if let navigationController = controller.navigationController {
                        let index = navigationController.viewControllers.firstIndex(of: controller) ?? 0
                        let viewControllers = Array(navigationController.viewControllers.prefix(through: index))
                        navigationController.setViewControllers(viewControllers, animated: false)
                    }

                    controller.dismiss(animated: animated, completion: completionHandler)
                } else if let navigationController = controller.navigationController {
                    navigationController.popToViewController(controller, animated: animated)

                    if animated, let transitionCoordinator = navigationController.transitionCoordinator {
                        transitionCoordinator.animate(alongsideTransition: nil, completion: { _ in completionHandler?() })
                    } else {
                        completionHandler?()
                    }
                }
            } else {
                debugPrint("Can't undo to the view controller with a given type or transition name. Will undo last transition instead.")
                undo(animated: animated, completionHandler: completionHandler)
            }
        } else if let current = current {
            if let navigationController = current.navigationController, navigationController.viewControllers.first != navigationController.topViewController {
                navigationController.popViewController(animated: animated)

                if animated, let transitionCoordinator = navigationController.transitionCoordinator {
                    transitionCoordinator.animate(alongsideTransition: nil, completion: { _ in completionHandler?() })
                } else {
                    completionHandler?()
                }
            } else {
                let presenting = current.presentingViewController
                presenting?.dismiss(animated: animated, completion: completionHandler)
            }
        }

        cleanUpNamedTransitionContainer()
    }

    public func lastInHierarchy<T: UIViewController>(_ type: T.Type? = nil, named name: String? = nil) -> T? {
        guard let root = root else {
            return nil
        }

        let controller = fetchOccurrenceInHierarchy(of: root, name: name, type: type) as? T
        return controller
    }

}

extension Serafim {

    private func fetchYoungestInHierarchy(of viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return fetchYoungestInHierarchy(of: presentedViewController)
        } else if let navigationController = viewController as? UINavigationController, let topViewController = navigationController.topViewController {
            return topViewController
        } else if let tabBarController = viewController as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
            return fetchYoungestInHierarchy(of: selectedViewController)
        } else {
            return viewController
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func fetchOccurrenceInHierarchy<T: UIViewController>(of viewController: UIViewController, name: String?, type: T.Type?) -> UIViewController? {
        if fitsCriteria(viewController, name: name, type: type) {
            return viewController
        } else if let navigationController = viewController as? UINavigationController {
            for viewController in navigationController.viewControllers {
                if let viewController = fetchOccurrenceInHierarchy(of: viewController, name: name, type: type) {
                    return viewController
                }
            }
        } else if let tabBarController = viewController as? UITabBarController {
            for viewController in tabBarController.viewControllers ?? [] {
                if let viewController = fetchOccurrenceInHierarchy(of: viewController, name: name, type: type) {
                    return viewController
                }
            }
        } else if !viewController.children.isEmpty {
            for viewController in viewController.children {
                if let viewController = fetchOccurrenceInHierarchy(of: viewController, name: name, type: type) {
                    return viewController
                }
            }
        } else if let presentedViewController = viewController.presentedViewController {
            return fetchOccurrenceInHierarchy(of: presentedViewController, name: name, type: type)
        }

        return nil
    }

    private func fitsCriteria<T: UIViewController>(_ viewController: UIViewController, name: String?, type: T.Type?) -> Bool {
        var viewControllerFits = true

        if let name = name {
            viewControllerFits = viewControllerFits && viewController == namedTransitionMap[name]?.source
        }

        if type != nil {
            viewControllerFits = viewControllerFits && Swift.type(of: viewController) == type
        }

        return viewControllerFits
    }

    private func cleanUpNamedTransitionContainer() {
        namedTransitionMap = namedTransitionMap.filter { (_, value) in
            return value.destination != nil
        }
    }

    private func didSetRoot(_ root: UIViewController?) {
        if let window = window {
            if window.rootViewController != root {
                window.rootViewController = root
            }
        }
    }

}
