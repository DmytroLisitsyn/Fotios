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

open class CrystalView: UICollectionView {

    public typealias DataSource = UICollectionViewDiffableDataSource<CrystalSection, CrystalItemContainer>
    public typealias Snapshot = NSDiffableDataSourceSnapshot<CrystalSection, CrystalItemContainer>

    public weak var crystalViewDelegate: CrystalViewDelegate?

    public lazy var crystalViewDataSource = makeDataSource(for: self)

    public var sectionInsets = UIEdgeInsets() {
        didSet { layout.invalidateLayout() }
    }

    public var minimumLineSpacing: CGFloat = 0 {
        didSet { layout.invalidateLayout() }
    }

    public var minimumInteritemSpacing: CGFloat = 0 {
        didSet { layout.invalidateLayout() }
    }

    public var sectionHeadersPinToVisibleBounds = false {
        didSet { layout.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds }
    }

    private lazy var registeredViews: Set<String> = []

    private var layout: UICollectionViewFlowLayout {
        return collectionViewLayout as! UICollectionViewFlowLayout
    }

    @available(*, unavailable)
    public override var dataSource: UICollectionViewDataSource? {
        get { return super.dataSource }
        set { super.dataSource = newValue }
    }

    @available(*, unavailable)
    public override var delegate: UICollectionViewDelegate? {
        get { return super.delegate }
        set { super.delegate = newValue }
    }

    public init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    public func invalidateLayout() {
        layout.invalidateLayout()
    }

    /// Registers reusable views for listed item types if not registered before.
    ///
    /// - Attention: Must be called before `dataSource` is supplied with items.
    public func registerTypes(headerTypes: [AnyCrystalItem.Type] = [], itemTypes: [AnyCrystalItem.Type]) {
        for headerType in headerTypes where !registeredViews.contains(headerType.viewType.reuseIdentifier) {
            let kind = UICollectionView.elementKindSectionHeader

            register(.supplementaryViewClass(kind: kind, headerType.viewType))
            registeredViews.insert(headerType.viewType.reuseIdentifier)
        }

        for itemType in itemTypes where !registeredViews.contains(itemType.viewType.reuseIdentifier) {
            register(.cellClass(itemType.viewType))
            registeredViews.insert(itemType.viewType.reuseIdentifier)
        }
    }

    private func makeDataSource(for crystalView: CrystalView) -> DataSource {
        let dataSource = DataSource(
            collectionView: crystalView,
            cellProvider: { collectionView, indexPath, itemContainer in
                let crystalView = collectionView as! CrystalView
                let snapshot = crystalView.crystalViewDataSource.snapshot()
                let section = snapshot.sectionIdentifiers[indexPath.section]
                let item = itemContainer.item

                let cellType = type(of: item).viewType as! UICollectionViewCell.Type
                let cell = collectionView.dequeue(cellType, at: indexPath) as! (UICollectionViewCell & AnyCrystalReusableView)

                let layoutType = type(of: item).layoutType
                let insets = section.insets ?? crystalView.sectionInsets
                let estimatedSize = collectionView.bounds.inset(by: insets).size
                let layout = layoutType.init(item: item, estimatedSize: estimatedSize)

                cell.setLayout(layout)
                cell.setItem(itemContainer.item)
                return cell
            }
        )

        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                let crystalView = collectionView as! CrystalView
                let snapshot = crystalView.crystalViewDataSource.snapshot()

                guard let header = snapshot.sectionIdentifiers[indexPath.section].header else {
                    return nil
                }

                let viewType = type(of: header).viewType
                let view = collectionView.dequeue(viewType, kind: elementKind, at: indexPath) as! AnyCrystalReusableView

                let layoutType = type(of: header).layoutType
                let layout = layoutType.init(item: header, estimatedSize: collectionView.bounds.size)

                view.setLayout(layout)
                view.setItem(header)
                return view
            default:
                return nil
            }
        }

        return dataSource
    }

    private func setup() {
        super.delegate = self
    }

}

extension CrystalView: UICollectionViewDelegateFlowLayout {

    // MARK: UIScrollViewDelegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        crystalViewDelegate?.crystalViewDidScroll(self)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        crystalViewDelegate?.crystalViewWillEndDragging(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    // MARK: Events

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        crystalViewDelegate?.crystalView(self, didSelectItemAt: indexPath)
    }

    // MARK: Layout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let section = crystalViewDataSource.snapshot().sectionIdentifiers.element(at: section)
        return section?.insets ?? sectionInsets
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let section = crystalViewDataSource.snapshot().sectionIdentifiers.element(at: section)
        return section?.minimumInteritemSpacing ?? minimumInteritemSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let section = crystalViewDataSource.snapshot().sectionIdentifiers.element(at: section)
        return section?.minimumLineSpacing ?? minimumLineSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let snapshot = crystalViewDataSource.snapshot()
        let section = snapshot.sectionIdentifiers[indexPath.section]
        let item = snapshot.itemIdentifiers(inSection: section)[indexPath.item].item

        let insets = section.insets ?? sectionInsets
        let estimatedSize = collectionView.bounds.inset(by: insets).size

        let layoutType = type(of: item).layoutType
        let layout = layoutType.init(item: item, estimatedSize: estimatedSize)

        if let cell = collectionView.cellForItem(at: indexPath) as? AnyCrystalReusableView {
            cell.setLayout(layout)
        }

        return layout.boundsSize
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let snapshot = crystalViewDataSource.snapshot()
        let sectionIdentifier = snapshot.sectionIdentifiers.element(at: section)

        if let header = sectionIdentifier?.header {
            let layoutType = type(of: header).layoutType
            let layout = layoutType.init(item: header, estimatedSize: collectionView.bounds.size)

            let indexPath = IndexPath(item: 0, section: section)
            let kind = UICollectionView.elementKindSectionHeader
            if let view = collectionView.supplementaryView(forElementKind: kind, at: indexPath) as? AnyCrystalReusableView {
                view.setLayout(layout)
            }

            return layout.boundsSize
        } else {
            return .zero
        }
    }

    // MARK: Displaying

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        crystalViewDelegate?.crystalView(self, willDisplayItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? AnyCrystalReusableView
        cell?.endDisplaying()
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {

    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        let view = view as? AnyCrystalReusableView
        view?.endDisplaying()
    }

}
