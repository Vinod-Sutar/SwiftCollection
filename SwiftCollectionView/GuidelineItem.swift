//
//  GuidelineItem.swift
//  SwiftCollectionView
//
//  Created by BBI-M USER1033 on 01/09/17.
//  Copyright © 2017 BBI-M USER1033. All rights reserved.
//

import Cocoa

class GuidelineItem: NSCollectionViewItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var draggingImageComponents: [NSDraggingImageComponent] {
        
        let itemRootView = self.view
        let itemBounds = itemRootView.bounds
        let bitmap = itemRootView.bitmapImageRepForCachingDisplay(in: itemBounds)!
        let bitmapData = bitmap.bitmapData
        if bitmapData != nil {
            bzero(bitmapData, bitmap.bytesPerRow * bitmap.pixelsHigh)
        }
        
        let slideCarrierImage = NSImage(named: NSImageNameFolder)
        NSGraphicsContext.saveGraphicsState()
        let oldContext = NSGraphicsContext.current()
        NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: bitmap))
        slideCarrierImage?.draw(in: itemBounds, from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
        NSGraphicsContext.setCurrent(oldContext)
        NSGraphicsContext.restoreGraphicsState()
        
        itemRootView.cacheDisplay(in: itemBounds, to: bitmap)
        let image = NSImage(size: bitmap.size)
        image.addRepresentation(bitmap)
        
        let component = NSDraggingImageComponent(key: NSDraggingImageComponentIconKey)
        component.frame = itemBounds
        component.contents = image
        
        return [component]
    }
}
