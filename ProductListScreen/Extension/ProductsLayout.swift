//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 15/12/2022.
//


import UIKit

protocol ProductsLayoutDelegate: AnyObject {
    func collectionView( _ collectionView: UICollectionView,
                         heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}
class ProductsLayout: UICollectionViewLayout {
    
    //MARK: -  Properties
    
    weak var delegate: ProductsLayoutDelegate?
    private let numberOfColumns = 2
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: contentHeight)
    }
    
    //MARK: - methods
    
    override func prepare() {
        cache.removeAll()
        guard let collectionView = collectionView else { return }
        contentHeight = 0
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        
        var xOffset = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
       
        for item in 0..<collectionView.numberOfItems(inSection: 0) {

            let indexPath = IndexPath(item: item, section: 0)
            let cellHeight = delegate?.collectionView(collectionView,
                                                      heightForPhotoAtIndexPath: indexPath) ?? 180
            let frame = CGRect(x: xOffset[column],
                               y: yOffset[column],
                               width: columnWidth,
                               height: cellHeight)
            
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + cellHeight
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
